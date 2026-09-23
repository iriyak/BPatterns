Extension { #name : 'String' }

{ #category : '*BPatterns-GtViews' }
String >> gtBPatternMatches [
	^ GtSearchBPatternFilter bpattern: (BPattern fromString: self)
]
