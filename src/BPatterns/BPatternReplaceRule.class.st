"
I am special replace rule class to handle some rewrite corner cases and provide the missing initialization methods required for BPattern.

Particularly #performOn: method uses new recursion search message #recusivelySearchInContextExcept: to fix the infinite loop for primitive bpatterns like:

```
[ any ] bpattern
```

"
Class {
	#name : 'BPatternReplaceRule',
	#superclass : 'OCStringReplaceRule',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'matching' }
BPatternReplaceRule >> performOn: aProgramNode [

	self context empty.
	^((searchTree match: aProgramNode inContext: self context)
		and: [self canMatch: aProgramNode])
			ifTrue:
				[owner recusivelySearchInContextExcept: aProgramNode.
				self foundMatchFor: aProgramNode]
			ifFalse: [nil]
]

{ #category : 'initialization' }
BPatternReplaceRule >> replaceTree: anAST [
	replaceTree := anAST.
	searchTree isSequence = replaceTree isSequence
		ifFalse: [ searchTree isSequence
				ifTrue: [ replaceTree := OCSequenceNode statements: (Array with: replaceTree) ]
				ifFalse: [ searchTree := OCSequenceNode statements: (Array with: searchTree) ] ]
]

{ #category : 'accessing' }
BPatternReplaceRule >> searchTree: anObject [

	searchTree := anObject
]
