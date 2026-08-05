---
title: IndexStore for Swift
description: because IndexStoreDB is a fickle beast
date: 2023-05-04 10:00:00 +1000
categories: [ios, swift, tooling, open-source]
tags: []
image:
  path: /assets/img/posts/indexstore-for-swift/cover.png
  alt: IndexStore for Swift
  lqip: data:image/webp;
---

*because IndexStoreDB is a fickle beast*

While writing the upcoming `MimicKit` library, I migrated to using [**Apple's IndexStoreDB**](https://github.com/apple/indexstore-db?ref=cheekyghost.com) to perform any source resolving and lookups as it is much faster and more accurate than manually searching through raw source files. At a point, I found it was more tenable to move this logic to it's own library as I will also be using it for other tooling and projects.

So, introducing [**IndexStore**](https://github.com/CheekyGhost-Labs/IndexStore): A swift library providing a query-based approach for searching for and working with Apple's indexstore-db library:

![IndexStore for Swift](/assets/img/posts/indexstore-for-swift/intro-diagram.png)

## IndexStore

### an overview

When writing the original [**Mimic**](https://cheekyghost.com/mimic/) app/extension, the core library driving it relied on manual searching of source files to find matching class/protocol declarations. It then looked up inheritance by parsing it with SwiftSemantics, and manually searched for inheritance types, parsed them, and so on.

While working on the upcoming MimicKit library (set to release within the next 2 weeks), I switched to using [**Apple's IndexStoreDB library**](https://github.com/apple/indexstore-db?ref=cheekyghost.com) for symbol searching, as it is much more accurate and efficient. At some point, my colleagues and I wanted to use `IndexStoreDB` to create static analysis tools. As a result, I decided to extract the abstraction I had written into its own library, which offered some convenient features and future expansion possibilities. It was a no-brainer to maintain it as a standalone library.

Ultimately, the concept is straightforward:

* Provide an abstracted interface for easy setup of an IndexStoreDB instance
* Automatically resolve the derived data path based on the current project directory
* Use `xcode-select` to resolve the libIndexStore path (within Xcode)
* Use `ProcessInfo()` to resolve index store database paths (for swift and xcode)
* Provide a simple and intentful query tool for performing queries
* Test the heck out of it 😅

The development took approximately 2-3 weeks to get it to an open source state, much longer than the 1 week I wanted it to take.

## IndexStoreDB

### An overview

As noted earlier, this library is built on top of [**Apple's IndexStoreDB**](https://github.com/apple/indexstore-db?ref=cheekyghost.com). It's important to note that the indexstore-db library itself is not well documented, and it relies on a lot of assumed knowledge from an [**Indexing Whitepaper**](https://docs.google.com/document/d/1cH2sTpgSnJZCkZtJl1aY-rzy4uGPcrI-6RrUpdATO2Q/?ref=cheekyghost.com). The library was built to index data produced by compilers such as Apple Clang and Swift. The main mechanism that IndexStoreDB uses to enable efficient querying of this data is by maintaining acceleration tables in a key-value database built with LMDB.

The `IndexStoreDB` library provides two important types for working with code symbols: `Symbol` and `SymbolOccurrence`. These types help developers to analyze and understand the structure and relationships within their codebase, making it easier to build developer tools and perform code analysis tasks:

### Symbol:

A `Symbol` represents an element in your code, such as a class, function, or variable. It contains essential information about the element, including its unique identifier (USR), name, and kind (e.g., class, function, variable, etc.). The `Symbol` type enables you to access high-level information about a code element, which is useful for navigating your codebase, understanding the structure of your code, and performing various analysis tasks.

### SymbolOccurence:

A `SymbolOccurrence` represents a specific occurrence or reference of a `Symbol` within the code. It includes information about the symbol's location in a source file (file path, line number, etc.) and its role in the code (e.g., definition, declaration, reference, etc.). The `SymbolOccurrence` type allows you to track and analyze how symbols are used, referred to, or defined throughout your codebase. This is particularly useful for finding specific instances of a symbol, such as all references to a particular function or variable, or understanding the relationships between different symbols.

### USR:

The `Symbol` also provides access to a `USR`. The `USR`, or `Universal Symbol Resolver`, is a unique identifier for a symbol in a programming language. In simple terms, it is a way to consistently and uniquely identify elements within your code, such as classes, functions, or variables, across different files and projects.

When working with code analysis tools, the `USR` allows you to track and manage code elements, as well as their relationships, making it easier to navigate, understand, and manipulate your codebase. In the context of the Swift language, the USR is a string that uniquely identifies a Swift symbol. It is generated by the Swift compiler and can be used by tools like `IndexStoreDB` to search, analyze, and manage source symbols in a Swift codebase.

The `USR` helps tools recognize and differentiate symbols even when they have the same name or appear in different locations within a project.

### Querying:

When searching for symbols and occurrences, there are a few options available, with the most commonly used being:

```swift
// Search the index for occurrences matching a query
@discardableResult public func forEachCanonicalSymbolOccurrence(
    containing pattern: String,
    anchorStart: Bool,
    anchorEnd: Bool,
    subsequence: Bool,
    ignoreCase: Bool,
    body: @escaping (SymbolOccurrence) -> Bool
) -> Bool

// Search for symbols within a source file (no filtering available)
public func symbols(inFilePath path: String) -> [Symbol]

// Find any `SymbolOccurence` for the given USR
public func occurrences(ofUSR usr: String, roles: SymbolRole) -> [SymbolOccurrence]

// Find any `SymbolOccurence` related to the given USR
public func occurrences(relatedToUSR usr: String, roles: SymbolRole) -> [SymbolOccurrence]
```

These methods also have variations to enumerate in a forEach loop and offer a few other convenient features. Essentially, these methods will query the index store in one of two ways:

Essentially these methods will query the index store in one of two ways:

* By searching based on a given query for keys and related contents to match and return symbols and occurrences.
* By evaluating the contents of a source file at a given path and looking up symbols within that file from the index.

Performing a query using the `forEachCanonicalSymbolOccurrence` approach is much faster; however, it does not treat an empty string using a "match all" strategy.

You can start to see how everything comes together by taking a quick look at the `SymbolOccurrence` type:

```swift
public struct SymbolOccurrence: Equatable {
  public var symbol: Symbol
  public var location: SymbolLocation
  public var roles: SymbolRole
  public var relations: [SymbolRelation]

  public init(symbol: Symbol, location: SymbolLocation, roles: SymbolRole, relations: [SymbolRelation] = []) {
    self.symbol = symbol
    self.location = location
    self.roles = roles
    self.relations = relations
  }
}
```

This type allows you to approach different tooling and problems related to code analysis, as it provides access to the symbol, its kind, its roles, and its related symbols (for looking up inheritance and such).

Lastly, you may have noticed the `SymbolRole` property on an occurrence, which is also required for some queries. Understanding this aspect is crucial when working with the IndexStoreDB library.

### SymbolRole:

The `SymbolRole` is an option set in the `IndexStoreDB` library that represents the different roles a symbol can have in your code. Each `SymbolOccurrence` is associated with one or more SymbolRole values, which indicate the purpose or usage of the symbol within a specific context. Understanding these roles is crucial for querying code, performing analysis, navigating tasks, and gaining insight into how symbols are related to each other and how they are utilized in the codebase.

The `IndexStoreDB` library does not document these roles, but I have duplicated them into a type called `SourceRole` in my library and provided [**full documentation**](https://github.com/CheekyGhost-Labs/IndexStore/blob/main/Sources/IndexStore/Public/SourceSymbol/SourceRole.swift?ref=cheekyghost.com). For example:

```swift
/// Represents a symbol that provides a complete implementation, e.g., class, struct, enum, or function body.
public static let definition ...

/// Represents a reference to a symbol, such as using a type, variable, or calling a function.
public static let reference ...

/// Represents a symbol that serves as a base class or protocol for another symbol.
public static let baseOf ...

/// Represents a method that overrides a method from its superclass or conforms to a protocol requirement.
public static let overrideOf ...
```

Depending on what roles you provide to a query, your results will differ. As an occurrence of a symbol can have multiple roles, you can use that to refine your initial result set before working with symbols and occurrences.

### IndexSymbolKind:

The `IndexSymbolKind` is declared on the `Symbol`, and it is an enumeration that represents the different kinds of symbols that can be found in your code. It categorizes symbols based on their language constructs, making it much easier to identify and filter symbols when performing code analysis or related tasks.

Some common IndexSymbolKind values include:

* class: The symbol represents a class.
* struct: The symbol represents a structure.
* enum: The symbol represents an enumeration.
* protocol: The symbol represents a protocol.
* function: The symbol represents a function or method.
* variable: The symbol represents a variable, constant, or property.
* typeAlias: The symbol represents a type alias or a typedef.
* extension: The symbol represents an extension to an existing type.

Again, these kinds are not documented within the indexstore-db library. While they are fairly straightforward, there are some nuances. I abstracted this with `SourceKind` in my library and added [**full documentation**](https://github.com/CheekyGhost-Labs/IndexStore/blob/main/Sources/IndexStore/Public/SourceSymbol/SourceKind.swift?ref=cheekyghost.com). For example, you may read `function` and think

> "that means a function I declared on a class"

but it actually refers to a stand-alone function. Instead, `instanceMethod` or `staticInstanceMethod` represent the function declarations on a class, protocol, enum, etc. I found this distinction useful, so I added documentation.

### Wrapping up:

In summary, the `indexstore-db` library provides the `IndexStoreDB` instance that can be used to resolve `Symbol` and `SymbolOccurrence` types, allowing you to facilitate various tooling or analysis tasks that you may encounter. The library itself is not well-documented, so it is recommended to read the Indexing Whitepaper to understand some of the underlying concepts (or you can ask ChatGPT to explain some of the types and methods, etc.).

## IndexStore Library

The `IndexStore` library I've released aims to make querying the underlying `IndexStoreDB` more readable and intentful. There are two main components to achieve this:

* The `IndexStore` instance
* The `IndexStoreQuery` struct

The `IndexStoreQuery` is designed to describe a query and allow you to tweak various query parameters. You can then send the query to the `IndexStore` instance to resolve a set of `SourceOccurrence` types.

### IndexStore:

The `IndexStore` contains an underlying workspace, which holds the `IndexStoreDB` instance for querying. One of the main goals is to minimize the setup required to start working with an index. This involves resolving the path to the index store database and the index store library during initialization. Developers can provide their own paths, but the default will assess the current process to resolve the paths it needs, which is especially useful when running from the Swift command line versus Xcode:

![Resolving index store database paths via ProcessInfo](/assets/img/posts/indexstore-for-swift/process-info-resolution.jpeg)

Additionally, the library resolves the path to the index store library (`libIndexStorePath`) by querying `xcode-select`:

![Resolving libIndexStorePath via xcode-select](/assets/img/posts/indexstore-for-swift/xcode-select-resolution.jpeg)

This approach allows developers to get started quickly, as the library can resolve what it needs on its own:

```swift
let configuration = try Configuration(projectDirectory: "working/directory/path")
let indexStore = IndexStore(configuration: configuration)

// Start querying
let protocols = indexStore.query(.protocols(matching: "MyProtocol"))
```

### Querying:

The `IndexStoreQuery` makes building a query far more readable and provides a good extension point for common queries. It offers the following properties:

* `query: String?`
* `sourceFiles: [String]?`
* `kinds: [SourceKind]`
* `roles: SourceRole`
* `restrictToProjectDirectory: Bool`
* `anchorStart: Bool`
* `anchorEnd: Bool`
* `includeSubsequence: Bool`
* `ignoreCase: Bool`

Additionally, it supports builder-like helpers to avoid setting everything up during initialization:

```swift
IndexStoreQuery(query: query)
    .withKinds(SourceKind.allFunctions)
    .withRoles([.definition, .childOf, .canonical])
    .withAnchorStart(false)
    .withAnchorEnd(false)
    .withInlcudeSubsequences(true)
    .withIgnoringCase(false)
```

This approach allowed me to provide a lot of extensions for common query scenarios, such as:

```swift
.functions("performOperation")
.functions(in: ["filePath", "filePath"], matching: "performOperation")

.classes("MyClass")
.classes(in: ["filePath", "filePath"], matching: "MyClass")

.extensions(ofType: "String")
.extensions(in: ["filePath", "filePath"], matching: "String")

.allDeclarations("MyType")
.allDeclarations(in: ["filePath", "filePath"], matching: "MyType")

// many more
```

So, when building out helpers and tooling, the code becomes quite intentful and much easier to read.

```swift
let myClasses = indexStore.querySymbols(.classes("MyClass"))

let protocols = indexStore.querySymbols(
    .protocols("rendering")
    .withAnchorStart(false)
    .withAnchorEnd(false)
)

let carEnum = indexStore.querySymbols(.enumDeclarations("Car")).first
```

### Convenience:

I also added some convenience methods for common scenarios that use pre-made queries to streamline the process. For example, to get all types conforming to a protocol:

```swift
let concretes = indexStore.sourceSymbols(conformingToProtocol: "Renderer")
```

or getting invocations of a valid symbol:

```swift
let functions = indexStore.querySymbols(.functions("performOperation"))

let invocations = indexStore.invocationsOfSymbol(functions[0])
```

These conveniences can be used to build out analysis tooling in a more readable and intentful manner. For instance, to find any functions not currently being invoked within a test case:

```swift
let functions = indexStore.querySymbols(.functions(in: ["filePath"]))

let notTested = functions.filter{ !$0.isSymbolInvokedByTestCase($0) }

notTested.forEach {
    print("Untested: \($0.name) in \($0.parent?.name) - \($0.location)")
}
```

In summary, this is a simple abstraction that emphasizes intent and readability. Some improvements and additional conveniences are planned to be added over the next month as well.

## Versioning Woes

> because stable means different things to different people

One major gripe I have with this library is that I am unable to follow a standard semvar tagging release process. I am tagging releases, however, due to what Swift Package Manager considers stable, the releases are currently facilitated by release branches to the `minor` version. For example:

* release/1.0
* release/1.1

This is because the `indexstore-db` library does not release using the semvar tagging approach. I have to add the dependency like this:

```swift
.package(url: "https://github.com/apple/indexstore-db.git", branch: "release/5.9"),
```

so if someone adds the `IndexStore` dependency in the standard manner like this:

```swift
.package(url: "https://github.com/CheekyGhost-Labs/IndexStore.git", from: "1.0.0"),
```

you will get the following error:

![SPM unstable dependency resolution error](/assets/img/posts/indexstore-for-swift/spm-unstable-error.png)

Which is worded odd for saying:

> The dependency `IndexStore` is not stable as it depends on `indexstore-db` using an unstable means of resolving.

So yeah, not ideal. However, as noted I will still be tagging releases for when `indexstore-db` does adopt the standard semvar tagging.

## Wrapping Up (and next steps)

This library was something that made sense to build and release as it is not only being used in the upcoming `MimicKit` library, but will also drive some tooling that I, and fellow colleagues, will be creating in the coming months.

On the list for future updates are:

* Provide a child iterator utility to iterate through source symbol children
* Consolidate and improve function parameter naming where relevant
* Build CLI tooling around it
* Build swift plugins for common tasks such as untested and unused code reporting
* Add more convenience methods based on developer feedback (or contributions)

This is first open source project I have released in a long time, something I am hoping to significantly change in the coming months.

However before signing off, I would be remiss to not mention how amazing the [**SwiftPackageIndex**](https://swiftpackageindex.com/?ref=cheekyghost.com) site and developer support is. I was able to publish the library within 2 hours, and more than that, because I followed standard DocC formatting for the code documentation - the site automatically picked it up and hosted the documentation. It also handles swift compatibility building and badge generation which is a great means to snapshot whether it is suited for use in your tooling or projects. Just a great tool and experience overall.

[**Swift Package Index**](https://swiftpackageindex.com/CheekyGhost-Labs/IndexStore)