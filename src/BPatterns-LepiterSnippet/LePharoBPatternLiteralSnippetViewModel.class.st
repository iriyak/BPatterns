Class {
	#name : 'LePharoBPatternLiteralSnippetViewModel',
	#superclass : 'LeSnippetViewModel',
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetViewModel >> snippetElementClass [
	^ LePharoBPatternLiteralSnippetElement
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetViewModel >> snippetView [
	<return: #LeSnippetView>
	^ super snippetView needsContentDecorationBar: true
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetViewModel >> subscribeToSnippetModel [
	super subscribeToSnippetModel.
	self snippetModel weak
		when: LePharoBPatternLiteralSnippetSourceChanged send: #announce: to: self;
		when: LePharoBPatternLiteralSnippetScopeChanged send: #announce: to: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternLiteralSnippetViewModel >> unsubscribeFromSnippetModel [
	super unsubscribeFromSnippetModel.
	self snippetModel unsubscribe: self
]
