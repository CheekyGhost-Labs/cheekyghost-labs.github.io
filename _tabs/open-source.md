---
title: Open Source
icon: fas fa-code-branch
order: 6
---

## Contribute

I am still in the process of migrating some work to the CheekyGhost Labs GitHub org — so keep an eye out for some of our open source projects.

CheekyGhost Labs will always endeavour to open source any work that is not client or consumer based. If you believe in one of the projects, there are a number of ways you can give a hand, and all help is much appreciated.

If you would like to contribute and work on any projects, please reach out on the [Contact Page](/contact/). If you already have a GitHub account, you can always just submit a pull request to any of our open projects or request to be a contributor.

Please also feel free to reach out if you want to:

* Send feedback and improvements on our blog posts.
* Request a blog or technical write-up topic.
* Contribute good vibes by telling your friends about us.

Thanks for checking us out!

---

## Projects

### SyntaxSparrow

SyntaxSparrow is a Swift library designed to facilitate the analysis and interaction with Swift source code. It leverages the Apple SwiftSyntax library to parse Swift code and produce a syntax tree which collects and traverses constituent declaration types for Swift code.

It also comes in handy when writing/working with macros that provide the `DeclSyntaxProtocol`, as you can parse them into semantic types quite easily.

<i class="fab fa-github"></i> [**CheekyGhost-Labs/SyntaxSparrow**](https://github.com/CheekyGhost-Labs/SyntaxSparrow)

### IndexStore

IndexStore is a library that provides a query-based approach for searching for and working with source symbols within an indexed code base. It is built on top of the Apple IndexStoreDB library, which provides access to the index data produced by the Swift compiler.

With this library, you can easily search for and analyze symbols in your code, making it a powerful tool for building developer tools, static analyzers, and code refactoring utilities.

I have added some niceties around resolving a parent type and closure assessment, and as the project was archived, I have forked and made my additions available on my GitHub.

<i class="fab fa-github"></i> [**CheekyGhost-Labs/IndexStore**](https://github.com/CheekyGhost-Labs/IndexStore)

### OSLogClient

OSLog is the recommended logging approach by Apple and the core Swift team. A comprehensive and reliable logging system is essential in software development. However, projects often need to send logs to third-party vendors or other services. This presents a challenge: how to use OSLog while also ensuring seamless and flexible integration with external logging solutions.

OSLogClient aims to bridge this gap by acting as an intermediary, channeling the strengths and convenience of OSLog into custom logging mechanisms. It does this by polling the underlying `OSLogStore`, assessing the logs, and then forwarding the post-processed log messages to registered `LogDriver` instances. As a result, a registered `LogDriver` can receive log messages with all OSLog-based privacy, security, and formatting intact. The driver will also receive metadata such as date-time, log level, logger subsystem, and logger category.

<i class="fab fa-github"></i> [**CheekyGhost-Labs/OSLogClient**](https://github.com/CheekyGhost-Labs/OSLogClient)