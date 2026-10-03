Extension { #name : 'BlockClosure' }

{ #category : '*BPatterns-GToolkit-Extensions' }
BlockClosure >> gtBPatternMatches [
	^ GtSearchBPatternFilter bpattern: self bpattern
]
