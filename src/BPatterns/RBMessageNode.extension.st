Extension { #name : 'RBMessageNode' }

{ #category : '*BPatterns' }
RBMessageNode >> bePatternNode [
	"Turn me, in place (#become:), into a BPatternMessageNode, so that I get BPattern's
	 matching and copying behaviour."

	| patternNode |
	patternNode := BPatternMessageNode new
		receiver: receiver
		selector: selector
		keywordsPositions: keywordsPositions
		arguments: arguments.
	patternNode parent: parent.
	patternNode become: self
]
