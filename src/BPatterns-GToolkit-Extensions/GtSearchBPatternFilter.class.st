"
I am a `GtSearchMethodsFilter` that lets a `BPattern` take part in GT's search/scope pipeline: I include a method when `bpattern matchesMethod:` it, and I compose with other filters as usual (`&`, `|`, class and package scoping).

I am created by `BPattern>>#executeSearchInFilter:` (intersected with the given scope filter, when there is one), by the inspector's Search buttons (`BPattern>>#gtSearchActionFor:`, `BPatternRewrite>>#gtSearchActionFor:`) and by `BlockClosure>>#gtBPatternMatches` (`[ pattern ] gtBPatternMatches`). `#highlighter` answers a `GtBPatternHighlighter` so results show the matched region; `#source` is the pattern's `displayString`. Two of me are equal when their patterns are.
"
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
