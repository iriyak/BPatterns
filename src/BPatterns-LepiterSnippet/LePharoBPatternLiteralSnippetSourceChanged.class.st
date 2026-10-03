Class {
	#name : 'LePharoBPatternLiteralSnippetSourceChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'sourceText'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetSourceChanged >> patternSource [
	^ sourceText
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetSourceChanged >> patternSource: aString [
	sourceText := aString
]
