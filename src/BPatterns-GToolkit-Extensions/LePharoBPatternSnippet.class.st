Class {
	#name : 'LePharoBPatternSnippet',
	#superclass : 'LePharoSnippet',
	#instVars : [
		'scope'
	],
	#category : 'BPatterns-GToolkit-Extensions-Models',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Models'
}

{ #category : 'menu' }
LePharoBPatternSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'accessing' }
LePharoBPatternSnippet class >> description [
	^ 'BPattern (code)'
]

{ #category : 'persistence' }
LePharoBPatternSnippet class >> leJsonV3AttributeMapping [
	^ super leJsonV3AttributeMapping
		add: #scope -> #scope;
		yourself
]

{ #category : 'persistence' }
LePharoBPatternSnippet class >> leJsonV3Name [
	^ 'bpatternSnippet2'
]

{ #category : 'persistence' }
LePharoBPatternSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #scope -> #scope;
		yourself
]

{ #category : 'persistence' }
LePharoBPatternSnippet class >> leJsonV4Name [
	^ 'bpatternSnippet2'
]

{ #category : 'converting' }
LePharoBPatternSnippet >> asSnippetViewModel [
	^ LePharoBPatternSnippetViewModel new snippetModel: self
]

{ #category : 'evaluating' }
LePharoBPatternSnippet >> evaluateThenDo: aBlock [
	"Evaluate #code in my coder's context and pass the GtSourceCoderEvaluationResult to aBlock.
	 Keeps the coder/code plumbing private to the model - callers (the Element's buttons) only
	 ever see the result."

	^ self coder evaluate: self code thenDo: aBlock
]

{ #category : 'scope' }
LePharoBPatternSnippet >> filterDescriptorNamesAndValuesDo: aBlock [
	(scope isNil or: [ scope isEmpty ]) ifTrue: [ ^ self ].
	scope first = $# ifFalse: [ ^ aBlock cull: scope cull: '' ].
	^ (RBParser parseExpression: scope) value
		do: [ :each |
			each isString
				ifTrue: [ aBlock cull: each cull: nil ]
				ifFalse: [ aBlock cull: each first cull: each second ] ]
]

{ #category : 'scope' }
LePharoBPatternSnippet >> filterDescriptorsUsing: snippetContext [
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

{ #category : 'accessing' }
LePharoBPatternSnippet >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternSnippet >> scope: aString [
	scope := aString.
	self
		notifyAnnouncement: (LePharoBPatternSnippetScopeChanged new
				source: self;
				snippet: self;
				scope: aString)
]
