Class {
	#name : 'LePharoBPatternRewriteSnippetReplaceChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'replace'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetReplaceChanged >> replace [
	^ replace
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetReplaceChanged >> replace: aString [
	replace := aString
]
