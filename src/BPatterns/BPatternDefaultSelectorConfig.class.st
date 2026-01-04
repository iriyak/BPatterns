"
I am a config for default selector patterns. 
I am applied for all selectors containing a keyword with the **any** prefix.

I am added to all BPattern instances by default. This way selectors with #any word does not need an explicit configuration. They all are traited as a pattern by default.
"
Class {
	#name : 'BPatternDefaultSelectorConfig',
	#superclass : 'BPatternSelectorConfig',
	#category : 'BPatterns',
	#package : 'BPatterns'
}

{ #category : 'testing' }
BPatternDefaultSelectorConfig >> isForKeyword: aSymbol [
	^aSymbol beginsWith: 'any'
]
