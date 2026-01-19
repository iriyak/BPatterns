Extension { #name : 'Object' }

{ #category : '*BPatterns-Deprecation' }
Object >> deprecated: anExplanationString by: blockToCallNewAPI [ 
	"Automatically transform the deprecated call."

	^BPatternDeprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		replacementBlock: blockToCallNewAPI;
		signal
]

{ #category : '*BPatterns-Deprecation' }
Object >> deprecatedBy: blockToCallNewAPI [ 
	"Automatically transform the deprecated call."

	^BPatternDeprecation new
		context: thisContext sender;
		explanation: 'Use ' , blockToCallNewAPI printString , ' instead';
		replacementBlock: blockToCallNewAPI;
		signal
]
