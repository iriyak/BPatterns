"
I am announced by `LePharoBPatternLiteralSnippet>>#scope:` when the snippet's ""Search in:"" scope changes; `scope` is the new scope string.
"
Class {
	#name : 'LePharoBPatternLiteralSnippetScopeChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'scope'
	],
	#category : 'BPatterns-GToolkit-Extensions-Announcements',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Announcements'
}

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetScopeChanged >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetScopeChanged >> scope: aString [
	scope := aString
]
