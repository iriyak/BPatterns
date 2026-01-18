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

{ #category : 'instance creation' }
BPattern class >> fromBlock: definitionBlock [ 
	| definitionAST patternAST |
	definitionAST := definitionBlock sourceNode.
	patternAST := (definitionAST statements size == 1 and: [ definitionAST temporaries isEmpty ])
		  ifTrue: [ definitionAST statements first ]
		  ifFalse: [ definitionAST body ].
	^self fromAST: patternAST
	
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
		patternAST := OCSequenceNode statements: (Array with: patternAST)]
]

{ #category : 'private' }
BPattern >> applyConfigs [
	| astBuilder |
	astBuilder := BPatternASTBuilder configuredBy: configs.
	astBuilder visitNode: patternAST.
	constantSelectors := astBuilder collectedSelectors.
	isConfigured := true
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
	| searcher |
	
	searcher := OCParseTreeSearcher new.
	searcher addRule: (BPatternSearchRule new 
			searchTree: self patternAST;
			answerBlock: [ :aNode :answer | nodeBlock cull: aNode cull: searcher context ]).
	searcher executeTree: anAST
]

{ #category : 'initialization' }
BPattern >> useDefaultConfigs [
	configs add: BPatternDefaultVarConfig new.
	configs add: BPatternDefaultSelectorConfig new
]

{ #category : 'scanning' }
BPattern >> users [

	| result |
	result := OrderedCollection new.
	Smalltalk allClasses 
		do:[:aClass| result addAll: (self usersInClass: aClass) ]
		displayingProgress: 'Lookup for [', self displayString, ']'
		every: 1000.
	^result
]

{ #category : 'scanning' }
BPattern >> usersInClass: aClass [
	
	| result |
	result := OrderedCollection new.
	aClass methodsDo: [:each | 	(self matchesMethod: each) ifTrue: [ result add: each ]].
	aClass class methodsDo: [:each | 	(self matchesMethod: each) ifTrue: [ result add: each ]].
	^result

]

{ #category : 'initialization' }
BPattern >> with: configSpecs [
	
	| patternConfigs |
	patternConfigs := BPatternConfig readFromSpecs: configSpecs.
	patternConfigs do: [ :each | self addConfig: each ]
]
