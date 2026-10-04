# BPatterns (GT-adapted fork)

This is a fork of [dionisiydk/BPatterns](https://github.com/dionisiydk/BPatterns), adapted for and tested in [Glamorous Toolkit (GT)](https://gtoolkit.com/) by [Kazunori Iriya](https://github.com/iriyak).  It keeps the original scripting/search/rewrite API intact and adds a GT-native search, inspection, and Lepiter-notebook integration layer on top of it.

For the full description of BPatterns itself (what a `BPattern` is, pattern configuration, `#bmethod`/`#brewrite`, etc.), see the **[original README](https://github.com/dionisiydk/BPatterns/blob/main/README.md)** — this document only covers what's different in this fork.

## Installation

```Smalltalk
Metacello new
  baseline: 'BPatterns';
  repository: 'github://iriyak/BPatterns:main';
  load
```

Once the project is loaded via Iceberg, register it with your Lepiter database and open the page from GT's Lepiter browser:

```Smalltalk
#BaselineOfBPatterns asClass loadLepiter
```

## Getting Started

This repository ships a Lepiter database under `lepiter/` with one page, **Getting started with BPatterns in GT**: runnable examples of building a `BPattern`/`BPatternRewrite`, searching and rewriting programmatically, and using the BPattern (code) snippet. 

## API and Additions

This fork keeps the original `BPattern`/`BPatternRewrite` API intact and adds:

- `BPattern >> #uniqueUsers` / `#uniqueUsersInClass:` in addition to `#users` / `#usersInClass:` — search for methods matching the pattern.
- `BPattern >> #executeSearchInFilter:` / `#potentialMethodsInFilter:` and `BPatternRewrite >> #executeRewriteInFilter:` — async, GT-search-scope-integrated search/rewrite (Trait-composed copies of a method are reported once, as in `#uniqueUsers`).
- `GtSearchBPatternFilter` and `BlockClosure >> #gtBPatternMatches` — compose a pattern into GT's search/scope pipeline.
- Two Lepiter snippets for interactive search/rewrite: `LePharoBPatternLiteralSnippet` and `LePharoBPatternSnippet`.
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