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

- `BPattern class >> #fromString:` builds a `BPattern` directly from a source string (in addition to the existing `#fromBlock:`).
- `BPattern >> #uniqueUsers` / `#uniqueUsersInClass:` return matching methods de-duplicated by origin, so a method shared across a class and the traits/subclasses that use it is only reported once.
- `BPattern >> #users` / `#usersInClass:` are re-implemented on top of GT's own search-filter framework (`GtSearchBPatternFilter`) instead of a manual `Smalltalk allClasses` scan.

**New GT views and tools**

- `BPattern` gets three new inspector tabs: **Matches**, **Metrics**, and **PatternAST**.
- `GtSearchBPatternFilter` — a `GtSearchMethodsFilter` that lets a `BPattern` be composed into GT's search/scope pipeline (`&`, `|`, class/package scoping, etc.), with AST-match highlighting via `GtBPatternHighlighter`.
- `String >> #gtBPatternMatches` and `BlockClosure >> #gtBPatternMatches` — one-line entry points that turn a pattern string or block straight into a live, spawnable `GtSearchBPatternFilter` object in GT.
- A new **"BPattern rewrite" Lepiter snippet**: insert it into any Lepiter page to author a search/replace/scope BPattern rewrite right in your notes, run the search with the same highlighting as above, and preview the rewrite as a diff before applying it.
- A `lepiter/` booklet (see Installation above) with development notes and a live demo of the snippet.

## Reference

- [Original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md) — BPattern basics, pattern configuration (variable/global/literal/selector patterns), `#bmethod`, `#brewrite`.
- [Original repository](https://github.com/dionisiydk/BPatterns)
- [This fork](https://github.com/iriyak/BPatterns)

## License

MIT License. Original work Copyright (c) 2025 [Denis Kudriashov](https://github.com/dionisiydk); fork additions Copyright (c) 2026 Kazunori Iriya. See [LICENSE](LICENSE) for the full text.
