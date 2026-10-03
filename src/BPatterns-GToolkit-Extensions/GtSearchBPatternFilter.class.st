Class {
	#name : 'GtSearchBPatternFilter',
	#superclass : 'GtSearchMethodsFilter',
	#instVars : [
		'bpattern'
	],
	#category : 'BPatterns-GToolkit-Extensions-Filters',
	#package : 'BPatterns-GToolkit-Extensions',
	#tag : 'Filters'
}

{ #category : 'accessing' }
GtSearchBPatternFilter class >> bpattern: aBPattern [
	^ self new
		bpattern: aBPattern;
		yourself
]

{ #category : 'comparing' }
GtSearchBPatternFilter >> = anObject [
	^ self class = anObject class and: [ bpattern = anObject bpattern ]
]

{ #category : 'accessing' }
GtSearchBPatternFilter >> bpattern [
	^ bpattern
]

{ #category : 'accessing' }
GtSearchBPatternFilter >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'comparing' }
GtSearchBPatternFilter >> hash [
	^ self class hash bitXor: bpattern hash
]

{ #category : 'highlighting' }
GtSearchBPatternFilter >> highlighter [
	^ GtBPatternHighlighter new
		bpattern: bpattern;
		yourself
]

{ #category : 'tesing' }
GtSearchBPatternFilter >> includesMethod: aCompiledMethod [
	^ bpattern matchesMethod: aCompiledMethod
]

{ #category : 'accessing' }
GtSearchBPatternFilter >> source [
	^ bpattern displayString
]
