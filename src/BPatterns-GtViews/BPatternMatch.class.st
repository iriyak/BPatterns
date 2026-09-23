Class {
	#name : 'BPatternMatch',
	#superclass : 'Object',
	#instVars : [
		'bpattern',
		'method'
	],
	#category : 'BPatterns-GtViews',
	#package : 'BPatterns-GtViews'
}

{ #category : 'instance creation' }
BPatternMatch class >> bpattern: aBPattern method: aCompiledMethod [
	^ self new
		bpattern: aBPattern;
		method: aCompiledMethod;
		yourself
]

{ #category : 'accessing' }
BPatternMatch >> bpattern [
	^ bpattern
]

{ #category : 'accessing' }
BPatternMatch >> bpattern: aBPattern [
	bpattern := aBPattern
]

{ #category : 'as yet unclassified' }
BPatternMatch >> gtSourceCodeFor: aView [
	<gtView>
	^ aView explicit
		title: 'Source code';
		priority: 10;
		stencil: [ 
			(GtPharoMethodCoder forMethod: method)
				highlighter: (GtBPatternHighlighter new bpattern: bpattern; method: method; yourself);
				asExpandedOnlyElement ]
]

{ #category : 'accessing' }
BPatternMatch >> method [
	^ method
]

{ #category : 'accessing' }
BPatternMatch >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : 'printing' }
BPatternMatch >> printOn: aStream [
	aStream
		nextPutAll: method methodClass name;
		nextPutAll: ' >> ';
		nextPutAll: method selector
]
