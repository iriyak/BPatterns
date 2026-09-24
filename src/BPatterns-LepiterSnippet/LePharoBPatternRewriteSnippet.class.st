Class {
	#name : 'LePharoBPatternRewriteSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'search',
		'replace',
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
	^ self new
		search: '';
		replace: '';
		scope: nil;
		yourself
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet class >> leJsonV3AttributeMapping [
	^ super leJsonV3AttributeMapping
		add: #search -> #search;
		add: #replace -> #replace;
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
		add: #search -> #search;
		add: #replace -> #replace;
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
	^ BPattern fromString: self search
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> bpatternRewrite [
	^ BPatternRewrite
		fromPattern: self bpattern
		to: (BPattern fromString: self replace)
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> canMoveToAnotherDatabase [
	^ true
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> contentAsString [
	^ String
		streamContents: [ :stream |
			stream nextPutAll: 'BPatternRewrite:'.
			stream
				nextPutAll: 'search=';
				print: (search ifNil: [ '' ]);
				nextPutAll: '|replace=';
				print: (replace ifNil: [ '' ]);
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
LePharoBPatternRewriteSnippet >> potentialMethodsInFilter: aFilter [
	| scopeFilter |
	scopeFilter := (aFilter ifNil: [ GtSearchImageMethodsFilter forAllMethods ])
		select: [ :each | each isFromTrait not ].
	^ (scopeFilter & (GtSearchBPatternFilter bpattern: self bpattern)) contents
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> replace [
	^ replace
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> replace: aString [
	replace := aString.
	self
		notifyAnnouncement: (LePharoBPatternRewriteSnippetReplaceChanged new
				source: self;
				snippet: self;
				replace: aString)
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
LePharoBPatternRewriteSnippet >> search [
	^ search
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> search: aString [
	search := aString.
	self
		notifyAnnouncement: (LePharoBPatternRewriteSnippetSearchChanged new
				source: self;
				snippet: self;
				search: aString)
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippet >> storeOn: aStream [
	aStream nextPutAll: '(LePharoBPatternRewriteSnippet new search: '.
	self search storeOn: aStream.
	aStream nextPutAll: '; replace: '.
	self replace storeOn: aStream.
	aStream nextPutAll: '; yourself)'
]
