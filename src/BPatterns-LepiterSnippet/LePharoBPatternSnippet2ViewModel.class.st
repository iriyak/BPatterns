Class {
	#name : 'LePharoBPatternSnippet2ViewModel',
	#superclass : 'LePharoSnippetViewModel',
	#category : 'BPatterns-LepiterSnippet',
	#package : 'BPatterns-LepiterSnippet'
}

{ #category : 'accessing' }
LePharoBPatternSnippet2ViewModel >> snippetElementClass [
	^ LePharoBPatternSnippet2Element
]

{ #category : 'accessing' }
LePharoBPatternSnippet2ViewModel >> snippetView [
	<return: #LeSnippetView>
	^ super snippetView needsContentDecorationBar: true
]

{ #category : 'subscriptions' }
LePharoBPatternSnippet2ViewModel >> subscribeToSnippetModel [
	super subscribeToSnippetModel.
	self snippetModel weak
		when: LePharoBPatternSnippet2ScopeChanged
			send: #announce:
			to: self
]

{ #category : 'subscriptions' }
LePharoBPatternSnippet2ViewModel >> unsubscribeFromSnippetModel [
	super unsubscribeFromSnippetModel.
	self snippetModel unsubscribe: self
]
