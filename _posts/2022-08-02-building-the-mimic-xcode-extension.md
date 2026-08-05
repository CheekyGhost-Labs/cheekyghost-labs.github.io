---
title: Building the Mimic Xcode Extension
date: 2022-08-02 10:00:00 +1000
categories: [ios, swift, tooling]
tags: []
image:
  path: /assets/img/posts/building-the-mimic-xcode-extension/cover.png
  alt: Building the Mimic Xcode Extension
  lqip: data:image/webp;base64
---

I am always baffled at the excuses I have heard over the years as to why test coverage is so low or non-existant. Ulitamtely though there is one thing I have to concede on:

> Swift does not provide much support for a test focused developer - Me every time someone asks 'Is there mockito for swift?'

Ultimately, waiting around for Swift to provide some decent reflection functionality, or in general expecting someone else to prioritise personal features, is just not scalable or ideal.

This post covers an Xcode extension I have written to generate mocks, spies, partial spies, and dummys from within Xcode. It is not a new concept or even a new extension to exist, however, it has been written with as little dependency on private libraries as possible.

1.0.2 Currently available for purchase on the app store!

[![Building the Mimic Xcode Extension](/assets/img/posts/building-the-mimic-xcode-extension/app-store-badge.png)](https://apps.apple.com/us/app/mimic-mockgenerator-for-xcode/id1640010185?ref=cheekyghost.com)

## Demos

> Note: These were recorded when this project was called `SwiftMock` - but apple did not like that name so it was renamed to `Mimic` for the app store release.

### Adding Permissions:

![Adding Permissions demo](/assets/img/posts/building-the-mimic-xcode-extension/demo-adding-permissions.gif)

### Generate Spy:

![Generate Spy demo](/assets/img/posts/building-the-mimic-xcode-extension/demo-generate-spy.gif)

### Generate Partial Spy:

![Generate Partial Spy demo](/assets/img/posts/building-the-mimic-xcode-extension/demo-generate-partial-spy.gif)

### Generate Stub:

![Generate Stub demo](/assets/img/posts/building-the-mimic-xcode-extension/demo-generate-stub.gif)

### Generate Dummy:

![Generate Dummy demo](/assets/img/posts/building-the-mimic-xcode-extension/demo-generate-dummy.gif)

## Thoughts on Existing Tooling

### providing some context

There is a bit of tooling already out there to help set up mocks, spies, dummies etc as part of your process. I have used most of them and in various team + project setups. Specifically, the following three are what kept popping up:

## [Sourcery](https://github.com/krzysztofzablocki/Sourcery?ref=cheekyghost.com)

Sourcery is a tool that generates Swift code by way of a template. It is powered by Apple's SourceKit and allows developers to do all sorts of fun things, one of which is generating mocks and spies etc using the `AutoMockable` type.

When using Sourcery the more common approach is to have an Xcode Build Phase that invokes the Sourcery tool, this tool enumerates the project and searches for either a comment requesting `AutoMockable`:

```swift
//sourcery: AutoMockable
```

or conformance to the `AutoMockable` protocol (that you also have to create somewhere in your project):

```swift
protocol AutoMockable {}

protocol MyThing: AutoMockable {
    func doTheThing()
}
```

The script then converts these into mock and spy outputs for use during testing.

**Note:** There are quite a few related tools built using Sourcery under the hood.

---

## [Cuckoo](https://github.com/Brightify/Cuckoo?ref=cheekyghost.com)

Cuckoo was written so that it's DSL is as close to [Mockito](https://site.mockito.org/?ref=cheekyghost.com) as possible. It works in two parts:

* CLI tool (to generate required things for the runtime component)
* Run time elements

The CLI portion generates supporting structs and classes from your project for the runtime element to utilise. This two-part approach allows for some niceties in the DSL area and a bit more flexibility to focus on convenience.

It is worth checking out to see if it suits your project and development team process.

---

## [SwiftMockGenerator for Xcode](https://github.com/seanhenry/SwiftMockGeneratorForXcode?ref=cheekyghost.com)

This OG tool is used by nearly every developer I have met. This project essentially installs an [XcodeSourceEditorExtension](https://developer.apple.com/documentation/xcodekit/creating_a_source_editor_extension?ref=cheekyghost.com) with an accompanying application.

The application component allows you to grant read permissions to a project directory, which the extension needs to be able to read and parse source code. The extension component takes the source code the developer is focusing on, parses it, and then generates a spy or stub etc by:

* Resolving the inherited types to generate for
* Resolve a moustache template for the mock type (spy, partialSpy, stub, dummy)
* Generate a render for the resolved template
* Replacing the existing contents of the focused class with the output

![SwiftMockGenerator demo](/assets/img/posts/building-the-mimic-xcode-extension/swiftmockgenerator-demo.gif)

This is also available on the OG GitHub page

The nice thing about this approach is that it is flexible for the developer. Teams can rely on developer discipline to ensure mocks/spies/stubs are created with source addition for immediate and future use.

### Notes on pain points:

While this tool is great, many developers (myself included) have raised a few pain points:

> These are written with constructive intent. The developer gave plenty of notice about no longer actively working on the tool and these points are what led me to write my own with no private dependencies.

* The templating system is hard to work with
* The source code is hard to navigate and modify
* The project uses pre-compiled 3rd party libraries that **are not open source**
* The project can go many months/years in an uncompilable state due to swift and Xcode updates
* Does not generate statics
* Does not generate classes with generic types
* Does not handle functions or variables using generics

Most recently there was an update on **July 6, 2022** – before that, the last update was on **Dec 1, 2020**. This is obviously a big risk flag. Again though, the developer/repo owner advertised that they were not maintaining the project anymore. They did an awesome job and still make time when they can update to the latest Xcode and swift etc. For myself though, I need something actively maintained (hence writing my own).

## Why I wrote my own

### albeit heavily inspired

As noted before, there were some paint points with the currently available SwiftMockGenerator. The most crucial for me are:

* It uses private dependencies that get caught in an uncompilable state due to swift compiler differences
* The templating system is hard to work with (from a swift-source perspective)
* There is no means for a developer to easily tweak the generation boilerplate to suit their style guides

Specifically, the private dependencies/binaries were a real blocker. Sometimes for the better part of 8 months, the project was not able to be compiled due to the binary being built with a previous version of the Swift compiler.

With this in mind, I found myself thinking "I should just write my own using Apple swift-syntax to avoid this". That led to a few other thoughts:

* Could introduce a strong separation of concerns to make the project more approachable and maintainable
* Could provide a more simple UI to manage the various projects with permissions granted
* Could introduce a means to alter the template via UI rather than rely on manually altering template files
* Utilise IndexStoreDB to try to leverage Xcode's indexing system for source code lookup

In the end, I realised that I wanted to write my own as a means to get across the XcodeSourceEditorExtension limitations and capabilities anyway, so the `Mimic` project was born.

## General Decisions, Architecture, and Approaches

In essence, the project is somewhat simple... as a concept:

* Send the current source and selection from Xcode IDE to the extension
* Resolve the hosting type (class/struct etc)
* Determine the inheritance types
* Resolve the source for those types
* Generate boilerplate based on the template (stub, spy, partialSpy, dummy)
* Replace the contents of the current source with the generated output
* World domination?

So first off, let's define some requirements, goals, and success metrics for the project.

### Requirements:

* Any 3rd party libraries need to be open-source and maintained
* Templates should be easily configurable (within reason) by the developer in the open-source project
* Developers should be able to pull the core library and achieve the same functional results. The app code should be completely decoupled.
* The project should use [**ScriptBridging**](https://developer.apple.com/documentation/scriptingbridge?ref=cheekyghost.com) rather than direct AppleScript invocations.
* 85% unit test coverage. Focusing on parsing and permissions etc.
* Should target macOS 11+ (public -1)
* Use local swift packages to avoid the `_InternalSwiftSyntaxParser` debacle with the Framework projects (tldr; let xcode handle the including and signing via SPM)

### Goals:

Ultimately this project needs to be maintainable and scalable, both from a stability/enhancement perspective and from being able to evolve with the swift language. This made me think of the pain point the SwiftMockGenerator project had in its use of pre-compiled binaries that are not open source. With this in mind, I came up with the following list:

* Use [Apple's swift-syntax](https://github.com/apple/swift-syntax?ref=cheekyghost.com) library for parsing swift source
* Use an open-source AST parser if possible that leverages swift-syntax
* Keep any business and parsing logic in a self-contained package for future flexibility
* Don't over-think the interface for the core library as this is not intended as a "one size fits all" library for common use
* Leverage a CI to enforce and advertise test coverage
* Use a templating solution that is approachable for developers
* Format the generated output to save devs a step

Three of these goals led to some pretty important decisions. The first was to fork and use the [**SwiftSemantics**](https://github.com/SwiftDocOrg/SwiftSemantics?ref=cheekyghost.com) library. This library is archived, but its quite solid and uses the swift-syntax library. The reason I forked it was to add some conveniences such as getting the parent type for a variable or function etc, as well as some conveniences around resolving whether properties are closures (and their input/result types etc).

My fork is open source and available here: [**SwiftSemantics**](https://github.com/mobrien-ghost/SwiftSemantics?ref=cheekyghost.com)

The second decision was to use [Stencil for the templating](https://github.com/stencilproject/Stencil?ref=cheekyghost.com). I found this to be the most stable and readable after exploring a few options. I looked at a few approaches too:

* Manually concatenating the formatted lines one by one using string format templates
* Having some basic templates that I could search and replace on `(replacingOccurrences(of:with:)`
* Using a mix of the previous two approaches
* Using the [Mustache templating library](https://github.com/groue/GRMustache.swift?ref=cheekyghost.com)
* Using the [Stencil templating library](https://github.com/stencilproject/Stencil?ref=cheekyghost.com)

Ultimately I went with Stencil as I found it to be the most reliable and offer the most functionality for templating around newline management and filtering. Mustache I found to be too cumbersome and the templates ended up becoming too unreadable. The outputs were also harder to format. As Stencil is open source and actively maintained I decided it was a safe bet.

Finally, I decided to include [**Nick Lockwood's SwiftFormat Library**](https://github.com/nicklockwood/SwiftFormat?ref=cheekyghost.com) to format the output. I figured it's nice to have, but could be configured behind a settings toggle if it caused any annoyance. However, I found some issues using this on source code not wrapped in valid brackets or types, so I ended up going with Apple's swift formatting library 😅

## Architecture/General Overview

I drew the following diagram to piece together how the project will be setup:

![Architecture diagram](/assets/img/posts/building-the-mimic-xcode-extension/architecture-diagram-1.png)

![Architecture diagram](/assets/img/posts/building-the-mimic-xcode-extension/architecture-diagram-2.png)

Pretty standard setup:

* `Mimic app` will have the `Mimic Extension` target
* `Mimic app` will import `AppCore` which will contain all the UI components to build out the GUI
* `AppCore` will import `MimicCore` to gain access to relative services (permissions, settings etc)
* `Mimic Extension` will import `MimicCore` to request the parsing and generation of templates.
* `MimicCore` will import the various utility libraries to parse, generate, and format the results

The bulk of the source code will be in the `MimicCore` library, as it will be responsible for:

* Facilitating granting and persisting of directory permissions
* Facilitating and persisting various settings
* Resolving the currently active Xcode project using ScriptBridging (falling back to AppleScript)
* Parsing raw source into AST
* Resolving the focused type and inheritance to generate
* Resolving various data contexts from the resolved inheritance AST's
* Rendering data contexts into the mock templates (stubs, spies, etc)
* Formatting the output result

The `AppCore` library will house any SwiftUI views and smaller components to facilitate:

* Displaying a list of project directories the user has given permission to
* Removing permissions
* Displaying any configurable settings

The `Mimic App` target will be dead simple. It will import the `AppCore` library and facilitate switching between any core views (permissions, settings, help etc)

Finally the `Mimic Extension` will facilitate declaring the source editor commands for the `Xcode>Editor` menu. It will also:

* Send the invocation (raw source+selections) to `MimicCore` to be parsed and generated
* Recieve the result back from the library
* Replace the current portions of the source file with the generation result

## Templates:

The `MimicCore` library will house any templates used with the `Stencil` dependency. They will sit in a very simple directory and be separated between `Variable` and `Function` templates. This is so the templates don't become too verbose, however, the Spy templates will support partial as part of its design:

![Templates screenshot](/assets/img/posts/building-the-mimic-xcode-extension/templates-screenshot.png)

## Mac App Component:

The `AppCore` follows the [**Swift Composable Architecture**](https://github.com/pointfreeco/swift-composable-architecture?ref=cheekyghost.com). I chose this as it is a super simple project from a UI/UX perspective and gave me the chance to experiment with the architecture. However, as the `MimicCore` contains all the functional logic and protocols etc, a developer could just as easily use `UIKit` or their own `SwiftUI-`based architecture.

My current app structure and code looks like this:

![App structure screenshot](/assets/img/posts/building-the-mimic-xcode-extension/app-structure-screenshot.png)

as you can see it's quite simple and lets you focus on the app lifecycle and coordination of flows.

## Release Plan (watch this space 🔥)

The AppStore version will be released first.

I thought long and hard about releasing this extension. Ultimately I was going to just do an open-source project and let folks have at it, however, I have noticed that it's easy to fall into the trap of not finding the time or to lump any additional work as 'lower priority'.

To this point, I am doing 2 things:

* Releasing to the app store for a reasonable price
* Based on the success of the above, look at releasing the project as open source **at some point** with some note in the license

The first point is pretty self-explanatory, and if the extension is useful to developers who want to avoid the minutiae of distribution (building + signing + distributing), they can purchase it at a one-off cost and gain any future updates for free - which in turn gives me the incentive and offset to dedicate my personal time to feature requests and optimisation updates.

The second is a little different. I want to maintain this as an active purchasable product first. It will allow purchasing customers to raise bugs and feature requests, which will in turn provide the incentive for me to deliver. However, I have no issues with this code being used to build another tool, or as a learning tool to understand some different approaches. There were many nuances to parsing code for various scenarios (good or bad). Everyone writes code differently so if this project can provide some insight all the better. After I gauge the success of SwitMock as a product, I will look at releasing it as an open-source project on GitHub at some point with one minor addition to the license (something along these lines):

> ... The source code, as is or close derivative, must not be resold or re-distributed as a sole product.

which ultimately is me saying that you will be able to:

* Fork your own copy
* Take portions of this code and use it in other products
* Build/distribute a local binary of the project as is **internally**
* Build/distribute a local binary of the project with modifications **internally**

and that you can't:

* Just change the signing and release the same product on the app store/web for sale or free
* Re-skin the app and release it as a product on the app store/web for sale or free

I feel this is a fair compromise as it allows:

* Myself to investigate maintaining a product that I feel is useful and worth a small one-time purchase fee
* Provide a means for existing customers to report bugs and see fix progress
* Provide a means for existing customers to request features and see the progress
* Provide a means for potential customers waiting for a feature to see progress
* Allow open source collaborators to contribute (and if successful I could re-reimburse for time spent as best I can)