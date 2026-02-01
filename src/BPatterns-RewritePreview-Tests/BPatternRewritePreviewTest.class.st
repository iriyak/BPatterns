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
	self assert: (change class name endsWith: 'AddMethodChange').
	self assert: change selector equals: #isNilIfFalseWith:.
	self assert: change changeClass identicalTo: BPatternMethodExamples.
	self assert: change parseTree equals: (BPatternRewrittenMethodExamples>>#isNilIfFalseWith:) ast.
]

{ #category : 'tests' }
BPatternRewritePreviewTest >> testChangeForMethods [

	| rewrite any change allChanges |
	rewrite := [[ any isNil ifFalse: [ any printString ]] -> [ any ifNotNil: [ any printString ]]] brewrite.
	
	allChanges := rewrite changeForMethods: {BPatternMethodExamples>>#isNilIfFalseWith:}.
	self assert: allChanges size equals: 1.
	change := allChanges first.
	self assert: change selector equals: #isNilIfFalseWith:.
	self assert: change changeClass identicalTo: BPatternMethodExamples.
	self assert: change parseTree equals: (BPatternRewrittenMethodExamples>>#isNilIfFalseWith:) ast.
]
