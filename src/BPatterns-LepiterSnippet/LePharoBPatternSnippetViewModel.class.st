Class {
	#name : 'LePharoBPatternSnippetViewModel',
	#superclass : 'LePharoSnippetViewModel',
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'accessing' }
LePharoBPatternSnippetViewModel >> snippetElementClass [
	^ LePharoBPatternSnippetElement
]

{ #category : 'accessing' }
LePharoBPatternSnippetViewModel >> snippetView [
	<return: #LeSnippetView>
	^ super snippetView needsContentDecorationBar: true
]

{ #category : 'subscriptions' }
LePharoBPatternSnippetViewModel >> subscribeToSnippetModel [
	super subscribeToSnippetModel.
	self snippetModel weak
		when: LePharoBPatternSnippetScopeChanged
			send: #announce:
			to: self
]

{ #category : 'subscriptions' }
LePharoBPatternSnippetViewModel >> unsubscribeFromSnippetModel [
	super unsubscribeFromSnippetModel.
	self snippetModel unsubscribe: self
]
