Extension { #name : 'BlockClosure' }

{ #category : '*BPatterns-GtViews' }
BlockClosure >> gtBPatternMatches [
	^ GtSearchBPatternFilter bpattern: self bpattern
]
