Class {
	#name : 'GtBPatternHighlighter',
	#superclass : 'GtPharoCodeHighlighter',
	#instVars : [
		'bpattern'
	],
	#category : 'BPatterns-GtViews-Highlighter',
	#package : 'BPatterns-GtViews',
	#tag : 'Highlighter'
}

{ #category : 'highlighting' }
GtBPatternHighlighter >> bpattern [
	^ bpattern
]

{ #category : 'highlighting' }
GtBPatternHighlighter >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'highlighting' }
GtBPatternHighlighter >> style: aText ast: theAst [
	| tree intervals |
	tree := theAst
		attributeNamed: #rbAST
		ifAbsentPut: [ RBParser parseFaultyMethod: aText asString ].
	intervals := OrderedCollection new.
	bpattern scanAST: tree do: [ :node :ctx |
		intervals addAll: node gtInterestingHighlightingIntervals ].
	self style: aText intervals: intervals.
	^ aText
]
