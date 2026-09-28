Class {
	#name : 'LePharoBPatternRewriteSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'source',
		'scope'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> description [
	^ 'BPattern rewrite'
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> empty [
	^ self new source: ''; scope: nil; yourself
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> leJsonV3AttributeMapping [
	^ super leJsonV3AttributeMapping
		add: #source -> #source;
		add: #scope -> #scope;
		yourself
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> leJsonV3Name [
	^ 'bpatternRewrite'
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #source -> #source;
		add: #scope -> #scope;
		yourself
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> leJsonV4Name [
	^ 'bpatternRewrite'
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> asSnippetViewModel [
	^ LePharoBPatternRewriteSnippetViewModel new snippetModel: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> bpattern [
	^ BPattern fromBlockAST: self searchBlockAST
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> bpatternRewrite [
	^ BPatternRewrite fromPattern: self bpattern to: self replacePattern
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> canMoveToAnotherDatabase [
	^ true
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> contentAsString [
	^ String
		streamContents: [ :stream |
			stream nextPutAll: (self isRewrite ifTrue: [ 'BPatternRewrite:' ] ifFalse: [ 'BPattern:' ]).
			stream
				nextPutAll: 'source=';
				print: (source ifNil: [ '' ]);
				nextPutAll: '|scope=';
				print: (scope ifNil: [ '' ]) ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> executeRewriteInFilter: aFilter [
	| model rewrite |
	model := RBNamespace new.
	rewrite := self bpatternRewrite.
	(self potentialMethodsInFilter: aFilter)
		do: [ :each | (model classFor: each methodClass) compileTree: (rewrite rewriteMethod: each) ].
	^ model
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> executeSearchInFilter: aFilter [
	| bpatternFilter |
	bpatternFilter := GtSearchBPatternFilter bpattern: self bpattern.
	^ aFilter ifNil: [ bpatternFilter ] ifNotNil: [ aFilter & bpatternFilter ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> filterDescriptorNamesAndValuesDo: aBlock [
	(scope isNil or: [ scope isEmpty ]) ifTrue: [ ^ self ].
	scope first = $# ifFalse: [ ^ aBlock cull: scope cull: '' ].
	^ (RBParser parseExpression: scope) value
		do: [ :each |
			each isString
				ifTrue: [ aBlock cull: each cull: nil ]
				ifFalse: [ aBlock cull: each first cull: each second ] ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> filterDescriptorsUsing: snippetContext [
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

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> isRewrite [
	"Whether #source is structured as a rewrite ([ [search] -> [replace] ]) rather than a
	 plain search pattern ([ search ])."

	^ self rewriteMessageNode notNil
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> markdownOn: stream level: anInteger [
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

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> parsedSourceNode [
	"Parse #source as a Pharo expression. Answer nil if it does not parse (e.g. mid-edit)."

	^ [ RBParser parseExpression: self source ] on: Error do: [ :e | nil ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> potentialMethodsInFilter: aFilter [
	| scopeFilter |
	scopeFilter := (aFilter ifNil: [ GtSearchImageMethodsFilter forAllMethods ])
		select: [ :each | each isFromTrait not ].
	^ (scopeFilter & (GtSearchBPatternFilter bpattern: self bpattern)) contents
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> replaceBlockAST [
	"Only meaningful when #isRewrite; nil otherwise."

	^ self rewriteMessageNode ifNotNil: [ :node | node arguments first ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> replacePattern [
	"Only meaningful when #isRewrite."

	^ BPattern fromBlockAST: self replaceBlockAST
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> rewriteMessageNode [
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

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> scope [
	^ scope
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> scope: aString [
	scope := aString.
	self
		notifyAnnouncement: (LePharoBPatternRewriteSnippetScopeChanged new
				source: self;
				snippet: self;
				scope: aString)
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> searchBlockAST [
	| rewriteNode |
	rewriteNode := self rewriteMessageNode.
	^ rewriteNode ifNil: [ self parsedSourceNode ] ifNotNil: [ rewriteNode receiver ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> source [
	^ source
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> source: aString [
	source := aString.
	self announce: (LePharoBPatternRewriteSnippetSourceChanged new patternSource: aString)
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> storeOn: aStream [
	aStream nextPutAll: '(LePharoBPatternRewriteSnippet new source: '.
	self source storeOn: aStream.
	aStream nextPutAll: '; yourself)'
]
