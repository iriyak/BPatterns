"
I am the `LeSnippetElement` (view) for `LePharoBPatternLiteralSnippet`, by analogy with `LePharoRewriteSnippetElement`.

Unlike `LePharoRewriteSnippetElement`, I do *not* implement the backtick-pattern authoring context menu (""Match any message"", ""Rename variable"", ""Add statement"", ...): that whole apparatus is built around `GtPharoPatternParser`'s backtick meta-syntax (``@args``, ``.Stmt``, ...), which `BPattern` doesn't use - its source is ordinary Pharo block source, where `any`-prefixed names are already wildcards. So I have a single source editor, a plain Pharo editor: I reuse `GtPharoStyler` (the ordinary Pharo AST styler, i.e. `GtPharoPatternStyler`'s own superclass minus the backtick-specific overrides) with `GtPharoParser`'s statement-sequence starting state, the same one `LePharoRewriteSnippetElement` itself resolves via `GtPharoParser startingStateForMethodSequence`. That one editor holds either a plain search (`[ pattern ]`) or a rewrite (`[ [search] -> [replace] ]`); `LePharoBPatternLiteralSnippet>>#isRewrite` tells which, and the Replace button is only enabled for the latter (see `#updateReplaceButtonEnabled`). No completion strategy is wired up for now (v1); can be added later if useful.

I have no `isMethodPattern` toggle for the same reason the model doesn't: not supported yet.

My layout is: a ""Search in:"" scope-filter row (`GtFiltersElement`), the source editor, and a row with the Search and Replace buttons, all inside the `rewriteElement` widget tree (the form everything else is looked up from by name).

The Search button spawns `self snippet executeSearchInFilter: self searchFilter` directly as an object - since that is a `GtSearchBPatternFilter` (or an intersection with it), GT already renders it with the generic search-results view, using `GtSearchBPatternFilter>>#highlighter` (`GtBPatternHighlighter`) to highlight the matched region in each result - so match highlighting comes for free here, the same as it does for the inspector's Search button (`BPattern>>#gtSearchActionFor:`). The Replace button spawns `self snippet executeRewriteInFilter: self searchFilter` (a `TAsyncFuture` of the rewritten `RBNamespace`) via `spawnFuture:`.

`contentElement` floats a small gray ""BPattern"" label in the top-right corner of the snippet, the same overlay technique `LeExternalEvaluatedSnippetElement>>#initializeLanguageElement` uses for its language/connection label (a `BrFrame` with the real content plus the label, the label constrained `alignRight`/`alignTop`). `#snippetContent` returns this frame. This exists purely so a BPattern (literal) snippet stays visually distinguishable from a Pharo Rewrite Snippet at a glance, since the two look otherwise near-identical.

"
Class {
	#name : 'LePharoBPatternLiteralSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'rewriteElement',
		'contentElement'
	],
	#category : 'BPatterns-GToolkit-Extensions-Views',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Views'
}

{ #category : 'initialization' }
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

{ #category : 'accessing' }
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
	 so a BPattern (literal) snippet stays visually distinguishable from a Pharo
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

{ #category : 'api - snippet view model' }
LePharoBPatternLiteralSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateSourceEditor.
	self updateScope
]

{ #category : 'initialization' }
LePharoBPatternLiteralSnippetElement >> saveScope [
	"Store the ""Search in:"" filters as a literal-array string in the model's #scope (see
	 #filterDescriptorNamesAndValuesDo: for the format)."

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

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetElement >> scope [
	^ (snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetElement >> scopeLabel [
	^ ((snippetViewModel ifNotNil: [ self snippet ])
		ifNotNil: [ :snippet | snippet scope ifNotNil: [ :scope | scope trim ifEmpty: [ nil ] ] ])
		ifNil: [ 'All methods' ]
]

{ #category : 'initialization' }
LePharoBPatternLiteralSnippetElement >> searchFilter [
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

{ #category : 'api - view' }
LePharoBPatternLiteralSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'initialization' }
LePharoBPatternLiteralSnippetElement >> snippetContext [
	"Answer the shared snippet context of the page's snippets (used for `self` and variable
	 bindings), or nil."

	snippetViewModel snippetsCollectionDo: [ :each | ^ each sharedSnippetContext ].
	^ nil
]

{ #category : 'api - view' }
LePharoBPatternLiteralSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'private' }
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

{ #category : 'accessing' }
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

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel unsubscribe: self
]

{ #category : 'private' }
LePharoBPatternLiteralSnippetElement >> updateReplaceButtonEnabled [
	"The Replace button only makes sense when #source parses as [ [search] -> [replace] ];
	 for a plain search pattern ([ search ]) there is nothing to replace with."

	rewriteElement
		childNamed: #replaceButton
		ifFound: [ :button | button enabled: self snippet isRewrite ]
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetElement >> updateScope [
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

{ #category : 'private' }
LePharoBPatternLiteralSnippetElement >> updateSource [
	"Push the editor's text into the model when it differs, then refresh the Replace button."

	self
		sourceEditorDo: [ :editor |
			| sourceString |
			sourceString := editor editor text asString.
			sourceString ~= self snippet source
				ifTrue: [ self snippet source: sourceString ] ].
	self updateReplaceButtonEnabled
]

{ #category : 'api - snippet view model' }
LePharoBPatternLiteralSnippetElement >> updateSourceEditor [
	"Pull the model's source into the editor when it differs, then refresh the Replace
	 button."

	rewriteElement
		childNamed: #sourceEditor
		ifFound: [ :editor |
			editor editor text asString ~= self snippet source
				ifTrue: [ editor editor text: self snippet source asRopedText ] ].
	self updateReplaceButtonEnabled
]
