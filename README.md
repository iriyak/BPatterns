# BPatterns

[![GitHub release](https://img.shields.io/github/release/dionisiydk/BPatterns.svg)](https://github.com/dionisiydk/BPatterns/releases/latest)
[![Unit Tests](https://github.com/dionisiydk/BPatterns/actions/workflows/tests.yml/badge.svg)](https://github.com/dionisiydk/BPatterns/actions/workflows/tests.yml)
[![Pharo 13](https://img.shields.io/badge/Pharo-13-informational)](https://pharo.org)
[![Pharo 14-alpha](https://img.shields.io/badge/Pharo-alpha-informational)](https://pharo.org)

Scripting tool to search and rewrite the system using simple code examples defined by blocks (**B** is for block patterns). It is based on the original Smalltalk rewrite engine but it does not require special syntax. 

## Installation

```Smalltalk
Metacello new
  baseline: 'BPatterns';
  repository: 'github://dionisiydk/BPatterns:main';
  load
```

## Overview

BPatterns can be created using **#bpattern** message to a pattern block:

```Smalltalk
	| any anyBlock |
	[ any isNil ifTrue: anyBlock ] bpattern
```

Once you have a `BPattern` you can browse the system to find all matching methods:

```Smalltalk
	| any any2 |
	[ any isNil ifTrue: any2 ] bpattern browseUsers.
```

<img width="1095" height="464" alt="Screenshot 2026-01-08 at 18 43 10" src="https://github.com/user-attachments/assets/3a392fdc-a34c-470f-970b-5c23e85a869d" />

Or you can scope it for a single class:

```Smalltalk
	| any |
	[ any printString asString ] bpattern browseUsersInClass: BPatternMethodQueryTest.
```

<img width="1033" height="313" alt="Screenshot 2026-01-08 at 18 44 34" src="https://github.com/user-attachments/assets/b39068f8-dec0-457d-8e65-c7bd45df64c6" />

Using two BPatterns you can rewrite the matching methods:

```Smalltalk
	| any |
	[ 
		[ any printString asString ] -> [ any printString ] 
	] brewrite previewForClass: BPatternMethodQueryTest
```

<img width="697" height="498" alt="Screenshot 2026-01-08 at 21 19 43" src="https://github.com/user-attachments/assets/df2fca06-aa6e-46e4-8d45-432492d95af0" />

See `BPatternRewrite` and `BPatternRewrite` class for more implementation details.

## Patterns configuration

The variables and selectors inside the pattern block can be used as a pattern to match particular AST nodes.
By default the following objects are automatically configured as **ANY** pattern to match any AST node:
- variables started with **any** word
- selectors where a keyword is started with **any** word

To narrow the filter represented by a pattern you have to configure it using **#with:** message:

```Smalltalk
	| anyVar anyBlock |
	[ anyVar isNil ifTrue: anyBlock ] bpattern with: [ anyVar ] -> [:pattern | pattern beVariable ]
```

Blocks are used for variables to lexically reference them instead of using raw string names. 
Here the **#anyVar** pattern name will match only variables which are receivers of **#isNil** message.
For example it will match the following expression: 

```Smalltalk
 	instVar isNil ifTrue: [ anotherVar printString ]
``` 

But it will not match an expression where the receiver is an another message send:

```Smalltalk
 	instVar someMessage isNil ifTrue: [ anotherVar printString ]
``` 

See other config methods of `BPatternVariableNode` for other options.

By using such a configuration for non default objects they will be converted to the pattern:

```Smalltalk
	| someVar anyBlock |
	[ someVar isNil ifTrue: anyBlock ] bpattern with: [ someVar ] -> [:pattern | pattern beVariable ]
```

Notice that without the config block the **#someVar** object would only match variables named **#someVar**.

The config block is optional and to enforce the pattern without extra settings you can just reference it:

```Smalltalk
	| someVar anyBlock |
	[ someVar isNil ifTrue: anyBlock ] bpattern with: [ someVar ]
```

In that case **#someVar** pattern will match **ANY** AST node like if it would be named **#anyVar**.

For the arguments of **#with:** message you can pass a block for variables, an association for a configuration or a symbol for a selector. And it can be an array of them:

```Smalltalk
	| any arg1 arg2 |
	[ any at: arg1 otherKeyword: arg2 ] bpattern 
		with: {[arg1. arg2] -> [:pattern | pattern beVariable]. #otherKeyword}
```

This example will match a message send with any receiver and variables as arguments and where a selector starts with **#at:** and an arbitrary second keyword (see **Selector Patterns**).

### Variable patterns

Patterns can be configured to match a particular type of variables:

```Smalltalk
	| anyVar anyBlock |
	[ anyVar do: anyBlock ] bpattern 
		with: [ anyVar ] -> [:pattern | pattern beInstVar ];
		with: [ anyBlock ] -> [:pattern | pattern beLocalVar ];
		browseUsers
```

<img width="1010" height="505" alt="Screenshot 2026-01-08 at 21 47 13" src="https://github.com/user-attachments/assets/36b863a8-dda3-4759-8a67-c686a08414e6" />


And you can specify an arbitraty block filter using **#where:** message:

```Smalltalk
	| anyVar anyBlock |
	[ anyVar do: anyBlock ] bpattern 
		with: [ anyVar ] -> [:pattern | pattern beInstVar ];
		with: [ anyBlock ] -> [:pattern | pattern beLocalVar where: [:var | 
				(var name beginsWith: 'a') not]];
		browseUsers
```

<img width="986" height="494" alt="Screenshot 2026-01-08 at 21 52 02" src="https://github.com/user-attachments/assets/60afe9f2-0fb0-4390-9120-b4c7451580d0" />

For other options see `BPatternVariableNode`. Few examples here:

### Global variable patterns

Patterns can find message sends to globals:

```Smalltalk
	| any |
	[ any initialize ] bpattern 
		with: [ any ] -> [:pattern | pattern beGlobalVar ];
		browseUsers
```

<img width="1017" height="551" alt="Screenshot 2026-01-08 at 21 54 42" src="https://github.com/user-attachments/assets/7a1b51ef-c7d2-4b0a-bb9e-9b7a660ccb9a" />

And you can narrow filter by given set of values:

```Smalltalk
	| any anySize |
	[ any new: anySize ] bpattern 
		with: [ any ] -> [:pattern | pattern beGlobalVarWithAny: {Array. Set} ];
		with: [ anySize] -> [:pattern | pattern beLiteral ];
		browseUsers
```

<img width="949" height="512" alt="Screenshot 2026-01-08 at 22 00 19" src="https://github.com/user-attachments/assets/3b32a99c-ea34-4cd5-9ae8-5bad0d79ee7a" />

### Undeclared variable patterns

Patterns can find undeclared variables:

```Smalltalk
	| any |
	[ any ] bpattern 
		with: [ any ] -> [:pattern | pattern beUndeclared ];
		browseUsers
```

<img width="984" height="499" alt="Screenshot 2026-01-08 at 22 03 32" src="https://github.com/user-attachments/assets/b3c61a94-d0fb-47b7-ac43-56af4ab9957e" />

### Literal patterns

Patterns can be configured to match literals:

```Smalltalk
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any. any2 ] -> [:pattern | pattern beLiteral ];
		browseUsers
```

This pattern will find all sum expressions with two literals.

<img width="899" height="493" alt="Screenshot 2026-01-08 at 22 05 23" src="https://github.com/user-attachments/assets/6d1e1efc-9cbd-427d-beb3-5acdb2700c8b" />

To narrow the filter you can add a **#where:** predicate block to match the literal values by an arbitrary criteria:

```Smalltalk
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any. any2 ] -> [:pattern | pattern beLiteral where: [:value | value isInteger not ]];
		browseUsers
```

<img width="1019" height="522" alt="Screenshot 2026-01-08 at 22 07 55" src="https://github.com/user-attachments/assets/ff3a3134-c9f4-4740-a386-6bd6cf4bc3f0" />

And you can also search for a particular list of literal values:

```Smalltalk
	| any any2 |
	[ any + any2 ] bpattern 
		with: [ any2 ] -> [:pattern | pattern beLiteralWithAny: #(2 3)];
		browseUsers
```

<img width="1007" height="544" alt="Screenshot 2026-01-08 at 22 10 20" src="https://github.com/user-attachments/assets/5e044e31-e567-49e9-a22d-616dd5aef403" />

### Selector patterns

Selectors can be also used as patterns:

```Smalltalk
	| any anyArg1 anyArg2 |
	[ any at: anyArg1 anyOtherKeyword: anyArg2 ] bpattern
```

It will match any message sends with a selector started with #at: and any other second keyword. It does not require any configuration because **#anyOtherKeyword:** is started with any word.  

The **keyword selector** pattern matches any type of selectors with same number of arguments.
For example the following pattern will match any binary messages like 1 + 2 together with any one argument keywords:

```Smalltalk
	| any any2 |
	[ any anyMessage: any2 ] bpattern
```

To narrow the filter to the keyword type use **#beKeyword** config:

```Smalltalk
	| any any2 |
	[ any anyMessage: any2 ] bpattern with: #anyMessage: -> [:pattern | pattern beKeyword ].
```

To narrow the filter to the binary type use **#beBinary** config:

```Smalltalk
	| any any2 |
	[ any anyMessage: any2 ] bpattern with: #anyMessage: -> [:pattern | pattern beBinary ].
```

Or you can configure any binary selector as a pattern:

```Smalltalk
	| any any2 |
	[ any + any2 ] bpattern with: #+.
```

Both examples will match any binary message sends lile #+, #-, #=, etc..

To play a bit try to browse all binary messages where receiver and arguments are literals:

```Smalltalk
	| anyRcv anyArg |
	[ anyRcv + anyArg ] bpattern
		with: {#+. [ anyRcv. anyArg ] -> [:pattern | pattern beLiteral ]};
		browseUsers
```

<img width="1004" height="443" alt="Screenshot 2026-01-08 at 22 13 56" src="https://github.com/user-attachments/assets/52768459-bd0a-4239-b3a3-8847ab25c3d1" />

### Unary selector patterns

The unary patterns are special. If an unary selector begins with **any** word it will match any type of messages (unary, binary and keyword) with any number of arguments. No need to reference arguments explicitly:

```Smalltalk
	[ instVar anyMessage printString ] bpattern
```

It will match expressions like:

```Smalltalk
	(instVar at: #key) printString.
	instVar variable anotherVariable printString.
	(instVar + 1) printString.
```

Unary patterns are useful to describe an arbitrary message sends. For example you can find all super calls with subsequent message sends:

```Smalltalk
	[ super anySuperCall anyMessage ] bpattern browseUsers
```

<img width="912" height="494" alt="Screenshot 2026-01-08 at 22 17 43" src="https://github.com/user-attachments/assets/6434bb75-d2a7-4871-99bd-2464e6873cfe" />

If you need a pattern to match **the unary** type of messages you have to explicitly configure it:

```Smalltalk
	[ super anySuperCall anyMessage ] bpattern 
		with: #anyMessage -> [:pattern | pattern beUnary ];
		browseUsers
```

<img width="948" height="459" alt="Screenshot 2026-01-11 at 15 55 04" src="https://github.com/user-attachments/assets/89cfc8b7-c9e9-4fa9-b54d-c0987cbac077" />

Notice this example shows many cascades where second message is not unary. 

<img width="950" height="461" alt="Screenshot 2026-01-11 at 15 50 10" src="https://github.com/user-attachments/assets/85306e33-79f9-4d9c-8715-08cb8b565b82" />

In all these cases the last part of the cascade chain is #yourself which matches the criteria as an unary message sent to the original super call. To exclude #yourself cases you can add an additional **#where**: filter:
 
```Smalltalk
	[ super anySuperCall anyMessage ] bpattern 
		with: #anyMessage -> [:pattern | pattern beUnary where: [:node | node selector ~~ #yourself ]];
		browseUsers
```

<img width="951" height="452" alt="Screenshot 2026-01-11 at 16 01 17" src="https://github.com/user-attachments/assets/8a67c865-48ab-4406-8f66-59f8132e0046" />

Or you can fully exclude cascades:

```Smalltalk
	[ super anySuperCall anyMessage ] bpattern 
		with: #anyMessage -> [:pattern | pattern beUnary where: [:node | node isCascaded not ]];
		browseUsers
```

## BMethod

Patterns defined by **#bpattern** message does not allow to use method header. To represent a method with a full signature there are **#bmethod** expressions:

```Smalltalk
	| anyArg1 anyArg2 |
	[[ self anyMethodName: anyArg1 anyExtraKeyword: anyArg2 ] -> [ anyArg1 isNil ifTrue: anyArg2 ]] bmethod
```

Here the enclosing block of **#bmethod** returns an association of a pattern block for a method header and a pattern block for a method body. By convention the method header should contain single message send with any receiver. AST node for this message send is extracted as a pattern to describe the method header. The selector and arguments from the header message can be used inside the body pattern:


```Smalltalk
		| anyStatement |
		[[ self anyMessage ] -> [ anyStatement. super anyMessage ]] bmethod 			
			browseUsers
```

This pattern will find all methods with a super call after any sequence of other statements.

<img width="993" height="547" alt="Screenshot 2026-01-08 at 22 37 51" src="https://github.com/user-attachments/assets/ab2cbd26-41a7-49a6-9b66-9ae83c2df98a" />

The result of **#bmethod** is an instance of `BPattern` and therefore it can be used for the code search and for the rewrite:

```Smalltalk
	| stmts |
	[
		[[ self anyMessage ] -> [ stmts. self anyMessage ]] bmethod 
			->
		[[ self anyMessage ] -> [ [ stmts ] repeat ]] bmethod
	] brewrite
```
Here is a rewrite example which will find a simple recursion and replace it with a loop. The recursive call can be any kind of message send with any number of arguments.
