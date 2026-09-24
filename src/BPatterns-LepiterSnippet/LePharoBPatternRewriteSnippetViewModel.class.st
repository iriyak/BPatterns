Class {
	#name : 'LePharoBPatternRewriteSnippetViewModel',
	#superclass : 'LeSnippetViewModel',
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetViewModel >> snippetElementClass [
	^ LePharoBPatternRewriteSnippetElement
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetViewModel >> snippetView [
	<return: #LeSnippetView>
	^ super snippetView needsContentDecorationBar: true
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetViewModel >> subscribeToSnippetModel [
	super subscribeToSnippetModel.
	self snippetModel weak
		when: LePharoBPatternRewriteSnippetSearchChanged
			send: #announce:
			to: self;
		when: LePharoBPatternRewriteSnippetReplaceChanged
			send: #announce:
			to: self;
		when: LePharoBPatternRewriteSnippetScopeChanged
			send: #announce:
			to: self
]

{ #category : 'as yet unclassified' }
LePharoBPatternRewriteSnippetViewModel >> unsubscribeFromSnippetModel [
	super unsubscribeFromSnippetModel.
	self snippetModel unsubscribe: self
]
