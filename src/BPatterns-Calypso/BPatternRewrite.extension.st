Extension { #name : 'BPatternRewrite' }

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> changeForMethod: aMethod [
	| rewrittenAST rbClass |
	rewrittenAST := self rewriteMethod: aMethod.
	rbClass := RBNamespace new classNamed: aMethod methodClass name.
	^rbClass compileTree: rewrittenAST
]

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> changeForMethods: methods [
	| changes |
	changes := methods collect: [:each | self changeForMethod: each ].
	^RBCompositeRefactoryChange new 
		changes: changes; 
		yourself
]
