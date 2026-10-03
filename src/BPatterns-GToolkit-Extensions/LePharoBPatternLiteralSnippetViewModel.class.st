Class {
	#name : 'LePharoBPatternLiteralSnippetViewModel',
	#superclass : 'LeSnippetViewModel',
	#category : 'BPatterns-GToolkit-Extensions-ViewModels',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'ViewModels'
}

{ #category : 'api - accessing' }
LePharoBPatternLiteralSnippetViewModel >> snippetElementClass [
	^ LePharoBPatternLiteralSnippetElement
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetViewModel >> snippetView [
	<return: #LeSnippetView>
	^ super snippetView needsContentDecorationBar: true
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetViewModel >> subscribeToSnippetModel [
	super subscribeToSnippetModel.
	self snippetModel weak
		when: LePharoBPatternLiteralSnippetSourceChanged send: #announce: to: self;
		when: LePharoBPatternLiteralSnippetScopeChanged send: #announce: to: self
]

{ #category : 'accessing' }
LePharoBPatternLiteralSnippetViewModel >> unsubscribeFromSnippetModel [
	super unsubscribeFromSnippetModel.
	self snippetModel unsubscribe: self
]
