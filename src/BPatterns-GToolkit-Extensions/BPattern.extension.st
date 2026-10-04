Extension { #name : 'BPattern' }

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> executeSearchInFilter: aFilter [
	"Answer a GtSearchBPatternFilter matching self within aFilter's scope (or all methods, if aFilter is nil), excluding Trait-composed methods (isFromTrait). This is the GT-integration counterpart to #scanAST:do: - matching within a filter's search scope rather than within a single, already-known AST.

	When a method is composed into a class from a Trait, the system installs one CompiledMethod per composing class, all sharing one origin (the Trait's own method). Excluding isFromTrait methods leaves one CompiledMethod per distinct <origin, selector> pair - each class's own methods plus each Trait's own canonical copy - the right notion of a location to edit, since editing a Trait's method once already propagates to every composing class. Verified live for one pattern: #users answered 497 distinct <methodClass, selector> pairs, 163 of them isFromTrait duplicates, leaving the 334 entries this search answers (same set as #uniqueUsers). Both counts are correct; they answer different questions (every installed method vs. every place the source differs)."

	| scopeFilter bpatternFilter |
	scopeFilter := (aFilter ifNil: [ GtSearchImageMethodsFilter forAllMethods ])
		select: [ :each | each isFromTrait not ].
	bpatternFilter := GtSearchBPatternFilter bpattern: self.
	^ scopeFilter & bpatternFilter
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
BPattern >> gtMetricsFor: aView [
	<gtView>
	^ aView forward
		title: 'Metrics';
		priority: 30;
		object: [ self executeSearchInFilter: nil ];
		view: #gtMetricsFor:
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> gtSearchActionFor: anAction [
	"Inspector button: spawn the GtSearchBPatternFilter for this pattern, searching all methods
	 (the inspector has no scope row, unlike the Lepiter snippets). Same call as the
	 snippets' Search button."

	<gtAction>
	^ anAction button
		priority: 10;
		label: 'Search';
		tooltip: 'Search all methods for this pattern';
		action: [ :aButton |
			aButton phlow spawnObject: (self executeSearchInFilter: nil) ]
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> gtSearchPatternFor: aView [
	<gtView>
	^ aView forward
		title: 'SearchPattern';
		priority: 10;
		object: [ self patternAST ];
		view: #gtTreeFor:
]

{ #category : '*BPatterns-GToolkit-Extensions' }
BPattern >> potentialMethodsInFilter: aFilter [
	"Answer a lazy async stream (GtAsyncSearchGroupStream) of the methods matching self within aFilter's scope (or all methods, if aFilter is nil) - not materialized into an Array, so a caller can chain #do:/#collect:/etc. and have items processed as they stream in. Trait-composed methods are excluded by #executeSearchInFilter: (see there), mirroring LePharoRewriteSnippet>>#potentialMethodsInFilter:, so a rewrite compiles one method per distinct <origin, selector> pair instead of one override per composing class."

	^ (self executeSearchInFilter: aFilter) asAsyncStream
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
