"
I am a superclass for variable pattern configs.

Subclasses redefine #isForNode: method to specify a set of variables which are defined as a pattern
"
Class {
	#name : 'BPatternVarConfig',
	#superclass : 'BPatternConfig',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'testing' }
BPatternVarConfig class >> isAbstract [ 
	^self = BPatternVarConfig
]

{ #category : 'testing' }
BPatternVarConfig >> isForNode: anASTNode [
	^anASTNode isVariable
]
