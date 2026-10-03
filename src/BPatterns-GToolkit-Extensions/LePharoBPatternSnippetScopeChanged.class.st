Class {
	#name : 'LePharoBPatternSnippetScopeChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'scope'
	],
	#category : 'BPatterns-GToolkit-Extensions-Announcements',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Announcements'
}

{ #category : 'accessing' }
LePharoBPatternSnippetScopeChanged >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternSnippetScopeChanged >> scope: aString [
	scope := aString
]
