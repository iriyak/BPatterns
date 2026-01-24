Extension { #name : 'BPatternRewrite' }

{ #category : '*BPatterns-Calypso' }
BPatternRewrite >> changeForMethod: aMethod [
	| rewrittenAST rbClass |
	rewrittenAST := self rewriteMethod: aMethod.
	rbClass := RBNamespace new classNamed: aMethod methodClass name.
	^rbClass compileTree: rewrittenAST
]

{ #category : '*BPatterns-Calypso' }
BPatternRewrite >> changeForMethods: methods [
	| changes |
	changes := OrderedCollection new.
	methods do: [:each | changes add: (self changeForMethod: each) ].
	^RBCompositeRefactoryChange new 
		changes: changes; 
		yourself
]
