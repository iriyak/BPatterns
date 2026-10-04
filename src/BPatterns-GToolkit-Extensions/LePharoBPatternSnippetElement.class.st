"
I am the view of `LePharoBPatternSnippet`, a `LePharoSnippetElement` (so the Pharo editor and evaluation display are inherited). I add a ""Search in:"" scope-filter row and Search/Rewrite buttons: `#performSearch` evaluates the source and spawns the matching `GtSearchBPatternFilter` (a `BPatternRewrite` contributes its search pattern); `#performRewrite` spawns the async rewrite (a `TAsyncFuture` of an `RBNamespace`) via `spawnFuture:`. A failed evaluation goes to the Inspector; a result of the wrong type is just an `#inform:` notice. A small ""BPattern"" label floats in the top-right corner, as in `LePharoBPatternLiteralSnippetElement`.
"
Class {
	#name : 'LePharoBPatternSnippetElement',
	#superclass : 'LePharoSnippetElement',
	#instVars : [
		'rewriteElement',
		'contentElement'
	],
	#category : 'BPatterns-GToolkit-Extensions-Views',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Views'
}

{ #category : 'building' }
LePharoBPatternSnippetElement >> createLabel: aString [
	^ BrLabel new
		text: aString asRopedText;
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize
				foreground: Color gray;
				fontSize: 12);
		yourself
]

{ #category : 'scope' }
LePharoBPatternSnippetElement >> filterDescriptors [
	snippetViewModel ifNil: [ ^ GtSearchFilter globalFilterDescriptors ].
	^ self snippet filterDescriptorsUsing: self snippetContext
]

{ #category : 'initialization' }
LePharoBPatternSnippetElement >> initialize [
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
	 LePharoBPatternLiteralSnippetElement/LeExternalEvaluatedSnippetElement use."
	bpatternLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularSmallSize
			foreground: BrGlamorousColors textMarkupColor);
		margin: (BlInsets top: 5 right: 5);
		text: 'BPattern (code)'.
	bpatternLabel constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignTop ].
	contentElement := BrFrame new
		hMatchParent;
		vFitContent;
		addChildren: { rewriteElement. bpatternLabel }
]

{ #category : 'updating' }
LePharoBPatternSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateScope
]

{ #category : 'actions' }
LePharoBPatternSnippetElement >> performRewrite [
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
LePharoBPatternSnippetElement >> performSearch [
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
LePharoBPatternSnippetElement >> saveScope [
	"Store the ""Search in:"" filters as a literal-array string in the model's #scope (see
	 #filterDescriptorNamesAndValuesDo: for the format)."

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
LePharoBPatternSnippetElement >> scope [
	^ (snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ]
]

{ #category : 'accessing' }
LePharoBPatternSnippetElement >> scopeLabel [
	^ ((snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ifNotNil: [ :scope | scope trim ifEmpty: [ nil ] ] ])
		ifNil: [ 'All methods' ]
]

{ #category : 'scope' }
LePharoBPatternSnippetElement >> searchFilter [
	"Answer the intersection (&) of the filters currently chosen in the ""Search in:"" row,
	 or nil when there are none (meaning: search all methods)."

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
LePharoBPatternSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'accessing' }
LePharoBPatternSnippetElement >> snippetContext [
	snippetViewModel snippetsCollectionDo: [ :each | ^ each sharedSnippetContext ].
	^ nil
]

{ #category : 'subscriptions' }
LePharoBPatternSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel weak
		when: LePharoBPatternSnippetScopeChanged
			send: #updateScope
			to: self
]

{ #category : 'subscriptions' }
LePharoBPatternSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel unsubscribe: self
]

{ #category : 'scope' }
LePharoBPatternSnippetElement >> updateScope [
	"Rebuild the ""Search in:"" row from the model's #scope; if that leaves no filter, add
	 the first available descriptor so the row is never empty."

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
