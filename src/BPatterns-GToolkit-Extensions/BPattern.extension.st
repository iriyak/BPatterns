Extension { #name : 'BPattern' }

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> executeSearchInFilter: aFilter [
	"Answer a GtSearchBPatternFilter matching self, intersected with aFilter when given.
	 This is the GT-integration counterpart to #scanAST:do: - matching within a filter's
	 search scope rather than within a single, already-known AST."

	| bpatternFilter |
	bpatternFilter := GtSearchBPatternFilter bpattern: self.
	^ aFilter ifNil: [ bpatternFilter ] ifNotNil: [ aFilter & bpatternFilter ]
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern class >> fromBlock: definitionBlock [
	"Answer a BPattern for the pattern written as definitionBlock (`[ ... ]`), taken from the
	 block's source."

	^ self fromBlockAST: definitionBlock sourceNode
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern class >> fromBlockAST: definitionAST [
	"Answer a BPattern from a block's AST: a single statement without temporaries is the
	 pattern itself; otherwise the whole block body is, as a sequence."

	| patternAST |
	patternAST := (definitionAST statements size == 1 and: [ definitionAST temporaries isEmpty ])
		ifTrue: [ definitionAST statements first ]
		ifFalse: [ definitionAST body ].
	^ self fromAST: patternAST
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> gtMatchesFor: aView [
	<gtView>
	^ aView forward
		title: 'Matches';
		priority: 30;
		object: [ GtSearchBPatternFilter bpattern: self ];
		view: #gtItemsFor:
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> gtMetricsFor: aView [
	<gtView>
	^ aView forward
		title: 'Metrics';
		priority: 40;
		object: [ GtSearchBPatternFilter bpattern: self ];
		view: #gtMetricsFor:
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> gtPatternASTFor: aView [
	<gtView>
	^ aView forward
		title: 'PatternAST';
		priority: 50;
		object: [ self patternAST ];
		view: #gtTreeFor:
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> potentialMethodsInFilter: aFilter [
	"Answer a lazy async stream (GtAsyncSearchGroupStream) of methods (excluding traits)
	 within aFilter's scope (or all methods, if aFilter is nil) that match self - not
	 materialized into an Array, so a caller can chain #do:/#collect:/etc. and have items
	 processed as they stream in, rather than waiting for the whole search to finish first.

	 Excludes isFromTrait methods (mirroring LePharoRewriteSnippet>>#potentialMethodsInFilter:'s
	 own identical filter): when a method is composed into a class from a Trait, the system
	 installs one CompiledMethod per composing class, but they all share one true origin (the
	 Trait's own method) - rewriting them individually would mean compiling N separate
	 per-class overrides of what is really a single piece of source, defeating the point of the
	 Trait. Excluding isFromTrait methods narrows the scope down to one CompiledMethod per
	 distinct <origin, selector> pair (each class's own methods, plus each Trait's own
	 canonical copy) - the right notion of 'location to edit' for a rewrite, since editing a
	 Trait's own method once already propagates to every composing class automatically.

	 This is a different notion of uniqueness than BPattern>>#users (which answers one
	 CompiledMethod per distinct <methodClass, selector> pair - every method actually
	 installed in the system, counting each Trait composition separately) answers - verified
	 live for one pattern, #users saw 497 distinct <methodClass, selector> pairs (no two
	 identical as such), of which 163 were isFromTrait duplicates sharing an origin with
	 another entry, collapsing to 334 distinct <origin, selector> pairs once deduplicated by
	 origin (matching #uniqueUsers and this method's own stream both in count and in the
	 exact set of entries). Both 497 and 334 are internally consistent and correct answers -
	 they just answer different questions (every installed method vs. every place the actual
	 source differs)."

	| scopeFilter |
	scopeFilter := (aFilter ifNil: [ GtSearchImageMethodsFilter forAllMethods ])
		select: [ :each | each isFromTrait not ].
	^ (self executeSearchInFilter: scopeFilter) asAsyncStream
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> uniqueUsers [
	"Like #users, but de-duplicated by origin: a method composed into many classes from one
	 Trait is answered once, as the Trait's own method (see #uniqueMethodsFrom:)."

	^ self uniqueMethodsFrom: self users
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> uniqueUsersInClass: aClass [
	"Like #usersInClass:, but de-duplicated by origin (see #uniqueUsers)."

	^ self uniqueMethodsFrom: (self usersInClass: aClass)
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> users [
	"Answer every method in the image that matches the pattern, found through GT's
	 search-filter framework: one result per distinct <methodClass, selector> pair, so
	 Trait-composed copies count separately (see #uniqueUsers)."

	^ (GtSearchBPatternFilter bpattern: self) contents
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> usersInClass: aClass [
	"Answer the matching methods of aClass and of its metaclass only."

	| scope |
	scope := (GtSearchMethodsInClassFilter forClass: aClass)
		| (GtSearchMethodsInClassFilter forClass: aClass class).
	^ (scope & (GtSearchBPatternFilter bpattern: self)) contents
]
