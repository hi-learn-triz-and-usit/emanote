{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Emanote.Model.Rel where

import Control.Lens.Operators as Lens ((^.))
import Control.Lens.TH (makeLenses)
import Data.Data (Data)
import Data.IxSet.Typed (Indexable (..), IxSet, ixGen, ixList)
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import Emanote.Model.Note (Note, noteDoc, noteRoute)
import qualified Emanote.Route as R
import Emanote.Route.Ext
import qualified Emanote.Route.WikiLinkTarget as WL
import qualified Text.Pandoc.Definition as B
import qualified Text.Pandoc.LinkContext as LC

type TargetRoute = Either WL.WikiLinkTarget (R.Route ('LMLType 'Md))

-- | A relation from one note to another.
data Rel = Rel
  { _relFrom :: R.Route ('LMLType 'Md),
    _relTo :: TargetRoute,
    -- | The relation context of 'from' note linking to 'to' note.
    _relCtx :: NonEmpty [B.Block]
  }
  deriving (Data, Show)

instance Eq Rel where
  (==) = (==) `on` (_relFrom &&& _relTo)

instance Ord Rel where
  (<=) = (<=) `on` (_relFrom &&& _relTo)

type RelIxs = '[R.Route ('LMLType 'Md), TargetRoute]

type IxRel = IxSet RelIxs Rel

instance Indexable RelIxs Rel where
  indices =
    ixList
      (ixGen $ Proxy @(R.Route ('LMLType 'Md)))
      (ixGen $ Proxy @TargetRoute)

makeLenses ''Rel

extractRels :: Note -> [Rel]
extractRels note =
  extractLinks . Map.map (fmap snd) . LC.queryLinksWithContext $ note ^. noteDoc
  where
    extractLinks :: Map Text (NonEmpty [B.Block]) -> [Rel]
    extractLinks m =
      flip mapMaybe (Map.toList m) $ \(url, ctx) -> do
        target <- parseUrl url
        pure $ Rel (note ^. noteRoute) target ctx

-- | Parse a URL string
parseUrl :: Text -> Maybe TargetRoute
parseUrl url = do
  guard $ not $ "://" `T.isInfixOf` url
  fmap Right (R.mkRouteFromFilePath @('LMLType 'Md) $ toString url)
    <|> fmap Left (WL.mkWikiLinkTargetFromUrl url)
