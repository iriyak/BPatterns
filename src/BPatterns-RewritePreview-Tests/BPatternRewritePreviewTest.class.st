Class {
	#name : 'BPatternRewritePreviewTest',
	#superclass : 'TestCase',
	#category : 'BPatterns-RewritePreview-Tests',
	#package : 'BPatterns-RewritePreview-Tests'
}

{ #category : 'tests' }
BPatternRewritePreviewTest >> testChangeForMethod [

	| rewrite any change |
	rewrite := [[ any isNil ifFalse: [ any printString ]] -> [ any ifNotNil: [ any printString ]]] brewrite.
	
	change := rewrite changeForMethod: BPatternMethodExamples>>#isNilIfFalseWith:.
	self assert: change class equals: RBAddMethodChange.
	self assert: change selector equals: #isNilIfFalseWith:.
	self assert: change changeClass identicalTo: BPatternMethodExamples.
	self assert: change parseTree equals: (BPatternRewrittenMethodExamples>>#isNilIfFalseWith:) ast.
]

{ #category : 'tests' }
BPatternRewritePreviewTest >> testChangeForMethods [

	| rewrite any change fullChange |
	rewrite := [[ any isNil ifFalse: [ any printString ]] -> [ any ifNotNil: [ any printString ]]] brewrite.
	
	fullChange := rewrite changeForMethods: {BPatternMethodExamples>>#isNilIfFalseWith:}.
	self assert: fullChange class equals: RBCompositeRefactoryChange.
	self assert: fullChange changes size equals: 1.
	change := fullChange changes first.
	self assert: change class equals: RBAddMethodChange.
	self assert: change selector equals: #isNilIfFalseWith:.
	self assert: change changeClass identicalTo: BPatternMethodExamples.
	self assert: change parseTree equals: (BPatternRewrittenMethodExamples>>#isNilIfFalseWith:) ast.
]
