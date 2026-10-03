Class {
	#name : 'LePharoBPatternSnippetViewModel',
	#superclass : 'LePharoSnippetViewModel',
	#category : 'BPatterns-GToolkit-Extensions-ViewModels',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'ViewModels'
}

{ #category : 'api - accessing' }
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
