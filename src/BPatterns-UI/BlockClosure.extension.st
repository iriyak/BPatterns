Extension { #name : 'BlockClosure' }

{ #category : '*BPatterns-UI' }
BlockClosure >> gtBPatternMatches [
	^ GtSearchBPatternFilter bpattern: self bpattern
]
