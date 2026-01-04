"
I am a config for default variable patterns. It is all variables started with the #any word.

I am added to all BPattern instances by default. This way variables with #any prefix does not need an explicit configuration. They all are traited as a pattern by default.
"
Class {
	#name : 'BPatternDefaultVarConfig',
	#superclass : 'BPatternVarConfig',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'testing' }
BPatternDefaultVarConfig >> isForNode: aVariableNode [
	(super isForNode: aVariableNode) ifFalse: [ ^false ].
	
	^aVariableNode name beginsWith: 'any'
]
