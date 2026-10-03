Class {
	#name : 'LePharoBPatternSnippet2Element',
	#superclass : 'LePharoSnippetElement',
	#instVars : [
		'rewriteElement',
		'contentElement'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'building' }
LePharoBPatternSnippet2Element >> createLabel: aString [
	^ BrLabel new
		text: aString asRopedText;
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize
				foreground: Color gray;
				fontSize: 12);
		yourself
]

{ #category : 'scope' }
LePharoBPatternSnippet2Element >> filterDescriptors [
	snippetViewModel ifNil: [ ^ GtSearchFilter globalFilterDescriptors ].
	^ self snippet filterDescriptorsUsing: self snippetContext
]

{ #category : 'initialization' }
LePharoBPatternSnippet2Element >> initialize [
	| scopeElement filtersElement buttonsRow bpatternLabel |
	super initialize.

	rewriteElement := BrVerticalPane new.
	rewriteElement padding: (BlInsets all: 5).
	rewriteElement vFitContent.
	rewriteElement hMatchParent.

	scopeElement := BrHorizontalPane new.
	scopeElement hMatchParent.
	scopeElement vFitContent.
	scopeElement margin: (BlInsets bottom: 2).
	scopeElement
		addChild: ((self createLabel: 'Search in:') margin: (BlInsets top: 5)).
	filtersElement := GtFiltersElement new.
	filtersElement hFitContent.
	filtersElement descriptors: [ self filterDescriptors ].
	filtersElement when: GtFiltersChangedEvent do: [ :event | self saveScope ].
	scopeElement addChild: filtersElement as: #filtersElement.
	rewriteElement addChild: scopeElement.

	rewriteElement addChild: super snippetContent.

	buttonsRow := BrHorizontalPane new.
	buttonsRow hFitContent.
	buttonsRow vFitContent.
	buttonsRow margin: (BlInsets top: 3 bottom: 3).
	buttonsRow
		addChild: (BrButton new
				margin: (BlInsets right: 5);
				beSmallSize;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect asElement;
				label: 'Search' asString;
				action: [ self performSearch ])
		as: #searchButton.
	buttonsRow
		addChild: (BrButton new
				beSmallSize;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect asElement;
				label: 'Rewrite' asString;
				action: [ self performRewrite ])
		as: #rewriteButton.
	rewriteElement addChild: buttonsRow.

	"Float a small 'BPattern' badge in the top-right corner, same technique as
	 LePharoBPatternRewriteSnippetElement/LeExternalEvaluatedSnippetElement use."
	bpatternLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularSmallSize
			foreground: BrGlamorousColors textMarkupColor);
		margin: (BlInsets top: 5 right: 5);
		text: 'BPattern (eval)'.
	bpatternLabel constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignTop ].
	contentElement := BrFrame new
		hMatchParent;
		vFitContent;
		addChildren: { rewriteElement. bpatternLabel }
]

{ #category : 'updating' }
LePharoBPatternSnippet2Element >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateScope
]

{ #category : 'actions' }
LePharoBPatternSnippet2Element >> performRewrite [
	"Evaluate the snippet's source and, if it is a BPatternRewrite, spawn the executed
	 rewrite (a TAsyncFuture of an RBNamespace with the rewritten classes) - non-blocking
	 end to end via #spawnFuture:. An evaluation failure goes to the Inspector (worth
	 inspecting); anything else that is not a BPatternRewrite is just a precondition notice
	 via #inform:, not an error."

	self snippet
		evaluateThenDo: [ :result |
			result isSuccess
				ifTrue: [ | value |
					value := result value.
					(value isKindOf: BPatternRewrite)
						ifTrue: [ self phlow spawnFuture: (value executeRewriteInFilter: self searchFilter) ]
						ifFalse: [ self inform: 'Source evaluates to a plain BPattern (no replace pattern) - nothing to rewrite: ' , value printString ] ]
				ifFalse: [ self phlow spawnObject: result ] ]
]

{ #category : 'actions' }
LePharoBPatternSnippet2Element >> performSearch [
	"Evaluate the snippet's source and, if it is a BPattern (or a BPatternRewrite - use its
	 #searchPattern), spawn the matching GtSearchBPatternFilter. An evaluation failure is
	 worth inspecting (stack trace etc.), so that goes to the Inspector; a type mismatch is
	 just a precondition notice, so that goes through #inform: instead."

	self snippet
		evaluateThenDo: [ :result |
			result isSuccess
				ifTrue: [ | value |
					value := result value.
					(value isKindOf: BPatternRewrite)
						ifTrue: [ self phlow spawnObject: (value searchPattern executeSearchInFilter: self searchFilter) ]
						ifFalse: [ (value isKindOf: BPattern)
								ifTrue: [ self phlow spawnObject: (value executeSearchInFilter: self searchFilter) ]
								ifFalse: [ self inform: 'Source does not evaluate to a BPattern or BPatternRewrite: ' , value printString ] ] ]
				ifFalse: [ self phlow spawnObject: result ] ]
]

{ #category : 'scope' }
LePharoBPatternSnippet2Element >> saveScope [
	rewriteElement
		childNamed: #filtersElement
		ifFound: [ :filtersElement |
			self snippet
				scope: (String
						streamContents: [ :stream |
							stream nextPutAll: '#('.
							filtersElement
								filtersDo: [ :descriptor :value |
									value
										ifNil: [ stream store: descriptor name ]
										ifNotNil: [ stream
												nextPutAll: '#(';
												store: descriptor name;
												space;
												store: value;
												nextPut: $) ].
									stream space ].
							stream nextPut: $) ]) ]
]

{ #category : 'accessing' }
LePharoBPatternSnippet2Element >> scope [
	^ (snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ]
]

{ #category : 'accessing' }
LePharoBPatternSnippet2Element >> scopeLabel [
	^ ((snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ifNotNil: [ :scope | scope trim ifEmpty: [ nil ] ] ])
		ifNil: [ 'All methods' ]
]

{ #category : 'scope' }
LePharoBPatternSnippet2Element >> searchFilter [
	| filters |
	filters := OrderedCollection new.
	rewriteElement
		childNamed: #filtersElement
		ifFound: [ :filtersElement |
			filtersElement
				filtersDo: [ :descriptor :value | filters add: (descriptor newFilterWithValue: value) ] ].
	^ filters ifEmpty: [ nil ] ifNotEmpty: [ filters reduce: [ :a :b | a & b ] ]
]

{ #category : 'accessing' }
LePharoBPatternSnippet2Element >> snippetContent [
	^ contentElement
]

{ #category : 'accessing' }
LePharoBPatternSnippet2Element >> snippetContext [
	snippetViewModel snippetsCollectionDo: [ :each | ^ each sharedSnippetContext ].
	^ nil
]

{ #category : 'subscriptions' }
LePharoBPatternSnippet2Element >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel weak
		when: LePharoBPatternSnippet2ScopeChanged
			send: #updateScope
			to: self
]

{ #category : 'subscriptions' }
LePharoBPatternSnippet2Element >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel unsubscribe: self
]

{ #category : 'scope' }
LePharoBPatternSnippet2Element >> updateScope [
	rewriteElement
		childNamed: #filtersElement
		ifFound: [ :filtersElement |
			| descriptors |
			descriptors := self filterDescriptors.
			filtersElement clearFilters.
			self snippet
				filterDescriptorNamesAndValuesDo: [ :name :value |
					(descriptors detect: [ :each | each name = name ] ifNone: [  ])
						ifNotNil: [ :descriptor | filtersElement addFilterForDescriptor: descriptor andValue: value ] ].
			(filtersElement currentFilters isEmpty and: [ descriptors notEmpty ])
				ifTrue: [ filtersElement addFilterForDescriptor: descriptors first andValue: '' ] ]
]
