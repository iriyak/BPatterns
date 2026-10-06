# BPatterns for Glamorous Toolkit

This is a fork of [dionisiydk/BPatterns](https://github.com/dionisiydk/BPatterns), adapted for and tested in [Glamorous Toolkit (GT)](https://gtoolkit.com/) by [Kazunori Iriya](https://github.com/iriyak).  It keeps the original scripting/search/rewrite API intact and adds a GT-native search, inspection, and Lepiter-notebook integration layer on top of it.

See the **[original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md)** for the full description of BPatterns itself (what a `BPattern` is, pattern configuration, `#bmethod`/`#brewrite`, etc.); this document only covers what's different in this fork.

## Installation

Load it into a Glamorous Toolkit image: the default group includes `BPatterns-GToolkit-Extensions`, which depends on GT.

```Smalltalk
Metacello new
  baseline: 'BPatterns';
  repository: 'github://iriyak/BPatterns:main';
  load
```

Register the `lepiter/` database with your Lepiter database and open the page from GT's Lepiter browser, once the project is loaded into Iceberg as `BPatterns` (`loadLepiter` looks the repository up by that name):

```Smalltalk
#BaselineOfBPatterns asClass loadLepiter
```

## Getting Started

Evaluate the snippet below to look up **Getting started with BPatterns in GT**, a page of runnable examples showing how to build a `BPattern`/`BPatternRewrite`, search and rewrite programmatically, and use the BPattern (code) snippet.

```Smalltalk
aDatabaseName := 'iriyak/BPatterns/lepiter'.
aDatabase := LeDatabasesRegistry defaultLogicalDatabase databases
		detect: [ :each | (each databaseName copyReplaceAll: '\' with: '/') = aDatabaseName ].
aPage := aDatabase pageNamed: 'Getting started with BPatterns in GT'
```

## API and Additions

This fork keeps the original `BPattern`/`BPatternRewrite` API intact and adds:

- `BPattern >> #uniqueUsers` / `#uniqueUsersInClass:` in addition to `#users` / `#usersInClass:` — search for methods matching the pattern.
- `BPattern >> #executeSearchInFilter:` / `#potentialMethodsInFilter:` and `BPatternRewrite >> #executeRewriteInFilter:` — async, GT-search-scope-integrated search/rewrite (Trait-composed copies of a method are reported once, as in `#uniqueUsers`).
- `GtSearchBPatternFilter` and `BlockClosure >> #gtBPatternMatches` — compose a pattern into GT's search/scope pipeline.
- Two Lepiter snippets for interactive search/rewrite: **BPattern (code)** (`LePharoBPatternSnippet`) and **BPattern (literal)** (`LePharoBPatternLiteralSnippet`, currently hidden from the insert menus).
- Inspector additions: `BPattern` gets **SearchPattern** and **Metrics** tabs and a **Search** button; `BPatternRewrite` gets **SearchPattern**, **RewritePattern** and **Metrics** tabs and **Search** and **Rewrite** buttons (the buttons do the same as the Lepiter snippets' buttons, over all methods).

See [Implementation notes](IMPLEMENTATION_NOTES.md) for how and why each of these was added, including a breaking change to the underlying AST classes. 

## Reference

- [Original Repository](https://github.com/dionisiydk/BPatterns)
- [Original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md)

## License

MIT License.
```
Copyright (c) 2025 Denis Kudriashov
Copyright (c) 2026 Kazunori Iriya (fork additions)
```
See [LICENSE](LICENSE) for the full text.