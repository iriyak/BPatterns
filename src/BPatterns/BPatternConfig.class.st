"
I am a root of a hierarchy of pattern config classes.
Configs are used to convert the regular AST nodes into the pattern.
Subclasses should implement #isForNode: method to define which kind of nodes they should be used for.
The actual convertion logic is implemented in #applyForNode method.

Instances of my subclasses can be created with an optional parameter #nodeConfigBlock to modify a state of the corresponding pattern nodes adjusting the filter behaviour.

Normally config instances are created together with #bpattern and #brewrite messages using an extra #with: DSL message. See the package comment for the full details about the pattern configuration.

"
Class {
	#name : 'BPatternConfig',
	#superclass : 'Object',
	#instVars : [
		'nodeConfigBlock'
	],
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'instance creation' }
BPatternConfig class >> forPatternNamesFrom: symbolsOrStringsOrBlocks configuredBy: configBlock [
	"symbols configure concrete pattern messages
	strings configure concrete variable names
	blocks configure all variables referenced inside them"
	^symbolsOrStringsOrBlocks first isSymbol 
		ifTrue: [ self forSelectorsFrom: symbolsOrStringsOrBlocks configuredBy: configBlock ]	
		ifFalse: [ self forVarsFrom: symbolsOrStringsOrBlocks configuredBy: configBlock ]
]

{ #category : 'instance creation' }
BPatternConfig class >> forSelectorsFrom: selectorOrArray configuredBy: configNodeBlock [

	| selectors |
	selectors := selectorOrArray isSymbol ifTrue: [ { selectorOrArray} ] ifFalse: [ selectorOrArray ].
	^BPatternSpecificSelectorsConfig forSelectors: selectors configuredBy: configNodeBlock.
]

{ #category : 'instance creation' }
BPatternConfig class >> forVarsFrom: blocksWithVarsAndVars configuredBy: configNodeBlock [

	| vars |	
	vars := OrderedCollection new.
	blocksWithVarsAndVars do: [:eachBlockOrVar | 
		eachBlockOrVar isString 
			ifTrue: [ vars add: eachBlockOrVar ]
			ifFalse: [ eachBlockOrVar sourceNode variableNodes do: [:each | vars add: each name ]]].
	^BPatternSpecificVarsConfig forVars: vars configuredBy: configNodeBlock
]

{ #category : 'instance creation' }
BPatternConfig class >> isAbstract [ 
	^self = BPatternConfig
]

{ #category : 'instance creation' }
BPatternConfig class >> readFromSingleSpec: anObjectOrAssoc [
	| objectsWithPatternNames configBlock |
	anObjectOrAssoc isAssociation 
		ifTrue: [ 
			objectsWithPatternNames := anObjectOrAssoc key.
			configBlock := anObjectOrAssoc value ]
		ifFalse: [ objectsWithPatternNames := anObjectOrAssoc ].
	objectsWithPatternNames isArray ifFalse: [ objectsWithPatternNames := { objectsWithPatternNames } ].	
	^self forPatternNamesFrom: objectsWithPatternNames configuredBy: configBlock
]

{ #category : 'instance creation' }
BPatternConfig class >> readFromSpecs: anObjectOrArray [

	anObjectOrArray isArray ifFalse: [ ^{self readFromSingleSpec: anObjectOrArray} ].
	^anObjectOrArray collect: [ :each | self readFromSingleSpec: each ]
]

{ #category : 'applying' }
BPatternConfig >> applyForNode: anASTNode [
	anASTNode bePatternNode.
	
	self applyForPatternNode: anASTNode
]

{ #category : 'applying' }
BPatternConfig >> applyForPatternNode: aPatternNode [
	
	nodeConfigBlock ifNotNil: [ nodeConfigBlock value: aPatternNode ]
]

{ #category : 'testing' }
BPatternConfig >> isForNode: anASTNode [
	^self subclassResponsibility 
]

{ #category : 'accessing' }
BPatternConfig >> nodeConfigBlock [

	^ nodeConfigBlock
]

{ #category : 'accessing' }
BPatternConfig >> nodeConfigBlock: anObject [

	nodeConfigBlock := anObject
]
