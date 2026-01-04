"
I am special search rule class to handle some corner cases and provide the missing initialization methods required for BPattern.

Particularly #performOn: method uses new recursion search message #recusivelySearchInContextExcept: to fix the infinite loop for primitive bpatterns like:

```
[ any ] bpattern
```

"
Class {
	#name : 'BPatternSearchRule',
	#superclass : 'OCSearchRule',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'accessing' }
BPatternSearchRule >> answerBlock [

	^ answerBlock
]

{ #category : 'accessing' }
BPatternSearchRule >> answerBlock: anObject [

	answerBlock := anObject
]

{ #category : 'matching' }
BPatternSearchRule >> performOn: aProgramNode [

	self context empty.
	^((searchTree match: aProgramNode inContext: self context)
		and: [self canMatch: aProgramNode])
			ifTrue:
				[owner recusivelySearchInContextExcept: aProgramNode.
				self foundMatchFor: aProgramNode]
			ifFalse: [nil]
]

{ #category : 'accessing' }
BPatternSearchRule >> searchTree: anObject [

	searchTree := anObject
]
