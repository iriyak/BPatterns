Class {
	#name : 'BPatternTest',
	#superclass : 'TestCase',
	#category : 'BPatterns-Tests',
	#package : 'BPatterns-Tests'
}

{ #category : 'tests' }
BPatternTest >> testComparison [

	| bpattern anotherPattern |
	bpattern := [ #someBlock1 ] bpattern.
	self assert: bpattern = bpattern.
	self assert: bpattern copy = bpattern.
	self assert: bpattern copy hash equals: bpattern hash.
	
	anotherPattern := [ #anotherBlock ] bpattern.
	self deny: bpattern = anotherPattern
]

{ #category : 'tests' }
BPatternTest >> testComparisonForBMethodWithFilters [
	
	| bpattern anyRcv anyArg bpattern2 |
	bpattern := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: [ anyArg ] -> [ :pattern | pattern beArg where: [:var | var name beginsWith: 'a' ]];
		with: #someMethod: -> [:pattern | pattern beKeyword ].
	self assert: bpattern = bpattern.
	self assert: bpattern copy = bpattern.
	self assert: bpattern copy hash equals: bpattern hash.
	
	bpattern2 := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: [ anyArg ] -> [ :pattern | pattern beArg where: [:var | var name beginsWith: 'a' ]];
		with: #someMethod: -> [:pattern | pattern beKeyword ].
	self assert: bpattern = bpattern2.
	self assert: bpattern hash = bpattern2 hash.
	
	bpattern2 := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: [ anyArg ] -> [ :pattern | pattern beArg where: [:var | var name beginsWith: 'a' ]].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: [ anyArg ] -> [ :pattern | pattern beArg where: [:var | var name beginsWith: 'some' ]];
		with: #someMethod: -> [:pattern | pattern beKeyword ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: [ anyArg ] -> [ :pattern | pattern beArg where: [:var | var name beginsWith: 'a' ]];
		with: #someMethod: -> [:pattern | pattern beBinary ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [[self someMethod: anyArg] -> [ anyRcv anyMessage: anyArg ]] bmethod 
		with: #someMethod: -> [:pattern | pattern beKeyword ].
	self deny: bpattern = bpattern2
]

{ #category : 'tests' }
BPatternTest >> testComparisonWithFilters [
	
	| bpattern anyRcv anyArg bpattern2 |
	bpattern := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: [ anyArg ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'a' ]];
		with: #anyMessage: -> [:pattern | pattern beKeyword ].
	self assert: bpattern = bpattern.
	self assert: bpattern copy = bpattern.
	self assert: bpattern copy hash equals: bpattern hash.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: [ anyArg ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'a' ]];
		with: #anyMessage: -> [:pattern | pattern beKeyword ].
	self assert: bpattern = bpattern2.
	self assert: bpattern hash = bpattern2 hash.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: [ anyArg ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'a' ]].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: #anyMessage: -> [:pattern | pattern beKeyword ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: [ anyArg ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'abc' ]];
		with: #anyMessage: -> [:pattern | pattern beKeyword ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
		with: [ anyRcv ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'prim' ]];
		with: [ anyArg ] -> [ :pattern | pattern beInstVar where: [:var | var name beginsWith: 'a' ]];
		with: #anyMessage: -> [:pattern | pattern beKeyword ];
		with: #anyMessage: -> [:pattern | pattern where: [ :node | node selector beginsWith: 'some' ]].
	self deny: bpattern = bpattern2
]

{ #category : 'tests' }
BPatternTest >> testComparisonWithPatternModifiers [
	
	| bpattern anyRcv anyArg bpattern2 |
	bpattern := [ anyRcv anyMessage: anyArg ] bpattern.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern with: [ anyRcv ] -> [ :pattern | pattern beLiteral ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern with: [ anyRcv ] -> [ :pattern | pattern beVariable ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
						with: [ anyRcv ] -> [ :pattern | pattern beStatement ].
	self deny: bpattern = bpattern2.
	
	bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
						with: #anyMessage: -> [ :pattern | pattern beSelectorList ].
	self deny: bpattern = bpattern2.
	
bpattern2 := [ anyRcv anyMessage: anyArg ] bpattern 
						with: #anyMessage: -> [ :pattern | pattern beCascadeList ].
	self deny: bpattern = bpattern2.
]

{ #category : 'tests' }
BPatternTest >> testConfigurationMultipleTimesAfterApply [
	
	| bpattern rcv arg  pattern |
	bpattern := [ rcv anyMessage: arg ] bpattern with: [ rcv ].
	pattern := bpattern patternAST variableNodes detect: [:node| node name = 'arg' ].
	self deny: pattern isPatternNode.
	
	bpattern with: [ arg ].
	pattern := bpattern patternAST variableNodes detect: [:node| node name = 'arg' ].
	self assert: pattern isPatternNode.
]

{ #category : 'tests' }
BPatternTest >> testCopy [
	
	| bpattern anyRcv anyArg copy |
	bpattern := [ anyRcv anyMessage: anyArg ] bpattern.
	copy := bpattern copy.
	self deny: bpattern patternAST identicalTo: copy patternAST.
	self assert: bpattern patternAST = copy patternAST.
]

{ #category : 'tests' }
BPatternTest >> testDisplayString [

	| actual pattern anyRcv anyArg |
	pattern := [ anyRcv someMessage: anyArg ] bpattern.
	actual := pattern displayString.
	
	self assert: actual equals: 'anyRcv someMessage: anyArg'
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodShouldNotModifyOriginalASTOfMethod [
	| block anyBody |
	block := [[ self anyMethod ] -> [ anyBody ]].
	block bmethod.
	
	block sourceNode variableNodes do: [:each | 
		self deny: each  isPatternNode "original AST was not modified"
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithConfiguredKeywordPattern [
	| bpattern allVarNodes patternVarNodes anyArg anyArg2 |
	bpattern := [[ self patternPart: anyArg nonPatternPart: anyArg2 ] -> [ ^anyArg printString ]] 
					bmethod with: #patternPart:.
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #(#patternPart:).
	self assert: bpattern patternAST selector equals: #patternPart:nonPatternPart:.
	self assert: bpattern patternAST argumentNames equals: #('anyArg' 'anyArg2').
	self assert: bpattern patternAST body class equals: OCSequenceNode.
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | #('anyArg' 'anyArg2') includes: each name ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithConfiguredUnarySelectorPattern [
	| bpattern |
	bpattern := [[ self someMessage ] -> [ super someMessage ]] bmethod with: #someMessage.
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('someMessage').
	self assert: bpattern patternAST selector equals: #someMessage.
	self assert: bpattern patternAST isSelectorList.
	self assert: bpattern patternAST body sendNodes first selector equals: #someMessage.
	self assert: bpattern patternAST body sendNodes first isPatternNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('someMessage').
	self assert: bpattern patternAST body sendNodes first isSelectorList.	
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithConfiguredUnarySelectorPatternInNonListMode [
	| bpattern |
	bpattern := [[ self someMessage ] -> [ super someMessage ]] bmethod
					with: #someMessage -> [:pattern | pattern beUnary ].
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('someMessage').
	self assert: bpattern patternAST selector equals: #someMessage.
	self deny: bpattern patternAST isSelectorList.
	self assert: bpattern patternAST body sendNodes first selector equals: #someMessage.
	self assert: bpattern patternAST body sendNodes first isPatternNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('someMessage').
	self deny: bpattern patternAST body sendNodes first isSelectorList.	
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithDefaultKeywordPattern [
	| bpattern allVarNodes patternVarNodes anyArg anyArg2 |
	bpattern := [[ self anyMessage: anyArg nonPatternPart: anyArg2 ] -> [ ^anyArg printString ]] bmethod.
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('anyMessage:').
	self assert: bpattern patternAST selector equals: #anyMessage:nonPatternPart:.
	self assert: bpattern patternAST argumentNames equals: #('anyArg' 'anyArg2').
	self assert: bpattern patternAST body class equals: OCSequenceNode.
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | #('anyArg' 'anyArg2') includes: each name ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithDefaultUnarySelectorPattern [
	| bpattern |
	bpattern := [ [ self anyMessage ] -> [ super anyMessage ]] bmethod. 
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('anyMessage').
	self assert: bpattern patternAST selector equals: #anyMessage.
	self assert: bpattern patternAST isSelectorList.
	self assert: bpattern patternAST body sendNodes first selector equals: #anyMessage.
	self assert: bpattern patternAST body sendNodes first isPatternNode.
	self assert: bpattern patternAST patternKeywords asArray equals: #('anyMessage').
	self assert: bpattern patternAST body sendNodes first isSelectorList.	
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithMultipleStatements [
	| bpattern arg stmps |
	bpattern := [[ self someMessage: arg ] -> [ stmps.  ^arg printString ]] bmethod.
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST body class equals: OCSequenceNode.
	self assert: bpattern patternAST body statements size equals: 2.
]

{ #category : 'tests' }
BPatternTest >> testFromBMethodWithoutSelectorPatterns [
	| bpattern allVarNodes patternVarNodes anyArg |
	bpattern := [ [ self someMessage: anyArg ] -> [ ^anyArg printString ]] bmethod. 
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST class equals: BPatternMethodNode.
	self deny: bpattern patternAST isSelectorList.
	self assert: bpattern patternAST patternKeywords isEmpty.
	self assert: bpattern patternAST selector equals: #someMessage:.
	self assert: bpattern patternAST argumentNames equals: #('anyArg').
	self assert: bpattern patternAST body temporaries size equals: 1.
	self assert: bpattern patternAST body temporaries first isPatternNode.
	self assert: bpattern patternAST body temporaries first isList.
	self assert: bpattern patternAST body class equals: OCSequenceNode.
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'anyArg' ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockShouldNotModifyOriginalASTOfMethod [

	| block any |
	block := [ any ].
	block bpattern.
	
	block sourceNode variableNodes do: [:each | 
		self deny: each isPatternNode "original AST was not modified"
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithCascadeMessages [

	| bpattern allVarNodes patternVarNodes any |
	bpattern := [ any printString; asString] bpattern.
	
	self assert: bpattern patternAST isCascade.
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'any' ].
	self assert: patternVarNodes size equals: 2.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithConfiguredSelectorPattern [

	| bpattern allMessages patternMessage any1 any2 |
	bpattern := [ self nonPatternPart: any1 patternSuffix: any2. any1 printString ]
						bpattern with: #patternSuffix:.
	
	allMessages := bpattern patternAST sendNodes.
	patternMessage := allMessages first.
	self assert: patternMessage isPatternNode.
	self assert: patternMessage patternKeywords asArray equals: #('patternSuffix:').
	self deny: allMessages second isPatternNode
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithConfiguredVarPattern [

	| bpattern allVarNodes patternVarNodes patternTemp |
	bpattern := [ | nonPatternVar | patternTemp isNil ifFalse: [ patternTemp printString. nonPatternVar ]]
						bpattern with: [ patternTemp ].
	
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'patternTemp' ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
		self assert: each isAnything.	
	].	 
	(allVarNodes copyWithoutAll: patternVarNodes) do: [ :each |
			self deny: each isPatternNode 
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithDefaultSelectorPattern [

	| bpattern allMessages patternMessage a b |
	bpattern := [ self nonPatternPart: a anySuffix: b. a printString ] bpattern.
	
	allMessages := bpattern patternAST sendNodes.
	patternMessage := allMessages first.
	self assert: patternMessage isPatternNode.
	self assert: patternMessage patternKeywords asArray equals: #('anySuffix:').
	self deny: allMessages second isPatternNode
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithDefaultUnarySelectorPattern [

	| bpattern anyVar varNode |
	bpattern := [ anyVar anySelector ] bpattern.
	
	varNode :=  bpattern patternAST sendNodes first.
	self assert: varNode isPatternNode.
	self assert: varNode isSelectorList.
	self assert: varNode patternKeywords asArray equals: #('anySelector')
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithDefaultVarPattern [ 

	| bpattern block allVarNodes patternVarNodes any |
	block := [| nonPatternTemp | nonPatternTemp := any isNil ifFalse: [ any printString ]].
	bpattern := block bpattern.
	
	self assert: bpattern class equals: BPattern.
	self assert: bpattern patternAST sourceCode equals: block sourceNode body sourceCode.
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'any' ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
		self assert: each isList.
		self assert: each isAnything.
	].	 
	(allVarNodes copyWithoutAll: patternVarNodes) do: [ :each |
			self deny: each isPatternNode 
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithVarPatternConfigBlock [

	| bpattern allVarNodes patternVarNodes patternTemp |
	bpattern := [ | nonPatternVar | patternTemp isNil ifFalse: [ patternTemp printString. nonPatternVar ]]
						bpattern with: [ patternTemp ] -> [:pattern | pattern beVariable ].
	
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'patternTemp' ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
		self deny: each isAnything.
		self deny: each isStatement.
	].	 
	(allVarNodes copyWithoutAll: patternVarNodes) do: [ :each |
			self deny: each isPatternNode 
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithVarPatternConfiguredByStringVarName [

	| bpattern allVarNodes patternVarNodes nonPatternVar patternVar |
	bpattern := [ nonPatternVar isNil ifFalse: [ patternVar printString. nonPatternVar ]]
						bpattern with: 'patternVar'.
	
	allVarNodes :=  bpattern patternAST variableNodes.
	patternVarNodes := allVarNodes select: [:each | each name = 'patternVar' ].
	self assert: patternVarNodes notEmpty.
	patternVarNodes do: [:each | 
		self assert: each isPatternNode.
		self assert: each isAnything.	
	].	 
	(allVarNodes copyWithoutAll: patternVarNodes) do: [ :each |
			self deny: each isPatternNode 
	]
]

{ #category : 'tests' }
BPatternTest >> testFromBlockWithVarPatternInsideDynamicArray [
	| bpattern any varNode |
	bpattern := [ {any} printString ] bpattern.
	
	varNode :=  bpattern patternAST variableNodes first.
	self assert: varNode isPatternNode.
	self deny: varNode isList.
	self assert: varNode isStatement.
]

{ #category : 'tests' }
BPatternTest >> testPrinting [

	| actual pattern anyRcv anyArg |
	pattern := [ anyRcv someMessage: anyArg ] bpattern.
	actual := pattern printString.
	
	self assert: actual equals: 'a BPattern(anyRcv someMessage: anyArg)'
]

{ #category : 'tests' }
BPatternTest >> testRewriteASTWithConfiguredPatternVars [
	| searchPattern rewritePattern originalBlock rewrittenAST rewrittenCode expectedResult some |
	searchPattern := [ some isNil ifFalse: [ some printString ]] bpattern with: [ some ].
	rewritePattern := [ some ifNotNil: [ some printString ]] bpattern with: [ some ].
	originalBlock := [:someTemp | someTemp isNil ifFalse: [ someTemp printString ]].
	rewrittenAST := searchPattern rewriteAST: originalBlock sourceNode with: rewritePattern.
	rewrittenCode := rewrittenAST formattedCode.
	expectedResult := [:someTemp | someTemp ifNotNil: [ someTemp printString ]] sourceNode formattedCode.
	self assert: rewrittenCode equals: expectedResult
]

{ #category : 'tests' }
BPatternTest >> testRewriteASTWithDefaultPatternVars [
	| searchPattern rewritePattern originalBlock rewrittenAST rewrittenCode expectedResult any |
	searchPattern := [ any isNil ifFalse: [ any printString ]] bpattern.
	rewritePattern := [ any ifNotNil: [ any printString ]] bpattern.
	originalBlock := [:someTemp | someTemp isNil ifFalse: [ someTemp printString ]].
	rewrittenAST := searchPattern rewriteAST: originalBlock sourceNode with: rewritePattern.
	rewrittenCode := rewrittenAST formattedCode.
	expectedResult := [:someTemp | someTemp ifNotNil: [ someTemp printString ]] sourceNode formattedCode.
	self assert: rewrittenCode equals: expectedResult

]

{ #category : 'tests' }
BPatternTest >> testScanAST [
	| patternBlock pattern searchScopeBlock matchingNode matchingVars patternVar any |
	patternBlock := [ any isNil ifFalse: [ any printString ]].
	pattern := patternBlock bpattern.
	searchScopeBlock := [:someVar | someVar isNil ifFalse: [ someVar printString ]. self printString].

	pattern scanAST: searchScopeBlock sourceNode do: [:node :context | matchingNode := node. matchingVars := context copy ].
	
	patternVar := pattern patternAST variableNodes first.
	self assert: patternVar name equals: 'any'.
	self assert: (matchingVars at: patternVar) equals: searchScopeBlock sourceNode variableNodes first.
	self assert: matchingNode equals: searchScopeBlock sourceNode statements first.
]
