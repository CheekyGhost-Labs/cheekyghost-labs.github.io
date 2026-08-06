---
layout: page
icon: fab fa-app-store
order: 2
title: Mimic
---

<div align="center">

<h2>Generate mocks, spies, stubs, and dummies for Swift in Xcode!</h2>

<div align="center" style="margin-top: -44px;">
	<img src="/assets/img/pages/mimic/hero.png" alt="Mimic" style="max-width: 100%; height: auto; align: center">
</div>

<div class="mimic-cta-row" style="margin-top: -34px;">
  <span class="mimic-app-store-badge">
    <a href="https://apps.apple.com/us/app/mimic-mockgenerator-for-xcode/id1640010185"
       target="_blank"
       rel="noopener noreferrer"
       style="display:inline-block; width:180px; height:52px; background-image:url('/assets/img/pages/mimic/app-store-badge.svg'); background-size:contain; background-repeat:no-repeat; background-position:center; text-decoration:none; border-bottom:none;"
       aria-label="Download on the App Store">
    </a>
  </span>
  <a href="https://github.com/CheekyGhost-Labs/mimic-appspace/releases/download/2.0.1/Mimic.zip" target="_blank" class="mimic-cta-btn primary">
    <i class="fas fa-download"></i> Direct Download
  </a>
  <a href="https://cheekyghost.lemonsqueezy.com/checkout" target="_blank" class="mimic-cta-btn secondary">
    <i class="fas fa-key"></i> Purchase a License
  </a>
</div>

<span style="font-weight: bold; margin-top: -34px;">**v2.x** · Currently available for purchase</span>

</div>

<hr/>

## What is Mimic?

Mimic is an Xcode editor extension that generates boilerplate test double code — Spies, Partial Spies, Stubs, and Dummies — with the click of a button (or a keyboard shortcut).

All generated code is native Swift with no custom DSL, so you're free to use the output within your own architectures and testing setups. The companion app makes it simple to grant project permissions and configure rendering options.

> **Note:** Mocking of `static`/`class` members is not currently supported.
{: .prompt-info }

---

## Recent Version History

#### 2.0.0 — In development

> This release adopts **MimicKit**, the library that handles source resolving, parsing, and mock generation. MimicKit will also be open-sourced 😎
{: .prompt-tip }

* [BUG] Support for inout properties
* [BUG] Better support for protocols with inheritance
* [BUG] Support for protocols with primary associated types
* [BUG] Better support for functions and variables named the same across different protocols
* [FEATURE] Default values generated for tuples and closures
* [STRETCH] Generate test doubles inheriting from types within SPM dependencies
* [STRETCH] Support for throwing closures
* [STRETCH] Support for operator declarations
* [STRETCH] Better support for classes/subclasses with complex generics

#### 1.0.4 — Current App Store version

* [BUG] Fixed issue where some function partial spies were not generating super calls
* [BUG] Fixed issue where sidebar unable to be re-opened
* [UPDATE] Unable to resolve Package-based directory permissions 😞

#### 1.0.3

* [BUG] Ensure correct indentation/formatting when generating for nested type
* [BUG] Don't re-generate initializers that having matching signatures across multiple inheritances 😅
* [BUG] Fix random ordering of generated functions
* [BUG]/[FEATURE] Better feedback for stale or corrupt project permissions
* [BUG] Fix bug where Package.swift files in root directory cause permission errors

#### 1.0.2

* [BUG] Exclude optional symbol from stubbed subscript properties
* [BUG] Default subscript generics with no type requirement to Any when expanding
* [BUG] Honour optional outputs in subscripts
* [BUG] Enforce standardised init order

#### 1.0.1

* Added support for Swift Playground project types
* Fixed bug where duplicate keywords would appear on some initializers
* Ensured redundant convenience init is not included in output when not required
* Fixed bug parsing some attributes in function parameters

#### 1.0.0

Initial release. See Features below for inclusions.

---

## Features

#### General

* ✅ Swift 5.0+
* ✅ Generate Spy
* ✅ Generate Stub
* ✅ Generate Dummy
* ✅ Generate Partial Spy
* ✅ Xcode 11+

#### Currently in development

* 🛠 Consolidating duplicate properties/functions from multiple inheritance types (it happens)
* 🛠 Default values for closures and tuples etc

#### In the backlog

* 🛠 Generate test doubles inheriting from SPM dependencies
* 🛠 Support for throwing closures
* 🛠 Better support for classes/subclasses with complex generics
* 🛠 Better support for valid attributes (`@available`, `#if`, etc)
* 🛠 Support for operator declarations
* 🛠 More stable support for UI attributes such as IBOutlets and IBActions etc
* 🛠 Workaround for static/class properties not supported with Generics

#### Settings

* ✅ Support resolving and expanding raw TypeAlias definitions
* ✅ Support assigning default values where possible (defaults to code tag)
* ✅ Support assigning nil for default value for optionals
* ✅ Support rendering code tags when a default value can't be assigned
* ✅ Support including unique methods/properties declared on type extensions
* ✅ Feedback for stale or corrupt permissions

#### Conformance and inheritance

* ✅ Generates TypeAlias for Associated Types
* ✅ Generates for multiple inheritance/conformance
* ✅ Generates for mix of class and protocol conformance
* ✅ Generate test doubles inheriting from Carthage dependencies
* ✅ Generate test doubles inheriting from CocoaPods dependencies

#### Recording and invocations

* ✅ Captures invocation status + count for getters, setters, and methods
* ✅ Captures invocation status + count for subscripts
* ✅ Captures invocation input parameters for methods
* ✅ Captures invocation input parameters for subscripts
* ✅ Captures multiple invocation input parameters for methods
* ✅ Captures multiple invocation input parameters for subscripts

#### Generics

* ✅ Supports classes with generics
* ✅ Supports methods and variables with generics
* ✅ Supports generic inputs/parameters
* ✅ Supports generic inputs/parameters in closures
* ✅ Supports generic return results

#### Closures

* ✅ Supports escaping/auto-escaping closure parameters
* ✅ Generates invocation and inputs for closure parameters
* ✅ Automatically calls closure parameters with stubbed values

#### Stubbed results

* ✅ Stubs values for your test doubles to return
* ✅ Stubs a default value for return values where possible
* ✅ Stubs return values for within generated closures

#### Scopes and keywords

* ✅ Avoids naming clashes in generated output per inheritance
* ✅ Supports type-annotation for annotations and attributes

#### Visibility flags

* ✅ Respects public/open visibility flags
* ✅ Ignores final, private, and static methods (unable to override)

#### Initializers

* ✅ Generates convenience initializer with default values where possible
* ✅ Supports initializers with arguments
* ✅ Supports throwable initializers
* ✅ Supports required initializers
* ✅ Supports super calls in initializers

#### Throws

* ✅ Generates error stub for throwing methods
* ✅ Generates error stub for throwing initializer (when possible)

---

## Troubleshooting

My testers (and myself) have done our best to test against all sorts of... unique code examples when using the Mimic generator. If something isn't rendering correctly, here are a few common scenarios worth checking before reaching out to support:

**Formatting is weird:**

Extremely odd formatting (usually indentation) is usually caused by existing code in the target mock class — or the type being mocked — being uncompilable or invalid Swift syntax. Check the project compiles, or remove all code within the mock class and try again.

**My code is super unique:**

Depending on the code quality of the project you inherited, there may be some things Mimic doesn't completely support yet. In these cases, [please submit a bug or feature request](mailto:mimic@cheekyghost.com) with an example of the declaration and the current output being generated. I can't fix or add something if I don't know about it 😅

## Feature Requests & Bug Reports

If you find a bug, or want support added for something, [please submit a bug or feature request](mailto:mimic@cheekyghost.com). I actively maintain Mimic every week, prioritize bugs, and am always up for adding popular feature requests as they come in.

## Privacy Policy

Mimic's Privacy Policy can be [found here](/page/mimic-privacy-policy).