---
title: SyntaxSparrow
description: helping to navigate SwiftSyntax tokens
date: 2023-06-12 10:00:00 +1000
categories: [ios, swift, tooling, open-source]
tags: []
image:
  path: /assets/img/posts/syntaxsparrow/cover.png
  alt: SyntaxSparrow
  lqip: data:image/webp;
---

*helping to navigate SwiftSyntax tokens*

SyntaxSparrow is a Swift library designed to facilitate the analysis and interaction with Swift source code. It leverages [Apple SwiftSyntax](https://github.com/apple/swift-syntax?ref=cheekyghost.com) to parse Swift code and produce a syntax tree that collects and traverses constituent declaration types for Swift code.

I wrote this as maintaining a fork of the now archived [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) project was becoming troublesome, primarily as I didn't write the original and I didn't have an in-depth enough knowledge of the [Apple SwiftSyntax](https://github.com/apple/swift-syntax?ref=cheekyghost.com) to add or maintain the library in a practical manner.

I also heavily used the [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) in [Mimic](https://cheekyghost.com/mimic/) - and when writing the upcoming MimicKit library. I found myself constantly tweaking things, making mistakes, and jumping between contexts. I needed a more maintainable solution, and now since [Swift introduced Macros](https://developer.apple.com/videos/play/wwdc2023/10167?ref=cheekyghost.com) (which will let me retire the Mimic extension in favour of macros), I wanted something that will let me focus on implementing tooling and features with a far more stable starting point.

![SyntaxSparrow](/assets/img/posts/syntaxsparrow/intro-diagram.png)

## Why?

[SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) was awesome, but being archived the only option is to fork and add features yourself, or hope someone has added your feature to their fork. [SyntaxSparrow](https://github.com/CheekyGhost-Labs/SyntaxSparrow?ref=cheekyghost.com) aims to pick up where this left off and add more support for conveniences, features, and hardening parsing where needed.

### MimicKit

The [Mimic Xcode Extension](https://cheekyghost.com/mimic/) was the initial mock generation product I wrote, however, it was never supposed to be the only related thing I was building. The core library "MimicKit" driving the application is something I always intended to open source. Previously MimicKit, and by proxy the Mimic extension, used the [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) library. So as I was adding functionality and tweaking the library I found myself wanting to solve the problems I found within the SwiftSemantics library more and more.

MimicKit also has a simple goal:

> To provide the code for spies, partial spies, and stubs with as little effort from the developer as possible

SyntaxSparrow plays a big part in this, as did SwiftSemantics, as my focus needed to be on building the code generation output rather than dealing with the nuances of talking to the [Apple SwiftSyntax](https://github.com/apple/swift-syntax?ref=cheekyghost.com) library directly. SwiftSyntax tokens are extensive and verbose, as they should be, but iterating and managing them can be tedious and annoying. As such, letting me focus on constituent types that enabled the MimicKit implementation goals was a logical choice.

SyntaxSparrow lets me leverage constituent semantic types, and from a maintenance perspective, has a clear separation of concerns between the publicly visible semantic type and the utility that assesses the Syntax node and children to resolve the expected details (name, parameters, keywords etc). This, in turn, lets me focus on what developers want to see in a tool like Mimic, and leverage Swift language features far more efficiently.

### Swift Language Feature

I was mid-proof of concept and proposal writing to add support for something like Mimic into the swift language. Ultimately I did not see it going ahead as it was more of an additive nice-to-have rather than a fundamental language feature, however, I wanted to explore what it would look like if developers could simply mark something along the lines of:

```swift
class MyTests: XCTestCase {

    @Spy var headerViewDelegate: HeaderViewDelegate
    ...
    func test_things() { 
        instanceUnderTest.didTapLogin() 
        XCTAssertEqual(headerViewDelegate.spy.didTapLoginCallCount, 1)
    }
}
```

Fortunately Macros now exist 🎉

### Macros

Swift recently announced and introduced Swift Macros at WWDC2023, and this changes things for me in the best way. I see Swift Macros as a way to add opt-in language features to developers without having to deal with adding tedious compiler steps and going through the swift evolution process.

**Note:** This is not to say the swift evolution process isn't good or constructive, but I am more focused on features from a tooling perspective. What I intend to provide with Mimic does not belong in the Swift language itself as a far better testing approach could be baked into the language.

So moving forward, MimicKit will be a Swift Package that offers Swift Macros developers can use in their code to avoid having to even run a script or extension to generate the spy/partial/stub outputs (if all goes well) 🥳

Fortunately, now that SyntaxSparrow is available, and I can add far more direct conveniences around the `SyntaxTree` instance, I can easily use it within the macro implementations to reduce the overhead of dealing with swift syntax nodes and tokens etc:

**Note:** This is contrived and does not reflect the eventual library in any manner 😅

```swift
import SwiftSyntax
import SyntaxSparrow

public struct VariableSpyMacro: PeerMacro {

    public static func expansion<
      Context: MacroExpansionContext,
      Declaration: DeclSyntaxProtocol
    >(
      of node: AttributeSyntax,
      providingPeersOf declaration: Declaration,
      in context: Context
    ) throws -> [DeclSyntax] {
        // Array as a VariableDeclSyntax can have multiple bindings
        let variables = SyntaxTree.declarations(of: Variable.self, fromSyntax: declaration)
        
        // Generate spy getters for each variable
        var results: [DeclSyntax] = []

        variables.forEach {
            results.append(contentsOf: [
                "var \(raw: $0.name)GetterCallCount: Int = 0",
                "var \(raw: $0.name)GetterParameterList: [\(raw: $0.type.description)] = []",
                "var \(raw: $0.name)GetterParameter: \(raw: $0.type.description)? { \(raw: $0.name)GetterParameterList.last }"
            ])
        }
        return results
    }
}
```

this would let a developer use the following:

```swift
@VariableSpy
var name: String
```

further reducing overhead and complexity.

A promising feature and this is also one of my immediate focuses.

## Core Overview

### SyntaxTree

The `SyntaxTree` type is the root entry point for the library. It essentially acts as a starting point for parsing raw source or existing Syntax node and collecting the supported declaration types.

For example:

```swift
let sourceCode = """
    enum Section {
        case summary
        case people
    }
    
    @available(*, unavailable, message: "my message")
    struct MyStruct {
        var name: String = "name"
    }
"""
let tree = SyntaxTree(viewMode: .fixedUp, sourceBuffer: sourceCode)
tree.collectChildren()
```

once collected, you can iterate through the supported declaration types:

```swift
for variable in tree.variables where variable.hasSetter {
    print("\(variable.name) of type `\(variable.type)` is mutable
}

tree.enumerations.forEach {
    print("enum \($0.name) has \($0.cases.count) cases")
}
```

The supported declarations, where relative, also support collecting children. This provides a hierarchical structure to work with:

```swift
let myEnum = tree.enumerations[0]

myEnum.structures.forEach { structure in
    print("\(myEnum.name) has nested struct named \(structure.name)")
    structure.classes.forEach { aClass in
        let parentName = "\(myEnum.name).\(structure.name)"
        print("-- \(parentName) has nested class \(aClass.name)")
    }
}
```

### Declaration

A `Declaration` is the public constituent type developers resolve and work with. It acts as a semantic type for more readable and maintainable code.

For example, if we take the output of a `FunctionDeclSyntax` from the following declaration:

```swift
func addPerson(withName name: String) throws {}
```

the token output would be:

```swift
FunctionDeclSyntax
├─funcKeyword: keyword(SwiftSyntax.Keyword.func)
├─identifier: identifier("addPerson")
├─signature: FunctionSignatureSyntax
│ ├─input: ParameterClauseSyntax
│ │ ├─leftParen: leftParen
│ │ ├─parameterList: FunctionParameterListSyntax
│ │ │ ╰─[0]: FunctionParameterSyntax
│ │ │   ├─firstName: identifier("withName")
│ │ │   ├─secondName: identifier("name")
│ │ │   ├─colon: colon
│ │ │   ╰─type: SimpleTypeIdentifierSyntax
│ │ │     ╰─name: identifier("String")
│ │ ╰─rightParen: rightParen
│ ╰─effectSpecifiers: FunctionEffectSpecifiersSyntax
│   ╰─throwsSpecifier: keyword(SwiftSyntax.Keyword.throws)
╰─body: CodeBlockSyntax
  ├─leftBrace: leftBrace
  ├─statements: CodeBlockItemListSyntax
  ╰─rightBrace: rightBrace
```

as you increase the complexity of the function, with multiple parameters, closures, tuples etc - the syntax node and token can become a bit unruly/tedious to deal with.

Using the resolved `Function` type that `SyntaxSparrow` provides, you can work with semantic goodness:

```swift
let function = tree.functions[0]
function.keyWord // func
function.identifier // addPerson
function.signature.returnType // nil
function.signature.effectSpecifiers?.throwsSpecifier // throws
function.signature.input // [SyntaxSparrow.Parameter]
function.signature.input[0].name // withName
function.signature.input[0].secondName // name
function.signature.input[0].type // EntityType.simple("String")
function.signature.input[0].isOptional // false
function.signature.input[0].isVariadic // false
function.signature.input[0].isInout // false
function.signature.input[0].isLabelOmitted // false
```

as you introduce more complex types to the function, you can start to see the benefit of dealing with more semantic types. Take the following function, which takes an optional tuple and closure parameter:

```swift
func addPerson(
    _ person: (name: String, age: Int)?, 
    _ completion: @escaping (Result<String, Error>) -> Void
) throws {}
```

the node structure is as follows:

```swift
FunctionDeclSyntax
├─funcKeyword: keyword(SwiftSyntax.Keyword.func)
├─identifier: identifier("addPerson")
├─signature: FunctionSignatureSyntax
│ ├─input: ParameterClauseSyntax
│ │ ├─leftParen: leftParen
│ │ ├─parameterList: FunctionParameterListSyntax
│ │ │ ├─[0]: FunctionParameterSyntax
│ │ │ │ ├─firstName: wildcard
│ │ │ │ ├─secondName: identifier("person")
│ │ │ │ ├─colon: colon
│ │ │ │ ├─type: OptionalTypeSyntax
│ │ │ │ │ ├─wrappedType: TupleTypeSyntax
│ │ │ │ │ │ ├─leftParen: leftParen
│ │ │ │ │ │ ├─elements: TupleTypeElementListSyntax
│ │ │ │ │ │ │ ├─[0]: TupleTypeElementSyntax
│ │ │ │ │ │ │ │ ├─name: identifier("name")
│ │ │ │ │ │ │ │ ├─colon: colon
│ │ │ │ │ │ │ │ ├─type: SimpleTypeIdentifierSyntax
│ │ │ │ │ │ │ │ │ ╰─name: identifier("String")
│ │ │ │ │ │ │ │ ╰─trailingComma: comma
│ │ │ │ │ │ │ ╰─[1]: TupleTypeElementSyntax
│ │ │ │ │ │ │   ├─name: identifier("age")
│ │ │ │ │ │ │   ├─colon: colon
│ │ │ │ │ │ │   ╰─type: SimpleTypeIdentifierSyntax
│ │ │ │ │ │ │     ╰─name: identifier("Int")
│ │ │ │ │ │ ╰─rightParen: rightParen
│ │ │ │ │ ╰─questionMark: postfixQuestionMark
│ │ │ │ ╰─trailingComma: comma
│ │ │ ╰─[1]: FunctionParameterSyntax
│ │ │   ├─firstName: wildcard
│ │ │   ├─secondName: identifier("completion")
│ │ │   ├─colon: colon
│ │ │   ╰─type: AttributedTypeSyntax
│ │ │     ├─attributes: AttributeListSyntax
│ │ │     │ ╰─[0]: AttributeSyntax
│ │ │     │   ├─atSignToken: atSign
│ │ │     │   ╰─attributeName: SimpleTypeIdentifierSyntax
│ │ │     │     ╰─name: identifier("escaping")
│ │ │     ╰─baseType: FunctionTypeSyntax
│ │ │       ├─leftParen: leftParen
│ │ │       ├─arguments: TupleTypeElementListSyntax
│ │ │       │ ╰─[0]: TupleTypeElementSyntax
│ │ │       │   ╰─type: SimpleTypeIdentifierSyntax
│ │ │       │     ├─name: identifier("Result")
│ │ │       │     ╰─genericArgumentClause: GenericArgumentClauseSyntax
│ │ │       │       ├─leftAngleBracket: leftAngle
│ │ │       │       ├─arguments: GenericArgumentListSyntax
│ │ │       │       │ ├─[0]: GenericArgumentSyntax
│ │ │       │       │ │ ├─argumentType: SimpleTypeIdentifierSyntax
│ │ │       │       │ │ │ ╰─name: identifier("String")
│ │ │       │       │ │ ╰─trailingComma: comma
│ │ │       │       │ ╰─[1]: GenericArgumentSyntax
│ │ │       │       │   ╰─argumentType: SimpleTypeIdentifierSyntax
│ │ │       │       │     ╰─name: identifier("Error")
│ │ │       │       ╰─rightAngleBracket: rightAngle
│ │ │       ├─rightParen: rightParen
│ │ │       ╰─output: ReturnClauseSyntax
│ │ │         ├─arrow: arrow
│ │ │         ╰─returnType: SimpleTypeIdentifierSyntax
│ │ │           ╰─name: identifier("Void")
│ │ ╰─rightParen: rightParen
│ ╰─effectSpecifiers: FunctionEffectSpecifiersSyntax
│   ╰─throwsSpecifier: keyword(SwiftSyntax.Keyword.throws)
╰─body: CodeBlockSyntax
  ├─leftBrace: leftBrace
  ├─statements: CodeBlockItemListSyntax
  ╰─rightBrace: rightBrace
```

so you can see it starts to become far more fun 🙃 - but dealing with it semantically is a bit more normal, especially when you need to work with the parameter types:

```swift
let function = tree.functions[0]

function.signature.input.forEach { param in
   switch param.type {

   case .tuple(let tuple):
       param.isOptional // true
       param.name // _
       param.secondName // person
       param.isLabelOmitted // true
       tuple.elements.count // 2
       tuple.isOptional // true
       tuple.elements[0].name // name
       tuple.elements[0].type // EntityType.simple("String")
       tuple.elements[1].isOptional // false
       tuple.elements[1].name // age
       tuple.elements[1].name // EntityType.simple("Int")
       tuple.elements[1].isOptional // false

   case .closure(let closure):
       param.isOptional // false
       param.name // _
       param.secondName // completion
       param.isLabelOmitted // true
       closure.isVoidOutput // true
       closure.output // EntityType.void
       closure.isVoidInput // false
       closure.isEscaping // true
       closure.input // EntityType.result(Result)
       closure.effectSpecifiers?.throwsSpecifier // nil

       if case let EntityType.result(result) = closure.input {
           result.successType // EntityType.simple("String")
           result.failureType // EntityType.simple("Error")
           result.isOptional // false
        }

   default:
      // other things
   }
}
```

### DeclarationComponent

A `DeclarationComponent` still represents a Syntax semantically, but for elements that support or decorate a `Declaration` type. For example, an attribute, accessor, modifiers, etc. It also is used to represent constituent types such as a `Closure`, `Tuple`, or `Result` etc

These component types are available on declarations as needed, for example if we take the following declaration:

```swift
@available(*, unavailable, message: "my message")
protocol AssociatedTypeProtocol {
    associatedtype A
    associatedtype B: Equatable
}
```

the resolved `ProtocolDecl` semantic type provides access to the `attributes` and `associatedTypes` :

```swift
let protocol = tree.protocols[0]

// Associated types
protocol.primaryAssociatedTypes.count // 0
protocol.associatedTypes.count // 2
protocol.associatedTypes[0].name // "A"
protocol.associatedTypes[0].inheritance // []
protocol.associatedTypes[1].name // "B"
protocol.associatedTypes[1].inheritance // ["Equatable"]

// Attributes
protocol.attributes.count // 1
protocol.attributes[0].name // "available"
protocol.attributes[0].arguments.count // 3
protocol.attributes[0].arguments[0].name // nil
protocol.attributes[0].arguments[0].value // "*"
protocol.attributes[0].arguments[1].name // nil
protocol.attributes[0].arguments[1].value // "unavailable"
protocol.attributes[0].arguments[2].name // "message"
protocol.attributes[0].arguments[2].value // "my message"
```

### EntityType

The `EntityType` is another core aspect within the library when representing the types of variables, parameters, typealias assignments, etc

It was introduced for two main reasons:

* To provide a consistent entry point for assessing a type
* To provide associated constituent `DeclarationComponent` types where relevant

For example, if you declare a function that takes a closure:

```swift
func executeOrder66(_ completion: @escaping () -> Void)
```

rather than having a dedicated `ClosureParameter` type and requiring generics, the `EntityType` supports the `closure` case, which will provide the underlying `Closure` representation as an associated value. This makes switching over the entity type and applying logic a lot more approachable:

```swift
switch parameter.type {
case .simple(let typeName):
    print("Simple type: \(typeName)")
    
case .tuple(let tuple):
    tuple.isOptional // true/false
    tuple.elements // Array of `Parameter` types

case .closure(let closure):
    closure.input // Entity Type
    closure.output // Entity Type
    closure.isEscaping // true/false
    closure.isAutoEscaping // true/false
    closure.isOptional // true/false
    closure.isVoidInput // true/false
    closure.isVoidOutput // true/false

case .result(let result):
    print(result.successType) // EntityType
    print(result.failureType) // EntityType

case .void(let rawType: let isOptional):
   print(rawType) // "Void" or "()?" etc

case .empty:
   print("undefined or partial")
}
```

The `EntityType` is also general enough to provide consistency, so it is used for:

* parameter types
* variable types
* tuple argument parameter types
* closure input/output types
* function return types
* typealias assignment types
* etc

I also introduced it for adding any additional support over time for new additions, or to expose additional features not currently supported by the library.

## Future Plans

SyntaxSparrow offers a solid starting point for my project goals related to parsing and analysing source code for various reasons. My goals moving forward are to align with latest -2 swift versions and continue to add support for some things that did not make the cut in the initial release. I also want to add more convenience to make it simple and intentful when resolving known declaration types and sets.

Some of the upcoming things I want to facilitate include:

* ResultBuilder type support
* Adding support for expression statements, such as `switch` and `if/else/` etc
* Add convenience helpers for working with Macros
* Implementation code additions (i.e localized string types, ternary statements etc)

While convenience and implementation code additions won't be at the top of my priority, I will get to them when I can. If someone else jumps in and adds them, that would be awesome too 😅

My main focus now is to add the structured concurrency keyword support, and to use this library with MimicKit to enable the mocking macro helpers I want to build.

If issues or bugs pop up during that process I will prioritise and fix them a.s.a.p

## Wrapping Up

So wrapping up, SyntaxSparrow offers a great starting point to working with the SwiftSyntax library that apple provide. It provides intentful and contextual semantic types that should make it far easier for developers when writing tooling or helpers (such as macros).

Before I go I did want to take a moment to shout out [NSHipster](https://nshipster.com/?ref=cheekyghost.com), who wrote the original [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) (now archived). SyntaxSparrow was obviously very heavily inspired by this library, and it offered great insight into node/token structure and approaches to parsing them. Was a great project and am glad I forked and worked with it before writing SyntaxSparrow as my efforts were made that little bit easier thanks to the awesome work done in SwiftSemantics ❤️

You can check out the repo here:

![SyntaxSparrow repository](/assets/img/posts/syntaxsparrow/repo-card.png)

or via [Swift Package Index here](https://swiftpackageindex.com/CheekyGhost-Labs/SyntaxSparrow):