Class {
	#name : 'LePharoBPatternSnippet2ScopeChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'scope'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'accessing' }
LePharoBPatternSnippet2ScopeChanged >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternSnippet2ScopeChanged >> scope: aString [
	scope := aString
]
