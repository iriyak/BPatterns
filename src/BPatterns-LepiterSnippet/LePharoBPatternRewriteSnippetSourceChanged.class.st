Class {
	#name : 'LePharoBPatternRewriteSnippetSourceChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'sourceText'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetSourceChanged >> patternSource [
	^ sourceText
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetSourceChanged >> patternSource: aString [
	sourceText := aString
]
