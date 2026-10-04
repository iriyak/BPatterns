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
		'collectedSelectors',
		'appliedConfigs'
	],
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'instance creation' }
BPatternASTBuilder class >> configuredBy: configs [
	^self new 
		patternConfigs: configs
]

{ #category : 'accessing' }
BPatternASTBuilder >> appliedConfigs [
	"Answer the IdentitySet of configs (from patternConfigs) that matched at least one node
	 during the AST visit just completed - i.e. #applyForNode: was actually sent to them.
	 Used by BPattern>>#applyConfigs to detect a #with: config whose target name/selector
	 never appeared anywhere in the pattern, which would otherwise silently have no effect."

	^ appliedConfigs
]

{ #category : 'visiting' }
BPatternASTBuilder >> applyConfigsFor: aNode [
	"Apply every config that matches aNode, remembering each one in #appliedConfigs so that
	 BPattern>>#applyConfigs can later warn about #with: configs that never matched anything."

	patternConfigs 
		select: [ :each | each isForNode: aNode ] 
		thenDo: [ :each | 
			appliedConfigs add: each.
			each applyForNode: aNode ]
]

{ #category : 'accessing' }
BPatternASTBuilder >> collectedSelectors [

	^ collectedSelectors
]

{ #category : 'initialization' }
BPatternASTBuilder >> initialize [
	super initialize.

	patternConfigs := #().
	collectedSelectors := OrderedCollection new.
	appliedConfigs := IdentitySet new
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
