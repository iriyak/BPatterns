Class {
	#name : 'BPatternDeprecationTests',
	#superclass : 'TestCase',
	#category : 'BPatterns-Deprecation-Tests',
	#package : 'BPatterns-Deprecation-Tests'
}

{ #category : 'deprecated examples' }
BPatternDeprecationTests >> deprecatedMessageWithArg: argExample1 and: argExample2 [

	^self deprecatedBy: [ self newMessageWith: argExample1 ]
]

{ #category : 'deprecated examples' }
BPatternDeprecationTests >> newMessageWith: anArgument [
	^anArgument printString
]

{ #category : 'deprecated examples' }
BPatternDeprecationTests >> rewrittenSenderOfDeprecatedMessage [ 
	
	| one result |
	one := 1.
	result := self class new newMessageWith: one + 2.
	^result
]

{ #category : 'deprecated examples' }
BPatternDeprecationTests >> senderOfDeprecatedMessage [ 
	
	| one result |
	one := 1.
	result := self class new deprecatedMessageWithArg: one + 2 and: 10 + 11.
	^result
]

{ #category : 'tests' }
BPatternDeprecationTests >> testDeprecationExplanation [

	| deprecation |
	[ self senderOfDeprecatedMessage ] on: Deprecation do: [ :err | deprecation := err ].

	self assert: deprecation explanationString equals: 'Use [ self newMessageWith: argExample1 ] instead'
]

{ #category : 'tests' }
BPatternDeprecationTests >> testDeprecationRewritePatterns [

	| deprecation deprecationRewrite searchPatternAST deprecatedMethodAST rewritePatternAST |
	[ self senderOfDeprecatedMessage ] on: Deprecation do: [ :err | deprecation := err ].

	self assert: deprecation class equals: BPatternDeprecation.
	deprecationRewrite := deprecation buildBRewrite.
	searchPatternAST := deprecationRewrite searchPattern patternAST.
	self assert: searchPatternAST class equals: OCMessageNode.
	self assert: searchPatternAST receiver isPatternNode.
	self assert: searchPatternAST receiver name equals: #self.
	deprecatedMethodAST := (self class >> #deprecatedMessageWithArg:and:) ast.
	self assert: searchPatternAST arguments size equals: deprecatedMethodAST arguments size.
	searchPatternAST arguments with: deprecatedMethodAST arguments do: [ :patternArg :methodArg | 
		self assert: patternArg isPatternNode.
		self deny: patternArg identicalTo: methodArg "it should be copied for the pattern"
	 ].
	rewritePatternAST := deprecationRewrite rewritePattern patternAST.
	self assert: rewritePatternAST receiver equals: searchPatternAST receiver.
	self assert: (searchPatternAST arguments includesAll: rewritePatternAST arguments)
]

{ #category : 'tests' }
BPatternDeprecationTests >> testDeprecationTransformation [
	| rewrittenAST expected actual |
	self skip. "manual test to verify the rewritten method"
	
	actual := self senderOfDeprecatedMessage.
	expected := self newMessageWith: 1 + 2.
	self assert: actual equals: expected.
	
	rewrittenAST := (self class >> #senderOfDeprecatedMessage) ast body.
	expected := (self class >> #rewrittenSenderOfDeprecatedMessage) ast body.
	self assert: rewrittenAST equals: expected.
]
