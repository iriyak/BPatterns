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
	^methods collect: [:each | self changeForMethod: each ]
]

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> preview [
	| methods |
	methods := searchPattern users.
	^self previewForMethods: methods
]

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> previewForClass: aClass [
	| methods |
	methods := searchPattern usersInClass: aClass.
	^self previewForMethods: methods
]

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> previewForMethods: methods [
	| changes preview |
	changes := self changeForMethods: methods.
	preview := StChangesBrowserPresenter changes: changes.
	^preview openModal
]
