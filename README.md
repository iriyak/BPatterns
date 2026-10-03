# BPatterns (GT-adapted fork)

This is [Iriya](https://github.com/iriyak)'s fork of [dionisiydk/BPatterns](https://github.com/dionisiydk/BPatterns), adapted for and tested in [Glamorous Toolkit (GT)](https://gtoolkit.com/). It keeps the original scripting/search/rewrite API intact and adds a GT-native search, inspection, and Lepiter-notebook integration layer on top of it.

For the full description of BPatterns itself (what a `BPattern` is, pattern configuration, `#bmethod`/`#brewrite`, etc.), see the **[original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md)** — this document only covers what's different in this fork.

## Installation

```Smalltalk
Metacello new
  baseline: 'BPatterns';
  repository: 'github://iriyak/BPatterns:main';
  load
```

To load only the core (without the GT integration or Lepiter snippet packages), load the `'Core'`/`'CoreTests'` groups explicitly:

```Smalltalk
Metacello new
  baseline: 'BPatterns';
  repository: 'github://iriyak/BPatterns:main';
  load: #('Core' 'CoreTests')
```

This repository also ships a Lepiter booklet under `lepiter/` (development notes, and a live "BPattern rewrite" snippet demo — see below). Once the project is loaded via Iceberg, register it with your Lepiter database and open it from GT's Lepiter browser:

```Smalltalk
#BaselineOfBPatterns asClass loadLepiter
```

## Overview — changes in this fork

This fork was adapted to run on GT, and adds GT-specific tooling around the same `BPattern`/`BPatternRewrite` API described in the original README.

**Breaking changes**

- The pattern engine now builds on Pharo's `RB*` (RefactoringBrowser) AST/searcher classes instead of `OC*` (OpenChain), to match what GT itself uses.

**New API**

- `BPattern >> #uniqueUsers` / `#uniqueUsersInClass:` return matching methods de-duplicated by origin (`<origin, selector>`), so a method composed into many classes from a single Trait is only reported once — as opposed to `#users`/`#usersInClass:`, which answer one result per distinct `<methodClass, selector>` pair (every method actually installed in the system, including one per Trait composition). Both are correct; they just answer different questions.
- `BPattern >> #users` / `#usersInClass:` are re-implemented on top of GT's own search-filter framework (`GtSearchBPatternFilter`) instead of a manual `Smalltalk allClasses` scan.
- `BPattern >> #executeSearchInFilter:` and `BPattern >> #potentialMethodsInFilter:` expose the search as GT-integration building blocks: the former composes a `GtSearchBPatternFilter` into a given search scope (used directly by `#gtMatchesFor:` and both Lepiter snippets below); the latter narrows that down to a lazy async stream of candidate methods — excluding Trait-composed methods, for the same `<origin, selector>` reason as `#uniqueUsers` above — for `BPatternRewrite` to rewrite.
- `BPatternRewrite >> #executeRewriteInFilter:` streams candidates from `#potentialMethodsInFilter:` and compiles each rewritten method as it arrives, answering a `TAsyncFuture` of the resulting `RBNamespace` — fully non-blocking end to end, mirroring `LePharoRewriteSnippet`'s own async design.

**New GT views and tools**

- `BPattern` gets three new inspector tabs: **Matches**, **Metrics**, and **PatternAST**.
- `GtSearchBPatternFilter` — a `GtSearchMethodsFilter` that lets a `BPattern` be composed into GT's search/scope pipeline (`&`, `|`, class/package scoping, etc.), with AST-match highlighting via `GtBPatternHighlighter`.
- `BlockClosure >> #gtBPatternMatches` — a one-line entry point that turns a pattern block straight into a live, spawnable `GtSearchBPatternFilter` object in GT.
- Two experimental Lepiter snippets, kept side by side for comparison:
  - **"BPattern rewrite"** (`LePharoBPatternRewriteSnippet`): a single Pharo source editor (syntax-highlighted, with Smalltalk-aware word selection/navigation) that structurally parses its own source — `[ pattern ]` or `[ [search] -> [replace] ]` — to decide between a plain search and a rewrite, with a "Search in:" scope filter row and Search/Replace buttons.
  - **"BPattern (evaluated)"** (`LePharoBPatternSnippet2`): built directly on GT's own `LePharoSnippet`, so it gets the real Pharo editor (completion, evaluation-error display) for free — its source is ordinary Pharo code (e.g. `[ anyVar isNil ifTrue: anyBlock ] bpattern`) that is evaluated on demand to get a `BPattern`/`BPatternRewrite` object, with the same scope row and always-enabled Search/Rewrite buttons.
  - Both snippets delegate all search/rewrite execution to `BPattern`/`BPatternRewrite` themselves (see New API above) rather than implementing it twice, and both spawn their results — a search filter, or the rewritten `RBNamespace` once the async rewrite future resolves — via GT's own `spawnObject:`/`spawnFuture:` machinery, never blocking the UI.
- A `lepiter/` booklet (see Installation above) with development notes and a live demo of both snippets.

## Reference

- [Original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md) — BPattern basics, pattern configuration (variable/global/literal/selector patterns), `#bmethod`, `#brewrite`.
- [Original repository](https://github.com/dionisiydk/BPatterns)
- [This fork](https://github.com/iriyak/BPatterns)

## License

MIT License. Original work Copyright (c) 2025 [Denis Kudriashov](https://github.com/dionisiydk); fork additions Copyright (c) 2026 Kazunori Iriya. See [LICENSE](LICENSE) for the full text.
