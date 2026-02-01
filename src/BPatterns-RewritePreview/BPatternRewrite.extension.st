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
BPatternRewrite >> openChangeBrowserOn: changes [
	"New Pharo 14"
	| browserClass preview |
	browserClass := self class environment at: #StChangesBrowserPresenter.
	preview := browserClass changes: changes.
	^preview openModal
]

{ #category : '*BPatterns-RewritePreview' }
BPatternRewrite >> openRefactoringPreviewFor: changes [
	"Old Pharo 13"
	| preview composite |
	composite := (self class environment at: #RBCompositeRefactoryChange) new 
						changes: changes; 
						yourself.
	preview := StRefactoringPreviewPresenter for: composite.
	^preview openModal
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
	| changes |
	changes := self changeForMethods: methods.
	^(self class environment includesKey: #StChangesBrowserPresenter) 
		ifTrue: [ self openChangeBrowserOn: changes ]
		ifFalse: [ self openRefactoringPreviewFor: changes ]
]
