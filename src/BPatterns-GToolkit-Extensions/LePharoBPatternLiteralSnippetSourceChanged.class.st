Class {
	#name : 'LePharoBPatternLiteralSnippetSourceChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'sourceText'
	],
	#category : 'BPatterns-GToolkit-Extensions-Announcements',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Announcements'
}

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetSourceChanged >> patternSource [
	^ sourceText
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetSourceChanged >> patternSource: aString [
	sourceText := aString
]
