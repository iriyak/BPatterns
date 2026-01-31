"
I am a command to show all users of a selected expression as a pattern.

I construct BPattern from a selected source node and pass it as a query into the browser
"
Class {
	#name : 'BPatternFindPatternUsersCommand',
	#superclass : 'SycSourceCodeCommand',
	#instVars : [
		'browser'
	],
	#category : 'BPatterns-Calypso',
	#package : 'BPatterns-Calypso'
}

{ #category : 'testing' }
BPatternFindPatternUsersCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isMethodSelected not
]

{ #category : 'activation' }
BPatternFindPatternUsersCommand class >> sourceCodeMenuActivation [
	<classAnnotation>

	^SycSourceCodeMenuActivation
		byItemOf: ClyQueryMenuGroup for: ClyMethodSourceCodeContext
]

{ #category : 'accessing' }
BPatternFindPatternUsersCommand >> defaultMenuIconName [
	^ #smallFind
]

{ #category : 'accessing' }
BPatternFindPatternUsersCommand >> defaultMenuItemName [

	^ 'Users of expression'
]

{ #category : 'accessing' }
BPatternFindPatternUsersCommand >> description [

	^ 'Finds all users of selected expression as a pattern'
]

{ #category : 'execution' }
BPatternFindPatternUsersCommand >> execute [
	| pattern |
	pattern := BPattern fromAST: sourceNode.
	browser spawnQueryBrowserOn: (BPatternMethodQuery withPattern: pattern)
]

{ #category : 'execution' }
BPatternFindPatternUsersCommand >> prepareFullExecutionInContext: aToolContext [

	super prepareFullExecutionInContext: aToolContext.
	browser := aToolContext browser
]
