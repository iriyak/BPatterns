Extension { #name : 'BPatternRewrite' }

{ #category : '*BPatterns-GToolkit-Extensions' }
BPatternRewrite >> executeRewriteInFilter: aFilter [
	"Answer a TAsyncFuture of an RBNamespace with every method within aFilter's scope
	 (or all methods, if aFilter is nil) that matches #searchPattern rewritten. Streams
	 candidates in from #potentialMethodsInFilter: and rewrites/compiles each one as it
	 arrives, rather than waiting for the whole search to finish before rewriting anything -
	 the GT-integration counterpart to #rewriteMethod:, by analogy with
	 LePharoRewriteSnippet>>#executeRewriteInFilter:. Unlike that original, a failure
	 anywhere in the stream is left to propagate as the future's own failure (instead of
	 being caught and turned into a successful value) and #then: (not #await/#otherwise:)
	 is used throughout, so the result stays a genuine TAsyncFuture end to end - callers use
	 #spawnFuture:, which already surfaces a failed future as a GT notification on its own,
	 and #spawnFuture: requires a TAsyncFuture, not a TAsyncPromise (what #await would
	 have produced)."

	<return: #TAsyncFuture>
	| model |
	model := RBNamespace new.
	^ ((self searchPattern potentialMethodsInFilter: aFilter)
		do: [ :each | (model classFor: each methodClass) compileTree: (self rewriteMethod: each) ])
		then: [ :ignored | model ]
]
