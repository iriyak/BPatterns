Class {
	#name : 'LePharoBPatternLiteralSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'source',
		'scope'
	],
	#category : 'BPatterns-GToolkit-Extensions-Models',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Models'
}

{ #category : 'menu' }
LePharoBPatternLiteralSnippet class >> contextMenuItemSpecification [
	"<leSnippetSpecification> - temporarily disabled: excluded from Spotter's
	 'Add page with snippet' list and the Lepiter + insert-snippet menu. Re-enable
	 by uncommenting the pragma above."
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet class >> description [
	^ 'BPattern (literal)'
]

{ #category : 'instance creation' }
LePharoBPatternLiteralSnippet class >> empty [
	^ self new source: ''; scope: nil; yourself
]

{ #category : 'persistence' }
LePharoBPatternLiteralSnippet class >> leJsonV3AttributeMapping [
	^ super leJsonV3AttributeMapping
		add: #source -> #source;
		add: #scope -> #scope;
		yourself
]

{ #category : 'persistence' }
LePharoBPatternLiteralSnippet class >> leJsonV3Name [
	^ 'bpatternRewrite'
]

{ #category : 'persistence' }
LePharoBPatternLiteralSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #source -> #source;
		add: #scope -> #scope;
		yourself
]

{ #category : 'persistence' }
LePharoBPatternLiteralSnippet class >> leJsonV4Name [
	^ 'bpatternRewrite'
]

{ #category : 'converting' }
LePharoBPatternLiteralSnippet >> asSnippetViewModel [
	^ LePharoBPatternLiteralSnippetViewModel new snippetModel: self
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> bpattern [
	^ BPattern fromBlockAST: self searchBlockAST
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> bpatternRewrite [
	^ BPatternRewrite fromPattern: self bpattern to: self replacePattern
]

{ #category : 'testing' }
LePharoBPatternLiteralSnippet >> canMoveToAnotherDatabase [
	^ true
]

{ #category : 'converting' }
LePharoBPatternLiteralSnippet >> contentAsString [
	^ String
		streamContents: [ :stream |
			stream nextPutAll: (self isRewrite ifTrue: [ 'BPatternRewrite:' ] ifFalse: [ 'BPattern:' ]).
			stream
				nextPutAll: 'source=';
				print: (source ifNil: [ '' ]);
				nextPutAll: '|scope=';
				print: (scope ifNil: [ '' ]) ]
]

{ #category : 'executing' }
LePharoBPatternLiteralSnippet >> executeRewriteInFilter: aFilter [
	"Delegate to BPatternRewrite itself - answers a TAsyncFuture now (non-blocking), where
	 it used to build and return an RBNamespace synchronously."

	<return: #TAsyncFuture>
	^ self bpatternRewrite executeRewriteInFilter: aFilter
]

{ #category : 'executing' }
LePharoBPatternLiteralSnippet >> executeSearchInFilter: aFilter [
	"Delegate to BPattern itself - this is purely GT-integration plumbing now, not snippet
	 logic of its own."

	^ self bpattern executeSearchInFilter: aFilter
]

{ #category : 'scope' }
LePharoBPatternLiteralSnippet >> filterDescriptorNamesAndValuesDo: aBlock [
	(scope isNil or: [ scope isEmpty ]) ifTrue: [ ^ self ].
	scope first = $# ifFalse: [ ^ aBlock cull: scope cull: '' ].
	^ (RBParser parseExpression: scope) value
		do: [ :each |
			each isString
				ifTrue: [ aBlock cull: each cull: nil ]
				ifFalse: [ aBlock cull: each first cull: each second ] ]
]

{ #category : 'scope' }
LePharoBPatternLiteralSnippet >> filterDescriptorsUsing: snippetContext [
	| variableBindings descriptors variables |
	descriptors := GtSearchFilter globalFilterDescriptors.
	(snippetContext notNil and: [ snippetContext hasSelfObject ])
		ifTrue: [ (snippetContext selfObject isKindOf: GtSearchFilter)
				ifTrue: [ descriptors
						addFirst: (GtFilterDescriptor new
								valueNotRequired;
								creator: [ :value | snippetContext selfObject ];
								named: 'self';
								order: 0) ]
				ifFalse: [ descriptors
						addFirst: (GtFilterDescriptor new
								valueNotRequired;
								creator: [ :value |
									| cls |
									cls := snippetContext selfObject class instanceSide.
									cls gtMethodsInClass | cls class gtMethodsInClass ];
								named: snippetContext selfObject class instanceSide name;
								order: 0) ] ].
	variableBindings := snippetContext
			ifNil: [ GtSharedVariablesBindings new ]
			ifNotNil: [ :aContext | aContext sharedBindings ].
	variables := self allSnippetVariables
			select: [ :each |
				(variableBindings hasBindingOf: each asSymbol) not
					or: [ (variableBindings bindingOf: each asSymbol) value isKindOf: GtSearchFilter ] ].
	variables asSortedCollection
		reverseDo: [ :each |
			descriptors
				addFirst: (GtFilterDescriptor new
						valueNotRequired;
						creator: [ :value |
							((variableBindings bindingOf: each asSymbol) value
								ifNotNil: [ :obj | (obj isKindOf: GtSearchFilter) ifTrue: [ obj ] ])
								ifNil: [ self inform: each , ' is not a search filter. Using all methods instead.'.
									GtSearchImageMethodsFilter forAllMethods ] ];
						named: each;
						order: 0) ].
	^ descriptors
]

{ #category : 'testing' }
LePharoBPatternLiteralSnippet >> isRewrite [
	"Whether #source is structured as a rewrite ([ [search] -> [replace] ]) rather than a
	 plain search pattern ([ search ])."

	^ self rewriteMessageNode notNil
]

{ #category : 'printing' }
LePharoBPatternLiteralSnippet >> markdownOn: stream level: anInteger [
	anInteger * 4 timesRepeat: [ stream nextPut: Character space ].
	stream
		cr;
		<< '```';
		cr;
		<< self contentAsString trimBoth;
		cr;
		<< '```';
		cr.
	self
		childrenDo: [ :child |
			stream cr.
			child markdownOn: stream level: anInteger + 1 ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> parsedSourceNode [
	"Parse #source as a Pharo expression. Answer nil if it does not parse (e.g. mid-edit)."

	^ [ RBParser parseExpression: self source ] on: Error do: [ :e | nil ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> replaceBlockAST [
	"Only meaningful when #isRewrite; nil otherwise."

	^ self rewriteMessageNode ifNotNil: [ :node | node arguments first ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> replacePattern [
	"Only meaningful when #isRewrite."

	^ BPattern fromBlockAST: self replaceBlockAST
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> rewriteMessageNode [
	"If #source parses to [ [ search ] -> [ replace ] ], answer that -> RBMessageNode. Answer nil otherwise
	 (a plain search-only pattern, or unparseable source)."

	| node stmt |
	node := self parsedSourceNode.
	(node isNil or: [ node isBlock not ]) ifTrue: [ ^ nil ].
	node statements size = 1 ifFalse: [ ^ nil ].
	stmt := node statements first.
	(stmt isMessage and: [ stmt selector = #-> ]) ifFalse: [ ^ nil ].
	(stmt receiver isBlock and: [ stmt arguments first isBlock ]) ifFalse: [ ^ nil ].
	^ stmt
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> scope: aString [
	scope := aString.
	self
		notifyAnnouncement: (LePharoBPatternLiteralSnippetScopeChanged new
				source: self;
				snippet: self;
				scope: aString)
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> searchBlockAST [
	| rewriteNode |
	rewriteNode := self rewriteMessageNode.
	^ rewriteNode ifNil: [ self parsedSourceNode ] ifNotNil: [ rewriteNode receiver ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> source [
	^ source
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippet >> source: aString [
	source := aString.
	self announce: (LePharoBPatternLiteralSnippetSourceChanged new patternSource: aString)
]

{ #category : 'printing' }
LePharoBPatternLiteralSnippet >> storeOn: aStream [
	aStream nextPutAll: '(LePharoBPatternLiteralSnippet new source: '.
	self source storeOn: aStream.
	aStream nextPutAll: '; yourself)'
]
