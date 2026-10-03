Class {
	#name : 'LePharoBPatternSnippetScopeChanged',
	#superclass : 'LeSnippetContentChanged',
	#instVars : [
		'scope'
	],
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'accessing' }
LePharoBPatternSnippetScopeChanged >> scope [
	^ scope
]

{ #category : 'accessing' }
LePharoBPatternSnippetScopeChanged >> scope: aString [
	scope := aString
]
