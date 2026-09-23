Class {
	#name : 'GtBPatternHighlighter',
	#superclass : 'GtPharoCodeHighlighter',
	#instVars : [
		'bpattern',
		'method'
	],
	#category : 'BPatterns-GtViews',
	#package : 'BPatterns-GtViews'
}

{ #category : 'highlighting' }
GtBPatternHighlighter >> bpattern [
	^ bpattern
]

{ #category : 'highlighting' }
GtBPatternHighlighter >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'as yet unclassified' }
GtBPatternHighlighter >> method [
	^ method
]

{ #category : 'as yet unclassified' }
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
