"
I am an AST visitor to build the pattern AST from the given AST node using a specified configs (#patternConfigs).
The original AST in that case is modified during the visit logic. The configured AST nodes are transformed into the pattern ones.

I am used by BPattern class to build the final #patternAST instance from the given block.
"
Class {
	#name : 'BPatternASTBuilder',
	#superclass : 'RBProgramNodeVisitor',
	#instVars : [
		'patternConfigs',
		'collectedSelectors'
	],
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'instance creation' }
BPatternASTBuilder class >> configuredBy: configs [
	^self new 
		patternConfigs: configs
]

{ #category : 'visiting' }
BPatternASTBuilder >> applyConfigsFor: aNode [
	patternConfigs 
		select: [ :each | each isForNode: aNode ] 
		thenDo: [ :each | 	each applyForNode: aNode ]
]

{ #category : 'accessing' }
BPatternASTBuilder >> collectedSelectors [

	^ collectedSelectors
]

{ #category : 'visiting' }
BPatternASTBuilder >> initialize [
	super initialize.
	
	patternConfigs := #().
	collectedSelectors := OrderedCollection new
]

{ #category : 'accessing' }
BPatternASTBuilder >> patternConfigs [

	^ patternConfigs
]

{ #category : 'accessing' }
BPatternASTBuilder >> patternConfigs: anObject [

	patternConfigs := anObject
]

{ #category : 'visiting' }
BPatternASTBuilder >> visitMessageNode: aMessageNode [
	self applyConfigsFor: aMessageNode.
	aMessageNode isPatternNode ifFalse: [ collectedSelectors add: aMessageNode selector ].
	
	self visitNode: aMessageNode receiver.
	self visitNode: aMessageNode selectorNode.
	aMessageNode arguments do: [ :each | self visitNode: each ]
]

{ #category : 'visiting' }
BPatternASTBuilder >> visitMethodNode: aMethodNode [
	self applyConfigsFor: aMethodNode.
	super visitMethodNode: aMethodNode
]

{ #category : 'visiting' }
BPatternASTBuilder >> visitVariableNode: aNode [
	self applyConfigsFor: aNode 
]
