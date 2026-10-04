"
I am announced by `LePharoBPatternLiteralSnippet>>#source:` when the snippet's source text changes; `patternSource` answers the new text.
"
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
