Extension { #name : 'RBVariableNode' }

{ #category : '*BPatterns' }
RBVariableNode >> bePatternNode [
	| patternNode |
	patternNode := BPatternVariableNode named: name start: start.
	patternNode
		parent: parent;
		variable: variable.
	patternNode configureDefaults.
	patternNode become: self
]
