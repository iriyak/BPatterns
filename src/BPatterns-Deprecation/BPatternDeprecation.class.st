Class {
	#name : 'BPatternDeprecation',
	#superclass : 'Deprecation',
	#instVars : [
		'replacementBlock'
	],
	#category : 'BPatterns-Deprecation',
	#package : 'BPatterns-Deprecation'
}

{ #category : 'handling' }
BPatternDeprecation >> buildBRewrite [
	| deprecatedAST patternArgNames messagePatternNode searchPattern patternArgs patternConfig |
	deprecatedAST := self contextOfDeprecatedMethod homeMethod ast.
	patternArgs := deprecatedAST arguments collect: [:each | each copy ].
	patternArgNames := patternArgs collect: [ :each | each name ].
	patternConfig := BPatternSpecificVarsConfig forVars: (patternArgNames copyWith: #self).
	messagePatternNode := OCMessageNode 
		receiver: OCVariableNode selfNode
		selector: deprecatedAST selector 
		arguments: patternArgs.
	searchPattern := BPattern fromAST: messagePatternNode.
	searchPattern addConfig: patternConfig.
	rule addConfig: patternConfig.
	^BPatternRewrite fromPattern: searchPattern to: rule
]

{ #category : 'handling' }
BPatternDeprecation >> defaultAction [
	super defaultAction.
	^replacementBlock value
]

{ #category : 'accessing' }
BPatternDeprecation >> replacementBlock [

	^ replacementBlock
]

{ #category : 'handling' }
BPatternDeprecation >> replacementBlock: blockToCallNewAPI [

	replacementBlock := blockToCallNewAPI.
	rule := replacementBlock bpattern.
	self explanation: 'Use ' , replacementBlock printString , ' instead'
]

{ #category : 'handling' }
BPatternDeprecation >> transform [
	| node aMethod rewrite rewrittenNode |
	self rewriterClass ifNil:[ ^ self ].
	
	aMethod := self contextOfSender homeMethod.	
	"no need to transform doits or non installed methods.
	Non installed methods can arise if we are rewriting a closure whose home method was rewritten"
	aMethod isDoIt ifTrue:[ ^ self ].
	aMethod isInstalled ifFalse: [ ^ self ].
	
	node := self contextOfSender sourceNodeExecuted.
	RecursionStopper during: [
		rewrite := self buildBRewrite.
		rewrittenNode := rewrite rewriteAST: node.
		node replaceWith: rewrittenNode.
		aMethod origin
			compile: aMethod ast formattedCode
			classified: aMethod protocol.
		self class addLog: self ]
]
