Class {
	#name : 'LePharoBPatternRewriteSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'rewriteElement'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> createLabel: aString [
	^ BrLabel new
		text: aString asRopedText;
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize
				foreground: Color gray;
				fontSize: 12);
		yourself
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> createSourceEditor: anUpdateSymbol [
	| element |
	element := BrEditor new.
	element vFitContent.
	element hMatchParent.
	element padding: (BlInsets all: 10).
	element
		aptitude: BrGlamorousCodeEditorAptitude + BrGlamorousEditableLabelAptitude.
	element editor
		styler: self styler;
		when: BrTextEditorInsertedEvent do: [ :event | self perform: anUpdateSymbol ];
		when: BrTextEditorDeletedEvent do: [ :event | self perform: anUpdateSymbol ].
	LeSnippetEditorElementShortcuter new
		editor: element;
		indent;
		moveUpAndDown;
		loseFocus.
	^ element
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> filterDescriptors [
	snippetViewModel ifNil: [ ^ GtSearchFilter globalFilterDescriptors ].
	^ self snippet filterDescriptorsUsing: self snippetContext
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> initialize [
	| searchEditor replaceEditor scopeElement filtersElement |
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
	searchEditor := self createSourceEditor: #updateSearch.
	rewriteElement addChild: searchEditor as: #searchEditor.
	rewriteElement
		addChild: (BrButton new
				margin: (BlInsets top: 3 bottom: 10);
				beSmallSize;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect asElement;
				label: 'Search' asString;
				action: [ rewriteElement phlow
						spawnObject: (self snippet executeSearchInFilter: self searchFilter) ])
		as: #searchButton.
	rewriteElement addChild: (self createLabel: 'Replace with:').
	replaceEditor := self createSourceEditor: #updateReplace.
	rewriteElement addChild: replaceEditor as: #replaceEditor.
	rewriteElement
		addChild: (BrButton new
				margin: (BlInsets top: 3 bottom: 3);
				beSmallSize;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect asElement;
				label: 'Replace' asString;
				action: [ rewriteElement phlow
						spawnTool: (GtPhlowExplicitTool new stencil: [ self rewritePreviewElement ]) ])
		as: #replaceButton
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateSearchEditor.
	self updateReplaceEditor.
	self updateScope
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> replaceEditorDo: block [
	rewriteElement childNamed: #replaceEditor ifFound: block
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> rewritePreviewElement [
	| asyncElement |
	asyncElement := BrAsyncWidget new
			matchParent;
			stencil: [ GtInspector forObject: (self snippet executeRewriteInFilter: self searchFilter) ].
	^ asyncElement
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> saveScope [
	rewriteElement
		childNamed: #filtersElement
		ifFound: [ :filtersElement |
			self snippet
				scope: (String
						streamContents: [ :stream |
							stream nextPutAll: '#(' .
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

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> scope [
	^ (snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> scopeLabel [
	^ ((snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ifNotNil: [ :scope | scope trim ifEmpty: [ nil ] ] ])
		ifNil: [ 'All methods' ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> searchEditorDo: block [
	rewriteElement childNamed: #searchEditor ifFound: block
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> searchFilter [
	| filters |
	filters := OrderedCollection new.
	rewriteElement
		childNamed: #filtersElement
		ifFound: [ :filtersElement |
			filtersElement
				filtersDo: [ :descriptor :value | filters add: (descriptor newFilterWithValue: value) ] ].
	^ filters ifEmpty: [ nil ] ifNotEmpty: [ filters reduce: [ :a :b | a & b ] ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> snippetContent [
	^ rewriteElement
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> snippetContext [
	snippetViewModel snippetsCollectionDo: [ :each | ^ each sharedSnippetContext ].
	^ nil
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> styler [
	| styler |
	styler := GtCompositeSmaCCASTStyler forParser: GtPharoParser.
	styler stylers: { GtPharoStyler new }.
	styler startingState: GtPharoParser startingStateForMethodSequence.
	^ styler
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel weak
		when: LePharoBPatternRewriteSnippetSearchChanged
			send: #updateSearchEditor
			to: self;
		when: LePharoBPatternRewriteSnippetReplaceChanged
			send: #updateReplaceEditor
			to: self;
		when: LePharoBPatternRewriteSnippetScopeChanged
			send: #updateScope
			to: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel unsubscribe: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> updateReplace [
	self
		replaceEditorDo: [ :editor |
			| replaceString |
			replaceString := editor editor text asString.
			replaceString ~= self snippet replace
				ifTrue: [ self snippet replace: replaceString ] ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> updateReplaceEditor [
	rewriteElement
		childNamed: #replaceEditor
		ifFound: [ :editor |
			editor editor text asString ~= self snippet replace
				ifTrue: [ editor editor text: self snippet replace asRopedText ] ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> updateScope [
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

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> updateSearch [
	self
		searchEditorDo: [ :editor |
			| searchString |
			searchString := editor editor text asString.
			searchString ~= self snippet search
				ifTrue: [ self snippet search: searchString ] ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetElement >> updateSearchEditor [
	rewriteElement
		childNamed: #searchEditor
		ifFound: [ :editor |
			editor editor text asString ~= self snippet search
				ifTrue: [ editor editor text: self snippet search asRopedText ] ]
]
