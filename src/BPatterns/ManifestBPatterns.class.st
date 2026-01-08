"
BPattern is a scripting tool to search and rewrite the system using simple code examples defined by blocks.

BPatterns can be created using **#bpattern** message to a pattern block:

```
	| any anyBlock |
	[ any isNil ifTrue: anyBlock ] bpattern
```

Once you have a `BPattern` you can browse the system to find all matching methods:

```
	| any any2 |
	[ any isNil ifTrue: any2 ] bpattern browseUsers.
```

```
	| any |
	[ any printString asString ] bpattern browseUsersInClass: BPatternMethodQueryTest.
```

Using two BPatterns you can rewrite the matching methods:

```
	| any |
	[ 
		[ any printString asString ] -> [ any printString ] 
	] brewrite previewForClass: BPatternMethodQueryTest
```
See `BPatternRewrite` and `BPatternRewrite` class for more implementation details.

##Patterns configuration


The variables and selectors inside the pattern block can be used as a pattern to match particular AST nodes.
By default the following objects are automatically configured as **ANY** pattern to match any AST node:
- variables started with **any** word
- selectors where a keyword is started with **any** word

To narrow the filter represented by a pattern you have to configure it using **#with:** message:

```
	| anyVar anyBlock |
	[ anyVar isNil ifTrue: anyBlock ] bpattern with: [ anyVar ] -> [:pattern | pattern beVariable ]
```

Blocks are used for variables to lexically reference them instead of using raw string names. 
Here the **#anyVar** pattern name will match only variables which are receivers of **#isNil** message.
For example it will match the following expression: 

```
 	instVar isNil ifTrue: [ anotherVar printString ]
``` 

But it will not match an expression where the receiver is an another message send:

```
 	instVar someMessage isNil ifTrue: [ anotherVar printString ]
``` 

See other config methods of `BPatternVariableNode` for other options.

By using such a configuration for non default objects they will be converted to the pattern:

```
	| someVar anyBlock |
	[ someVar isNil ifTrue: anyBlock ] bpattern with: [ someVar ] -> [:pattern | pattern beVariable ]
```

Notice that without the config block the **#someVar** object would only match variables named **#someVar**.

The config block is optional and to enforce the pattern without extra settings you can just reference it:

```
	| someVar anyBlock |
	[ someVar isNil ifTrue: anyBlock ] bpattern with: [ someVar ]
```

In that case **#someVar** pattern will match **ANY** AST node like if it would be named **#anyVar**.

For the arguments of **#with:** message you can pass a block for variables, an association for a configuration or a symbol for a selector. And it can be an array of them:

```
	| any arg1 arg2 |
	[ any at: arg1 otherKeyword: arg2 ] bpattern 
		with: {[arg1. arg2] -> [:pattern | pattern beVariable]. #otherKeyword}
```

This example will match a message send with any receiver and variables as arguments and where a selector starts with **#at:** and an arbitrary second keyword (see **Selector Patterns**).

###Variable patterns

Patterns can be configured to match a particular type of variables:

```
	| anyVar anyBlock |
	[ anyVar do: anyBlock ] bpattern 
		with: [ anyVar ] -> [:pattern | pattern beInstVar ];
		with: [ anyBlock ] -> [:pattern | pattern beLocalVar ];
		browseUsers
```

And you can specify an arbitraty block filter using **#where:** message:

```
	| anyVar anyBlock |
	[ anyVar do: anyBlock ] bpattern 
		with: [ anyVar ] -> [:pattern | pattern beInstVar ];
		with: [ anyBlock ] -> [:pattern | pattern beLocalVar where: [:var | 
				(var name beginsWith: 'a') not]];
		browseUsers
```

For other options see `BPatternVariableNode`. Few examples here:

###Global variable patterns

Patterns can find message sends to globals:

```
	| any |
	[ any initialize ] bpattern 
		with: [ any ] -> [:pattern | pattern beGlobalVar ];
		browseUsers
```

And you can narrow filter by given set of values:

```
	| any anySize |
	[ any new: anySize ] bpattern 
		with: [ any ] -> [:pattern | pattern beGlobalVarWithAny: {Array. Set} ];
		with: [ anySize] -> [:pattern | pattern beLiteral ];
		browseUsers
```

###Undeclared variable patterns

Patterns can find undeclared variables:

```
	| any |
	[ any ] bpattern 
		with: [ any ] -> [:pattern | pattern beUndeclared ];
		browseUsers
```

###Literal patterns

Patterns can be configured to match literals:

```
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any. any2 ] -> [:pattern | pattern beLiteral ];
		browseUsers
```

This pattern will find all sum expressions with two literals.

To narrow the filter you can add a **#where:** predicate block to match the literal values by an arbitrary criteria:

```
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any. any2 ] -> [:pattern | pattern beLiteral where: [:value | value isInteger not ]];
		browseUsers
```

And you can also search for a particular list of literal values:

```
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any2 ] -> [:pattern | pattern beLiteralWithAny: #(2 3)];
		browseUsers
```

###Selector patterns

Selectors can be also used as patterns:

```
	| any anyArg1 anyArg2 |
	[ any at: anyArg1 anyOtherKeyword: anyArg2 ] bpattern
```

It will match any message sends with a selector started with #at: and any other second keyword. It does not require any configuration because **#anyOtherKeyword:** is started with any word.  

The **keyword selector** pattern matches any type of selectors with same number of arguments.
For example the following pattern will match any binary messages like 1 + 2 together with any one argument keywords:

```
	| any any2 |
	[ any anyMessage: any2 ] bpattern
```

To narrow the filter to the keyword type use **#beKeyword** config:

```
	| any any2 |
	[ any anyMessage: any2 ] bpattern with: #anyMessage: -> [:pattern | pattern beKeyword ].
```

To narrow the filter to the binary type use **#beBinary** config:

```
	| any any2 |
	[ any anyMessage: any2 ] bpattern with: #anyMessage: -> [:pattern | pattern beBinary ].
```

Or you can configure any binary selector as a pattern:

```
	| any any2 |
	[ any + any2 ] bpattern with: #+.
```

Both examples will match any binary message sends lile #+, #-, #=, etc..

To play a bit try to browse all binary messages where receiver and arguments are literals:

```
	| anyRcv anyArg |
	[ anyRcv + anyArg ] bpattern
		with: {#+. [ anyRcv. anyArg ] -> [:pattern | pattern beLiteral ]};
		browseUsers
```

###Unary selector patterns

The unary patterns are special. If an unary selector begins with **any** word it will match any type of messages (unary, binary and keyword) with any number of arguments. No need to reference arguments explicitly:

```
	[ instVar anyMessage printString ] bpattern
```

It will match expressions like:

```
	(instVar at: #key) printString.
	instVar variable anotherVariable printString.
	(instVar + 1) printString.
```

Unary patterns are usefull to describe an arbitrary message sends. For example you can find all super calls with subsequent message sends:

```
	[ super anySuperCall anyMessage ] bpattern browseUsers
```

If you need a pattern to match **the unary** type of messages you have to explicitly configure it:

```
	[ super anySuperCall anyMessage ] bpattern 
		with: #anyMessage -> [:pattern | pattern beUnary ];
		browseUsers
```

##BMethod

Patterns defined by **#bpattern** message does not allow to use method header. To represent a method with a full signature there are **#bmethod** expressions:

```
	| anyArg1 anyArg2 |
	[[ self anyMethodName: anyArg1 anyExtraKeyword: anyArg2 ] -> [ anyArg1 isNil ifTrue: anyArg2 ]] bmethod
```

Here the enclosing block of **#bmethod** returns an association of a pattern block for a method header and a pattern block for a method body. By convention the method header should contain single message send with any receiver. AST node for this message send is extracted as a pattern to describe the method header. The selector and arguments from the header message can be used inside the body pattern:


```
		| anyStatement |
		[[ self anyMessage ] -> [ anyStatement. super anyMessage ]] bmethod 
			browseUsers
```

This pattern will find all methods with a super call after any sequence of other statements.

The result of **#bmethod** is an instance of `BPattern` and therefore it can be used for the code search and for the rewrite:

```
	| stmts |
	[
		[[ self anyMessage ] -> [ stmts. self anyMessage ]] bmethod 
			->
		[[ self anyMessage ] -> [ [ stmts ] repeat ]] bmethod
	] brewrite
```
Here is a rewrite example which will find a simple recursion and replace it with a loop. The recursive call can be any kind of message send with any number of arguments.

"
Class {
	#name : 'ManifestBPatterns',
	#superclass : 'PackageManifest',
	#category : 'BPatterns-Manifest',
	#package : 'BPatterns',
	#tag : 'Manifest'
}
