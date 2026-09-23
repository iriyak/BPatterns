Class {
	#name : 'GtSearchBPatternFilter',
	#superclass : 'GtSearchMethodsFilter',
	#instVars : [
		'bpattern'
	],
	#category : 'BPatterns-GtViews',
	#package : 'BPatterns-GtViews'
}

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter class >> bpattern: aBPattern [
	^ self new
		bpattern: aBPattern;
		yourself
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> = anObject [
	^ self class = anObject class and: [ bpattern = anObject bpattern ]
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> bpattern [
	^ bpattern
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> hash [
	^ self class hash bitXor: bpattern hash
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> highlighter [
	^ GtBPatternHighlighter new
		bpattern: bpattern;
		yourself
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> includesMethod: aCompiledMethod [
	^ bpattern matchesMethod: aCompiledMethod
]

{ #category : 'as yet unclassified' }
GtSearchBPatternFilter >> source [
	^ bpattern displayString
]
