# Implementation notes

This document covers what's different in this fork from the original BPatterns, in more detail than the [README](README.md)'s API summary.

## Changes

- The pattern engine now builds on Pharo's `RB*` (RefactoringBrowser) AST/searcher classes instead of `OC*` (OpenChain), to match what GT itself uses.
- `BPattern >> #users` / `#usersInClass:` are re-implemented on top of GT's own search-filter framework (`GtSearchBPatternFilter`) instead of a manual `Smalltalk allClasses` scan.
- `BPattern >> #uniqueUsers` / `#uniqueUsersInClass:` return matching methods de-duplicated by origin (`<origin, selector>`), so a method composed into many classes from a single Trait is only reported once — as opposed to `#users`/`#usersInClass:`, which answer one result per distinct `<methodClass, selector>` pair (every method actually installed in the system, including one per Trait composition). Both are correct; they just answer different questions.

## API

- `BPattern >> #executeSearchInFilter:` and `BPattern >> #potentialMethodsInFilter:` expose the search as GT-integration building blocks: the former composes a `GtSearchBPatternFilter` into a given search scope, excluding Trait-composed methods (`isFromTrait`) — one result per `<origin, selector>` pair, the same set as `#uniqueUsers` and for the same reason — and is what the inspector's Search buttons and both Lepiter snippets below call, so their result counts match `#uniqueUsers`, not `#users`; the latter turns that into a lazy async stream of candidate methods for `BPatternRewrite` to rewrite.
- `BPatternRewrite >> #executeRewriteInFilter:` streams candidates from `#potentialMethodsInFilter:` and compiles each rewritten method as it arrives, answering a `TAsyncFuture` of the resulting `RBNamespace` — fully non-blocking end to end, mirroring `LePharoRewriteSnippet`'s own async design.

## Custom views, actions and snippets

### gtViews, gtActions

- `BPattern` gets two new inspector tabs, **SearchPattern** (the pattern's AST as a tree) and **Metrics**, and a **Search** button (`#gtSearchActionFor:`) that spawns the `GtSearchBPatternFilter` for the pattern over all methods.
- `BPatternRewrite` gets three inspector tabs: **SearchPattern** and **RewritePattern** (the AST of each side as a tree, the same view as `BPattern`'s) and **Metrics** (computed for the search pattern, since only that side is matched). It also gets a **Search** button (on its search pattern) and a **Rewrite** button (`#gtRewriteActionFor:`) that spawns the async rewrite preview. The buttons make the same calls as those of the two Lepiter snippets below, minus their "Search in:" scope.
- `GtSearchBPatternFilter` — a `GtSearchMethodsFilter` that lets a `BPattern` be composed into GT's search/scope pipeline (`&`, `|`, class/package scoping, etc.), with AST-match highlighting via `GtBPatternHighlighter`.
- `BlockClosure >> #gtBPatternMatches` — a one-line entry point that turns a pattern block straight into a live, spawnable `GtSearchBPatternFilter` object in GT.

### Lepiter snippet

- Two experimental Lepiter snippets, kept side by side for comparison:
  - **"BPattern (code)"** (`LePharoBPatternSnippet`): built directly on GT's own `LePharoSnippet`, so it gets the real Pharo editor (completion, evaluation-error display) for free — its source is ordinary Pharo code (e.g. `[ anyVar isNil ifTrue: anyBlock ] bpattern`) that is evaluated on demand to get a `BPattern`/`BPatternRewrite` object, with the same scope row and always-enabled Search/Rewrite buttons.
  - **"BPattern (literal)"** (`LePharoBPatternLiteralSnippet`): a single Pharo source editor (syntax-highlighted, with Smalltalk-aware word selection/navigation) that structurally parses its own source — `[ pattern ]` or `[ [search] -> [replace] ]` — to decide between a plain search and a rewrite, with a "Search in:" scope filter row and Search/Replace buttons. *(Currently excluded from Spotter's "Add page with snippet" list and the Lepiter + insert-snippet menu — see `LePharoBPatternLiteralSnippet class >> #contextMenuItemSpecification`.)*
  - Both snippets delegate all search/rewrite execution to `BPattern`/`BPatternRewrite` themselves (see New API above) rather than implementing it twice, and both spawn their results — a search filter, or the rewritten `RBNamespace` once the async rewrite future resolves — via GT's own `spawnObject:`/`spawnFuture:` machinery, never blocking the UI.

### Lepiter database

- A `lepiter/` database (see [Installation](README.md#installation) in the README) with one page, **Getting started with BPatterns in GT**: runnable examples of building a `BPattern`/`BPatternRewrite`, searching and rewriting programmatically (with and without a scope filter), and the BPattern (code) snippet.
