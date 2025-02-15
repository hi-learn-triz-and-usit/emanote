# emanote

WIP: Spiritual successor to [neuron](https://neuron.zettel.page), based on [Ema](https://ema.srid.ca).

Create beautiful websites -- such as personal webpage, blog, wiki, Zettelkasten, notebook, knowledge-base, documentation, etc. from future-proof plain-text notes and arbitrary data -- with live preview that updates in real-time.

**Project Status**: Alpha status, but usable for generating documentation sites (see examples below). HTML templates are yet to be finalized. More features are being worked on (see tasks below).

## Installing and using

```bash
# Install
nix-env -if ./default.nix

# Run live server
PORT=8001 emanote -C /path/to/notebook

# Generate static files
mkdir /tmp/output
emanote -C /path/to/notebook gen /tmp/output
```

### Examples

* [ema.srid.ca](https://ema.srid.ca) (generated from [these sources](https://github.com/srid/emanote/tree/master/docs)).
* [Haskell KB](https://taylor.fausak.me/haskell-knowledge-base/) (generated from [these sources](https://github.com/tfausak/haskell-knowledge-base))

## Hacking

To develop with full IDE support in Visual Studio Code, follow these steps:

- [Install Nix](https://nixos.org/download.html) & [enable Flakes](https://nixos.wiki/wiki/Flakes)
- Run `nix-shell --run haskell-language-server` to sanity check your environment 
- [Open as single-folder workspace](https://code.visualstudio.com/docs/editor/workspaces#_singlefolder-workspaces) in Visual Studio Code
    - Install the [workspace recommended](https://code.visualstudio.com/docs/editor/extension-marketplace#_workspace-recommended-extensions) extensions
    - <kbd>Ctrl+Shift+P</kbd> to run command "Nix-Env: Select Environment" and select `shell.nix`. The extension will ask you to reload VSCode at the end.
- Press <kbd>Ctrl+Shift+B</kbd> in VSCode, or run `bin/run` (`bin/run-via-tmux` if you have tmux installed) in terminal, to launch the Ema dev server, and navigate to http://localhost:9010/

All but the final step need to be done only once.

## Tasks

### Current

Before tests (tasks impacting the larger architectural context in code base),

- [x] Interlude(architecture): a layer between ema and emanote
  - source -> target file transformation with routing
  - examples
    - source: .md, .org, static files, ..
    - output: .rss/.xml
- [ ] WikiLink: allow linking to non-HTML files.
  - Refactor `Route` to accomodate them all, and ditch `Either FilePath`
- Embedding / Filtering / Transforming / etc
  - [ ] Link embedding: support `![[]]` of Obsidian? https://help.obsidian.md/How+to/Embed+files
    - Have `rewriteLinks` pass "title" to WikiLink parser, and have it return `WikiLink Video` (as distinct from `WikiLink Md`)
      - For embed flag, make that `WikiLink Embed Video` (vs `WikiLink (Conn Folge) Md`)
    - That, or do it from `<PandocLink>` style, in `rpBlock` by decoding "title" attr.
    - Also consider non-Obsidian formats, `![[program.hs:2-13]]
  - [ ] Queries and results embed
- [ ] Generation of pages with no associated Markdown
  - eg: Pagination ala https://web.dev/authors/ | https://web.dev/how-we-build-webdev-and-use-web-components/#collections
- [ ] neuron UpTree?
  - ixset + path finding traversal
  - rendering design: where to place? esp. in relation to sidebar?
- [ ] Finally, **tests**!
  - URL parsing (.md and wiki-links) and route encoding/decoding
  - Metadata overriding

To triage,

- [ ] apply prismJS on live server refresh?
  - Hack on `<script class="ema-rerun">`?
- [ ] `emanote gen` should generate $dir.html even if $dir.md doesn't exist.
- [ ] Proper footnote styling: take Tufte style (sidebar refs) into consideration
- [ ] BUG: raw HTML doesn't work (eg: <video> element)
  - Blame https://github.com/snapframework/xmlhtml ?
    - Culprit, possibly: https://github.com/snapframework/xmlhtml/blob/54463f1691c7b31cc3c4c336a6fe328b1f0ebb95/src/Text/Blaze/Renderer/XmlHtml.hs#L27
- [ ] `emanote init` to allow editing default templates/yaml
- [x] Add fsnotify watcher for default template files (etc), but only in ghcid mode
- [ ] Allow overriding baseUrl in CLI: `emanote gen --baseUrl=srid.github.io/foo`
- [x] Sidebar: expand-by-default on per-tree basis, by enabling it on yaml or frontmatter
- [ ] `neuron query` equivalent?
- [ ] Heist Pandoc splice: allow custom "class library" with hierarchy:
  ```
  <Pandoc>
    <Custom>
      <Popout class="px-1 font-serif rounded bg-pink-50" />
      <!-- Hierarchical styling? -->
      <Warning class="px-1 rounded bg-gray-50">
        <Header>
          <h2>class="text-xl font-bold"</h2>
        </Header>
      </Warning>
    </Custom>
  </Pandoc>
  ```

Before public release

- [x] Finalize in HTML templating: heist vs a more popular one?
  - Probably gonna take the heist trade-off, given the ability to customize breadcrumbs/sidebar/pandoc HTML

### Archived Tasks

Initial MVP,

- [x] Wiki-links
- Splice work
  - [x] Make sidebar tree a splice
  - [x] Make breadcrumbs a splice
    - Requires supporting arbitrary HTML in node children
  - [x] Make pandoc view a splice
- [x] Backlinks
  - Using ixset
- [x] Report error on web / CLI on markdown parse failure (generally on any error)
- [x] .emanote/templates/settings.yml - to pass global vars (`theme`, `site-title`) as-is
- [x] Use default templates and metadata if none exist
  - [x] Load templates from cabal data-files by default
  - [x] Do the same for `index.yaml` (then test on haskell-kb)
- [x] Use default static files (favicon.svg) for those that do not exist
- [x] Finish Pandoc AST rendering (address Unsupported)
- [x] Add docker image
- [x] Milestone: Make ema.srid.ca an emanote site
  - Bugs and blockers
    - [x] /start.md - the .md breaks links
    - [x] workaround raw html bug (see below) using video raw format
    - [x] "Next" styling, via class map in .yaml
  - [x] docs: adjust tutorial for new ema-template 
  - [x] ema-docs: replace with ema-template
- [x] Tailwind CDN: replace with windi workflow for faster page load, or use Twind shim
- [x] Avoid "Ema - Ema" kind of title. Pass ifIndexRoute splice?
- [x] BUG: /Haskell.org (with dot in it) crashes ema dev server
- [x] Milestone: `./emanote -C ~/code/haskell-knowledge-base` should just work.

