"
I am special AST rewriter to adjust the way how the argument nodes are handled.
For BPatterns we do not need a separate #argumentSearches as it is done for the original rewrite engine.
"
Class {
	#name : 'BPatternASTRewriter',
	#superclass : 'OCParseTreeRewriter',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'visiting' }
BPatternASTRewriter >> visitArgumentNode: aNode [
	| value |
	value := self performSearches: searches on: aNode.
	^ value
		ifNil: [
			super visitArgumentNode: aNode.
			aNode ]
		ifNotNil: [ value ]
]
