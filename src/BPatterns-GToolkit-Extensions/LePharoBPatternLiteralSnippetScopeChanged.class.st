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
