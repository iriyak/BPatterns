Extension { #name : 'Object' }

{ #category : '*BPatterns-Deprecation' }
Object >> deprecatedBy: blockToCallNewAPI [ 
	"Automatically transform the deprecated call."

	^BPatternDeprecation new
		context: thisContext sender;
		replacementBlock: blockToCallNewAPI;
		signal
]
