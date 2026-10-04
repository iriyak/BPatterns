Extension { #name : 'RBVariableNode' }

{ #category : '*BPatterns' }
RBVariableNode >> bePatternNode [
	"Turn me, in place (#become:), into a BPatternVariableNode with default configuration, so
	 that I get BPattern's matching and copying behaviour."

	| patternNode |
	patternNode := BPatternVariableNode named: name start: start.
	patternNode
		parent: parent;
		variable: variable.
	patternNode configureDefaults.
	patternNode become: self
]
