"
I am the `LeSnippetElement` (view) for `LePharoBPatternLiteralSnippet`, by analogy with `LePharoRewriteSnippetElement`.

Unlike `LePharoRewriteSnippetElement`, I do *not* implement the backtick-pattern authoring context menu (""Match any message"", ""Rename variable"", ""Add statement"", ...): that whole apparatus is built around `GtPharoPatternParser`'s backtick meta-syntax (``@args``, ``.Stmt``, ...), which `BPattern` doesn't use - its search/replace fields hold ordinary Pharo block source, where `any`-prefixed names are already wildcards. So my two source editors are plain Pharo editors: I reuse `GtPharoStyler` (the ordinary Pharo AST styler, i.e. `GtPharoPatternStyler`'s own superclass minus the backtick-specific overrides) with `GtPharoParser`'s statement-sequence starting state, the same one `LePharoRewriteSnippetElement` itself resolves via `GtPharoParser startingStateForMethodSequence`. No completion strategy is wired up for now (v1); can be added later if useful.

I have no `isMethodPattern` toggle for the same reason the model doesn't: not supported yet.

One small, deliberate naming fix versus the original: `LePharoRewriteSnippetElement` has both an ivar *and* a same-named instance method called `rewriteElement` (the ivar is the whole widget tree; the method builds the async rewrite-preview widget spawned by the Replace button) - legal Smalltalk, but confusing to read. I renamed the method to `#rewritePreviewElement` to keep the two apart.

The Search button spawns `self snippet executeSearchInFilter: self searchFilter` directly as an object - since that is a `GtSearchBPatternFilter` (or an intersection with it), GT already renders it with the generic search-results view, using `GtSearchBPatternFilter>>#highlighter` (`GtBPatternHighlighter`) to highlight the matched region in each result - so match highlighting comes for free here, the same as it does in `BPattern>>#gtMatchesFor:`.

`contentElement` floats a small gray ""BPattern"" label in the top-right corner of the snippet, the same overlay technique `LeExternalEvaluatedSnippetElement>>#initializeLanguageElement` uses for its language/connection label (a `BrFrame` with the real content plus the label, the label constrained `alignRight`/`alignTop`). `#snippetContent` returns this frame; `rewriteElement` (the actual form) is still the widget everything else (editors, buttons, scope filters) is built into and looked up by name from. This exists purely so a BPattern rewrite snippet stays visually distinguishable from a Pharo Rewrite Snippet at a glance, since the two look otherwise near-identical.

"
Class {
	#name : 'LePharoBPatternLiteralSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'rewriteElement',
		'contentElement'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> createLabel: aString [
	^ BrLabel new
		text: aString asRopedText;
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize
				foreground: Color gray;
				fontSize: 12);
		yourself
]

{ #category : 'building' }
LePharoBPatternLiteralSnippetElement >> createSourceEditor: anUpdateSymbol [
	| element |
	element := BrEditor new.
	element vFitContent.
	element hMatchParent.
	element padding: (BlInsets all: 10).
	element
		aptitude: BrGlamorousCodeEditorAptitude + BrGlamorousEditableLabelAptitude.
	element editor
		styler: self styler;
		doubleClickWordClassifier: GtSmalltalkSourceCoder doubleClickClassifier;
		movementWordClassifier: GtSmalltalkSourceCoder wordMovementClassifier;
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
LePharoBPatternLiteralSnippetElement >> filterDescriptors [
	snippetViewModel ifNil: [ ^ GtSearchFilter globalFilterDescriptors ].
	^ self snippet filterDescriptorsUsing: self snippetContext
]

{ #category : 'initialization' }
LePharoBPatternLiteralSnippetElement >> initialize [
	| sourceEditor scopeElement filtersElement bpatternLabel buttonsRow |
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
	sourceEditor := self createSourceEditor: #updateSource.
	rewriteElement addChild: sourceEditor as: #sourceEditor.
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
				action: [ rewriteElement phlow
						spawnObject: (self snippet executeSearchInFilter: self searchFilter) ])
		as: #searchButton.
	buttonsRow
		addChild: (BrButton new
				beSmallSize;
				enabled: false;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons playinspect asElement;
				label: 'Replace' asString;
				action: [ rewriteElement phlow
						spawnFuture: (self snippet executeRewriteInFilter: self searchFilter) ])
		as: #replaceButton.
	rewriteElement addChild: buttonsRow.

	"Float a small 'BPattern' badge in the top-right corner, the same technique
	 LeExternalEvaluatedSnippetElement uses for its language/connection label,
	 so a BPattern rewrite snippet stays visually distinguishable from a Pharo
	 Rewrite Snippet at a glance, not just at insertion time."
	bpatternLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularSmallSize
			foreground: BrGlamorousColors textMarkupColor);
		margin: (BlInsets top: 5 right: 5);
		text: 'BPattern'.
	bpatternLabel constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignTop ].
	contentElement := BrFrame new
		hMatchParent;
		vFitContent;
		addChildren: { rewriteElement. bpatternLabel }
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateSourceEditor.
	self updateScope
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> saveScope [
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
LePharoBPatternLiteralSnippetElement >> scope [
	^ (snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> scopeLabel [
	^ ((snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ifNotNil: [ :scope | scope trim ifEmpty: [ nil ] ] ])
		ifNil: [ 'All methods' ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> searchFilter [
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
LePharoBPatternLiteralSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> snippetContext [
	snippetViewModel snippetsCollectionDo: [ :each | ^ each sharedSnippetContext ].
	^ nil
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> sourceEditorDo: block [
	rewriteElement childNamed: #sourceEditor ifFound: block
]

{ #category : 'styling' }
LePharoBPatternLiteralSnippetElement >> styler [
	| styler |
	styler := GtCompositeSmaCCASTStyler forParser: GtPharoParser.
	styler
		stylers: {(GtPharoStyler new
				coderViewModel: GtPharoSnippetCoderViewModel new;
				yourself)}.
	styler startingState: GtPharoParser startingStateForMethodSequence.
	^ styler
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel weak
		when: LePharoBPatternLiteralSnippetSourceChanged
			send: #updateSourceEditor
			to: self;
		when: LePharoBPatternLiteralSnippetScopeChanged
			send: #updateScope
			to: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel unsubscribe: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> updateReplaceButtonEnabled [
	"The Replace button only makes sense when #source parses as [ [search] -> [replace] ];
	 for a plain search pattern ([ search ]) there is nothing to replace with."

	rewriteElement
		childNamed: #replaceButton
		ifFound: [ :button | button enabled: self snippet isRewrite ]
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> updateScope [
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
LePharoBPatternLiteralSnippetElement >> updateSource [
	self
		sourceEditorDo: [ :editor |
			| sourceString |
			sourceString := editor editor text asString.
			sourceString ~= self snippet source
				ifTrue: [ self snippet source: sourceString ] ].
	self updateReplaceButtonEnabled
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetElement >> updateSourceEditor [
	rewriteElement
		childNamed: #sourceEditor
		ifFound: [ :editor |
			editor editor text asString ~= self snippet source
				ifTrue: [ editor editor text: self snippet source asRopedText ] ].
	self updateReplaceButtonEnabled
]
