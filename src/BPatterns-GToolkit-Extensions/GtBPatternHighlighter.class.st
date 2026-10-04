"
I highlight the regions of a method's source that a `BPattern` matches. I am a `GtPharoCodeHighlighter` answered by `GtSearchBPatternFilter>>#highlighter`, which is how GT's generic search-results view marks the matched part of each result method.

`#style:ast:` runs `BPattern>>#scanAST:do:` over the method's AST and styles the `gtInterestingHighlightingIntervals` of every matched node. The AST comes from `method` when it is set explicitly, else from the compiled method of the coder view model I am attached to; failing both, the text itself is parsed (tolerating syntax errors via `RBParser parseFaultyMethod:`).
"
Class {
	#name : 'GtBPatternHighlighter',
	#superclass : 'GtPharoCodeHighlighter',
	#instVars : [
		'bpattern',
		'method'
	],
	#category : 'BPatterns-GToolkit-Extensions-Highlighters',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Highlighters'
}

{ #category : 'accessing' }
GtBPatternHighlighter >> bpattern [
	^ bpattern
]

{ #category : 'accessing' }
GtBPatternHighlighter >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'accessing' }
GtBPatternHighlighter >> method [
	^ method
]

{ #category : 'accessing' }
GtBPatternHighlighter >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : 'highlighting' }
GtBPatternHighlighter >> style: aText ast: theAst [
	| aMethod tree intervals |
	aMethod := method ifNil: [
		self coderViewModel
			ifNotNil: [ :aViewModel | 
				aViewModel coderModel
					ifNotNil: [ :aCoderModel | 
						(aCoderModel respondsTo: #compiledMethod)
							ifTrue: [ aCoderModel compiledMethod ] ] ] ].
	tree := aMethod
		ifNotNil: [ aMethod sourceNode ]
		ifNil: [ theAst attributeNamed: #rbAST ifAbsentPut: [ RBParser parseFaultyMethod: aText asString ] ].
	intervals := OrderedCollection new.
	bpattern scanAST: tree do: [ :node :ctx | intervals addAll: node gtInterestingHighlightingIntervals ].
	self style: aText intervals: intervals.
	^ aText
]
