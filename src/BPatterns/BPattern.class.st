"
I represent an AST pattern which can be matched against AST nodes.
My instances are created from a pattern block using **#bpattern** message:

```
	| any anyBlock |
	[ any isNil ifTrue: anyBlock ] bpattern
```

Once you have a `BPattern` you can browse the system to find all matching methods:

```
	| any any2 |
	[ any isNil ifTrue: any2 ] bpattern browseUsers.
```

```
	| any |
	[ any printString asString ] bpattern browseUsersInClass: BPatternMethodQueryTest.
```

Using two BPatterns you can rewrite the matching methods:

```
	| any |
	[ 
		[ any printString asString ] -> [ any printString ] 
	] brewrite previewForClass: BPatternMethodQueryTest
```

The variables and selectors inside the pattern block can be used as a pattern to match particular AST nodes.
By default the following objects are automatically configured as **ANY** pattern to match any AST node:
- variables started with **any** word
- selectors where a keyword is started with **any** word

To narrow the filter represented by a pattern you have to configure it using **#with:** message:

```
	| anyVar anyBlock |
	[ anyVar isNil ifTrue: anyBlock ] bpattern with: [ anyVar ] -> [:pattern | pattern beVariable ]
```

See the package comment for the full details about the pattern configuration.

Internally I construct #patternAST using AST pattern nodes from the rewrite engine. 
I use BPatternASTBuilder to process the given AST where its nodes are replaced with the configured pattern nodes. My #configs list defines which nodes will be converted to the patterns and how they will behave. 
I am created with two initial configs: `BPatternDefaultVarConfig` and `BPatternDefaultSelectorConfig`.
They bring the default patterns - the nodes containing the **any** prefix word. Default patterns behave as a wider filter possible and to narrow it you have to provide an another set of configs using #with: message.
The pattern AST is built lazily when the pattern is actually being used for a search or a rewrite. Therefore the configuration can be applied many times before the first use.

I implement the following API:

- code search:

```
bpattern scanAST: anAST do: [:matchingNode :matchingVars | ]
```

I executes given block with every node fully matching the entire pattern where the matching vars is a dictionary mapping the pattern var names with the matching nodes they represent.

- code rewrite:

```
rewrittenAST := bpattern rewriteAST: anAST with: replaceBPattern
```

- maching nodes:

```
bpattern matchesAST: anAST.

bpattern matchesMethod: aMethod
```

"
Class {
	#name : 'BPattern',
	#superclass : 'Object',
	#instVars : [
		'patternAST',
		'configs',
		'isConfigured',
		'constantSelectors'
	],
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'instance creation' }
BPattern class >> fromAST: anASTNode [ 
	^self new 
		patternAST: anASTNode
]

{ #category : 'comparing' }
BPattern >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^self patternAST = anObject patternAST
]

{ #category : 'accessing' }
BPattern >> addConfig: aPatternConfig [
	
	configs add: aPatternConfig.
	isConfigured := false
]

{ #category : 'converting' }
BPattern >> adoptToSequenceNode [ 
	patternAST isSequence ifFalse: [ 
		patternAST := RBSequenceNode statements: (Array with: patternAST)]
]

{ #category : 'private' }
BPattern >> applyConfigs [
	"Besides building the configured patternAST (as before), also warn - via #inform: (a
	 non-blocking GT toast notification; confirmed empirically to not block or error when
	 signaled from a background async search worker, since BlBlocUIManagerNotification is a
	 resumable Notification that either renders an async toast or silently resumes if
	 unhandled) - when a #with: config that opts into #warnsWhenUnmatched (i.e. a
	 BPatternSpecificVarsConfig/BPatternSpecificSelectorsConfig, as opposed to the two
	 always-present default configs) never matched a single node anywhere in the pattern.
	 This is a strong signal that the variable/selector name passed to #with: was mistyped or
	 copy-pasted from a different pattern (e.g. configuring 'anyVar' when the pattern
	 actually uses 'anyRcv') - previously such a config was silently a no-op, leaving the
	 pattern unexpectedly unfiltered."

	| astBuilder unmatchedConfigs |
	astBuilder := BPatternASTBuilder configuredBy: configs.
	astBuilder visitNode: patternAST.
	constantSelectors := astBuilder collectedSelectors.
	isConfigured := true.

	unmatchedConfigs := configs select: [ :each |
		each warnsWhenUnmatched and: [ (astBuilder appliedConfigs includes: each) not ] ].
	unmatchedConfigs ifNotEmpty: [
		self inform: (String streamContents: [ :s |
			s nextPutAll: 'BPattern with: target(s) not found anywhere in the pattern - had no effect: '.
			unmatchedConfigs
				do: [ :each | each printOn: s ]
				separatedBy: [ s nextPutAll: '; ' ] ]) ]
]

{ #category : 'converting' }
BPattern >> beMethod: headerBlock [
	self adoptToSequenceNode.
	patternAST := BPatternMethodNode 
						fromHeaderBlock: headerBlock 
						body: patternAST.

]

{ #category : 'converting' }
BPattern >> bpattern [
	^self
]

{ #category : 'printing' }
BPattern >> displayStringOn: aStream [
	
	aStream nextPutAll: patternAST formattedCode
]

{ #category : 'comparing' }
BPattern >> hash [
	^self patternAST hash
]

{ #category : 'initialization' }
BPattern >> initialize [ 
	super initialize.

	configs := OrderedCollection new.
	isConfigured := false.
	self useDefaultConfigs
]

{ #category : 'testing' }
BPattern >> isSequenceNode [ 
	^patternAST isSequence
]

{ #category : 'testing' }
BPattern >> matchesAST: aNode [
	self scanAST: aNode do: [ ^true ].
	^false
]

{ #category : 'testing' }
BPattern >> matchesMethod: aMethod [
	"Optimization to verify that all constant selectors from the pattern are actually used by the method.
	It will avoid a slow AST scan for most of the unrelated methods"
	self patternAST. "ensure the lazy pattern build"
	(constantSelectors allSatisfy: [:each | aMethod hasSelector: each ]) ifFalse: [ ^false ].
	
	^self matchesAST: aMethod sourceNode
]

{ #category : 'accessing' }
BPattern >> patternAST [
	isConfigured ifFalse: [ self applyConfigs ].
	^ patternAST 
]

{ #category : 'accessing' }
BPattern >> patternAST: anASTNode [
	patternAST := anASTNode copy
]

{ #category : 'copying' }
BPattern >> postCopy [ 
	super postCopy.
	
	patternAST := patternAST copy.
	configs := configs copy.
]

{ #category : 'printing' }
BPattern >> printOn: aStream [
	super printOn: aStream.
	
	aStream nextPut: $(.
	self displayStringOn: aStream.
	aStream nextPut: $)
]

{ #category : 'rewriting' }
BPattern >> rewriteAST: originalAST with: rewritePattern [

	| rewriter |
	rewriter := BPatternASTRewriter new.
	rewriter addRule: (BPatternReplaceRule new 
			searchTree: self patternAST;
			replaceTree: rewritePattern patternAST).
	rewriter executeTree: originalAST.
	^rewriter tree
	
]

{ #category : 'scanning' }
BPattern >> scanAST: anAST do: nodeBlock [
	"Evaluate nodeBlock for every node of anAST that matches the pattern, passing the matched
	 node and (optionally) the match context."

	| searcher |
	
	searcher := RBParseTreeSearcher new.
	searcher addRule: (BPatternSearchRule new 
			searchTree: self patternAST;
			answerBlock: [ :aNode :answer | nodeBlock cull: aNode cull: searcher context ]).
	searcher executeTree: anAST
]

{ #category : 'private' }
BPattern >> uniqueMethodsFrom: methods [
	"Answer methods, keeping only the first one seen for each distinct <origin, selector>
	 pair and answering the origin's own method (`origin >> selector`) in its place - so a
	 method composed into many classes from one Trait is reported once, as the Trait's own
	 method."

	| seenOrigins |
	seenOrigins := Set new.
	^ (methods select: [ :each |
		(seenOrigins includes: each origin -> each selector)
			ifTrue: [ false ]
			ifFalse: [ seenOrigins add: each origin -> each selector. true ] ])
		collect: [ :each | each origin >> each selector ]
]

{ #category : 'initialization' }
BPattern >> useDefaultConfigs [
	configs add: BPatternDefaultVarConfig new.
	configs add: BPatternDefaultSelectorConfig new
]

{ #category : 'initialization' }
BPattern >> with: configSpecs [
	
	| patternConfigs |
	patternConfigs := BPatternConfig readFromSpecs: configSpecs.
	patternConfigs do: [ :each | self addConfig: each ]
]
