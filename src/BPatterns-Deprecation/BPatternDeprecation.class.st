"
I am a special deprecation warning based on BPatterns which brings an automatic transformation without a special rewrite syntax.

For example let's deprecate the renamed method #foo: using its new name #newFoo:. The deprecated method should just call new one using a regular self-call wrapped by new deprecation mechanizm:

```
foo: fooArg
	^ self deprecatedBy: [ self newFoo: fooArg ]
```

The deprecation block represents new API to be called instead of a deprecated one. 

With the old deprecatino mechanizm you would manualy construct the transformation rule using the rewrite syntax:

```
foo: fooArg
	self 
		deprecated:   'Use Bar>>newFoo: instead.'
		transformWith:   '`@receiver foo: `@arg' -> '`@receiver newFoo: `@arg'.	
	^self newFoo: fooArg
```

You can see that new deprecation API is much simpler.

The default deprecation message is constructed from the deprecation block:

```
Use [ self newFoo: fooArg ] instead
```

For the custom warning there is another message:

```
foo: fooArg
	^ self 
			deprecated: 'Custom deprecation string'
			by: [ self newFoo: fooArg ]
```

Internally the deprecation block is used for three goals:

- to construct the default deprecation text

- to call new API when the deprecation warning is passed (the default action)

- to construct the rewrite pattern for the automatic transformation of the deprecation user

For the automatic transformation I construct a `BPatternRewrite` instance using an AST of the deprecated method as a search pattern and a deprecation block as a rewrite pattern. All variables of the deprecated method are configured as a wildcard patterns. For the illustration, the equivalent #brewrite expression for the same transformation would be: 


```
[[ self foo: fooArg ] -> [ self newFoo: fooArg ]] brewrite with: [self. fooArg]
```

"
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
	| patternArgNames messagePatternNode searchPattern patternConfig |
	messagePatternNode := self buildDeprecatedMessageNode. 
	patternArgNames := messagePatternNode variableNodes collect: [ :each | each name ].
	patternConfig := BPatternSpecificVarsConfig forVars: patternArgNames.
	searchPattern := BPattern fromAST: messagePatternNode.
	searchPattern addConfig: patternConfig.
	rule addConfig: patternConfig.
	^BPatternRewrite fromPattern: searchPattern to: rule
]

{ #category : 'handling' }
BPatternDeprecation >> buildDeprecatedMessageNode [
	| deprecatedAST patternArgs |
	deprecatedAST := self contextOfDeprecatedMethod homeMethod ast.
	patternArgs := deprecatedAST arguments collect: [:each | each copy ].
	^RBMessageNode
		receiver: RBVariableNode selfNode
		selector: (RBSelectorNode value: deprecatedAST selector)
		arguments: patternArgs
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
	rule := replacementBlock bpattern
]

{ #category : 'handling' }
BPatternDeprecation >> transform [
	| node aMethod rewrittenNode |
	self rewriterClass ifNil:[ ^ self ].
	
	aMethod := self contextOfSender homeMethod.	
	"no need to transform doits or non installed methods.
	Non installed methods can arise if we are rewriting a closure whose home method was rewritten"
	aMethod isDoIt ifTrue:[ ^ self ].
	aMethod isInstalled ifFalse: [ ^ self ].
	
	node := self contextOfSender sourceNodeExecuted.
	RecursionStopper during: [
		rewrittenNode := self buildBRewrite rewriteAST: node.
		node replaceWith: rewrittenNode.
		aMethod origin
			compile: aMethod ast formattedCode
			classified: aMethod protocol.
		self class addLog: self ]
]
