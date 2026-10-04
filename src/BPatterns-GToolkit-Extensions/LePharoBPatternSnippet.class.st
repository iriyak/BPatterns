"
I am a Lepiter snippet built on GT's own `LePharoSnippet`, so I get the real Pharo editor (completion, evaluation-error display) for free. My source is ordinary Pharo code - e.g. `[ anyVar isNil ifTrue: anyBlock ] bpattern` - that is evaluated on demand (`#evaluateThenDo:`) to a `BPattern` or `BPatternRewrite`; the Search and Rewrite buttons of `LePharoBPatternSnippetElement` work on that value. (Compare `LePharoBPatternLiteralSnippet`, whose source is only parsed, never evaluated.)

`scope` holds the ""Search in:"" filters as a string; `#filterDescriptorsUsing:` also offers the context's `self` and the snippet's variables as scope filters. Both `scope` and the source are persisted (JSON type name `bpatternSnippet2`, kept from this class's earlier name so existing pages still load).
"
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
	"Evaluate aBlock with the name and value (nil when there is none) of each ""Search in:""
	 filter stored in #scope. A scope that does not start with `#` is a single filter name;
	 otherwise it is the literal array written by the element's #saveScope, of names and
	 (name value) pairs."

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
	"Answer the filter descriptors offered by the ""Search in:"" row: GT's global descriptors
	 and, in front of them, the snippet context's `self` object (as a filter when it is one,
	 else its class's methods) and the snippet's variables that are unbound or hold search
	 filters."

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
