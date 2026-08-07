---
layout: page
icon: fab fa-app-store
order: 2
title: Mimic
---

<hr/>

<div align="center">

<h2>Generate mocks, spies, stubs, and dummies for Swift in Xcode!</h2>

<div align="center">
	<img src="/assets/img/pages/mimic/hero.png" alt="Mimic" style="max-width: 100%; height: auto; align: center">
</div>

<div class="mimic-cta-row">
  <span class="mimic-app-store-badge">
	<a href="https://apps.apple.com/us/app/mimic-mockgenerator-for-xcode/id1640010185"
	   target="_blank"
	   rel="noopener noreferrer"
	   class="mimic-app-store-btn"
	   aria-label="Download on the App Store">
	</a>
  </span>
  <a href="https://github.com/CheekyGhost-Labs/mimic-appspace/releases/download/2.1.0/Mimic.zip" target="_blank" class="mimic-cta-btn primary">
    <i class="fas fa-download"></i> Direct Download
  </a>
  <a href="https://cheekyghost.lemonsqueezy.com" target="_blank" class="mimic-cta-btn secondary">
    <i class="fas fa-key"></i> Purchase a License
  </a>
</div>

</div>

<hr/>

## Features:

<!-- Feature grid — styled to match site theme via CSS variables -->
<div style="
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.25rem;
  margin: 2rem 0;
">

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-bolt" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">One-Click Generation</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">Generate Spy, Partial Spy, Stub, or Dummy test doubles straight from the Xcode Editor menu.</p>
  </div>

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-code" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">Native Swift Output</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">No custom DSL — generated code is plain Swift, ready to drop into any architecture or test setup.</p>
  </div>

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-sitemap" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">Generics &amp; Closures</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">Full support for generic types, closure parameters, and multiple inheritance/conformance.</p>
  </div>

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-shield-halved" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">Invocation Tracking</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">Captures call counts and input parameters for methods, subscripts, getters, and setters.</p>
  </div>

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-gear" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">Configurable Rendering</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">Companion app lets you manage project permissions and tweak generation settings.</p>
  </div>

  <div style="background: var(--card-bg); box-shadow: var(--card-shadow); border-radius: 10px; padding: 1.5rem;">
    <i class="fas fa-swift" style="font-size: 1.5rem; color: #0d6efd; margin-bottom: 0.75rem; display: block;"></i>
    <h4 style="margin: 0 0 0.5rem;">Swift 5.0+ / Xcode 11+</h4>
    <p style="margin: 0; color: var(--text-muted-color); font-size: 0.95rem;">Built and tested against modern Swift and Xcode toolchains, actively maintained.</p>
  </div>

</div>

<hr/>

## Getting Started

<!-- Step 1 -->
<div class="mimic-step-card">
  <div class="mimic-step-header">
    <span class="mimic-step-badge">1</span>
    <h3 style="margin:0;">Grant Xcode Extension Permissions</h3>
  </div>
  <ul class="mimic-step-bullets">
    <li>Launch the Mimic app and click <strong>Authorize</strong>.</li>
    <li>Click <strong>Open Preferences</strong> and enable the Xcode Source Editor toggle for Mimic.</li>
  </ul>
  <div class="mimic-image-row">
    <img src="/assets/img/pages/mimic/setup-1a.png" alt="Clicking Authorize in the Mimic app">
    <img src="/assets/img/pages/mimic/setup-1b.png" alt="Enabling the Xcode Source Editor toggle">
  </div>
  <p class="mimic-note-plain">These steps differ slightly depending on your macOS version. The Authorization screen in the Mimic app will show you the exact steps for your system.</p>
</div>

<!-- Step 2 -->
<div class="mimic-step-card">
  <div class="mimic-step-header">
    <span class="mimic-step-badge">2</span>
    <h3 style="margin:0;">Grant Derived Data Permissions</h3>
  </div>
  <ul class="mimic-step-bullets">
    <li>Click <strong>Permissions</strong>.</li>
    <li>Click <strong>Link Derived Data</strong>, then click <strong>Grant Permissions</strong> on the dialog presented.</li>
  </ul>
  <div class="mimic-image-row">
    <img src="/assets/img/pages/mimic/setup-2a.png" alt="Clicking Link Derived Data">
    <img src="/assets/img/pages/mimic/setup-2b.png" alt="Granting permissions on the Derived Data dialog">
  </div>
  <div class="mimic-note">
    <i class="fas fa-circle-info"></i>
    <p>If you use a custom Derived Data location, navigate to that directory instead of the default.</p>
  </div>
</div>

<!-- Step 3 -->
<div class="mimic-step-card">
  <div class="mimic-step-header">
    <span class="mimic-step-badge">3</span>
    <h3 style="margin:0;">Add Your Project(s)</h3>
  </div>
  <ul class="mimic-step-bullets">
    <li>Click <strong>Add Project</strong> on the Permissions screen.</li>
    <li>Navigate to the root directory of your Xcode project or Swift package, and click <strong>Grant Permissions</strong>.</li>
  </ul>
  <div class="mimic-image-row">
    <img src="/assets/img/pages/mimic/setup-3a.png" alt="Clicking Add Project on the Permissions screen">
    <img src="/assets/img/pages/mimic/setup-3b.png" alt="Granting permissions on a project's root directory">
  </div>
  <div class="mimic-note info">
    <i class="fas fa-circle-info"></i>
    <p>Mimic supports directories containing: `.xcodeproj`, `.xcworkspace`, and `Package.swift` files.</p>
  </div>
</div>

<!-- Step 4 -->
<div class="mimic-step-card">
  <div class="mimic-step-header">
    <span class="mimic-step-badge">4</span>
    <h3 style="margin:0;">Using the Xcode Extension</h3>
  </div>

  <ul class="mimic-step-bullets">
    <li>Find or add a mock candidate, then select within the declaration — or within a nested method.</li>
    <li>Click <strong>Editor → Mimic</strong> and select one of the <strong>Generate</strong> options.</li>
  </ul>
  <div class="mimic-image-row">
    <img src="/assets/img/pages/mimic/setup-4a.png" alt="Selecting within a mock candidate declaration">
    <img src="/assets/img/pages/mimic/setup-4b.png" alt="Selecting a Generate option from the Editor > Mimic menu">
  </div>
  <div class="mimic-note">
    <i class="fas fa-circle-info"></i>
    <p>Mimic uses IndexStore to resolve symbols — wait for your project to finish indexing before generating a mock.</p>
  </div>

  <hr style="border:none; border-top:1px solid var(--main-border-color); margin:1.75rem 0;">

  <ul class="mimic-step-bullets">
    <li>If this is your first ever usage of Mimic you will need to allow access.</li>
    <li>Your mock output should generate directly in the editor.</li>
  </ul>
  <div class="mimic-image-row">
    <img src="/assets/img/pages/mimic/setup-4c.png" alt="First use permissions">
    <img src="/assets/img/pages/mimic/setup-4d.png" alt="Generated mock output in the Xcode editor">
  </div>
  <div class="mimic-note">
    <i class="fas fa-circle-info"></i>
    <p>On first use, a permissions/access dialog will appear. Click Allow/Accept to continue.</p>
  </div>
</div>

## Common Troubleshooting

> Please reach out to [CheekyGhost Labs](mailto:mimic@cheekyghost.com) if you have any explicit examples or suggestions for improvements in generation and code formatting 🙏
{: .prompt-tip }

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 1rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">Editor action is greyed out</summary>
  <p style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    This usually means either Xcode hasn't finished loading extensions, or you need to add explicit permission in the system extension settings.
  </p>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 1rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">Derived Data and project permissions</summary>
  <p style="margin: 0.75rem 0; color: var(--text-muted-color);">
    <code>error: "Permissions..."</code>
  </p>
  <p style="margin: 0 0 0.75rem; color: var(--text-muted-color);">
    The permissions setup has been hardened and will most likely last until you physically remove permissions. Occasionally, however, you may need to re-grant permissions in the Mimic app — usually after significant system or OS updates. The Xcode editor will show an error banner (and a notification, if granted) — resolve this by clicking the <strong>Re-link Project</strong> button in the app. As a fallback, remove and re-add the project permissions.
  </p>
  <p style="margin: 0; color: var(--text-muted-color);">
    The same applies to the Derived Data permissions at the top of the <strong>Permissions</strong> tab in the app.
  </p>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 1rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">Symbol resolution</summary>
  <p style="margin: 0.75rem 0; color: var(--text-muted-color);">
    <code>error: "Unable to resolve symbols..."</code>
  </p>
  <p style="margin: 0; color: var(--text-muted-color);">
    This usually means IndexStore hasn't finished processing the area you're trying to mock. A way to actively observe Xcode's indexing status is in development. If you hit this error, wait for indexing to finish — or, worst case, quit and restart Xcode.
  </p>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 1rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">Formatting</summary>
  <p style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    If you come across any weird formatting, it may indicate invalid Swift syntax (or a similar setup issue). Since most projects have their own formatting phase, if you're not a fan of Mimic's default format, we'd suggest running your own formatter as needed.
  </p>
</details>

<hr/>

## Changelog

#### 2.1.0 — Current Version

* [FEATURE] Redesigned the Settings screen with a cleaner, card-based layout
* [BUG] Fixed Terms of Service and Privacy Policy links not opening from the subscription view
* [BUG] Fixed toggle alignment in Settings so switches sit consistently at the trailing edge

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">2.0.1</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>[BUG] Fixed bug where invalid declarations would render. i.e <code>private</code> or <code>let</code> etc</li>
    <li>[BUG] Fixed bug where subscripts with same indices but with different return types were being considered the same and only rendering the first found.</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">2.0.0</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>[FEATURE] Added Swift package project support</li>
    <li>[FEATURE] Uses IndexStore to resolve symbols. Occasional gremlin but far more accurate.</li>
    <li>[FEATURE] Uses SwiftSyntax library to generate code. Hardening source creation.</li>
    <li>[FEATURE] Default values generated for tuples and closures where possible</li>
    <li>[FEATURE] Generate test doubles inheriting from types within SPM dependencies</li>
    <li>[FEATURE] Support for throwing closures</li>
    <li>[FEATURE] Better support for structured concurrency</li>
    <li>[FEATURE] Better support for operator declarations</li>
    <li>[FEATURE] Better support for classes/subclasses with complex generics</li>
    <li>[FEATURE] Support for pre and post generation content</li>
    <li>[BUG] Support for inout properties</li>
    <li>[BUG] Better support for protocols with inheritance</li>
    <li>[BUG] Support for protocols with primary associated types</li>
    <li>[BUG] Better support for functions and variables named the same across different protocols</li>
    <li>[BUG] Hardened duplication naming support</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">1.0.4</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>[BUG] Fixed issue where some function partial spies were not generating super calls</li>
    <li>[BUG] Fixed issue where sidebar unable to be re-opened</li>
    <li>[UPDATE] Unable to resolve Package-based directory permissions 😞</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">1.0.3</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>[BUG] Ensure correct indentation/formatting when generating for nested type</li>
    <li>[BUG] Don't re-generate initializers that having matching signatures across multiple inheritances 😅</li>
    <li>[BUG] Fix random ordering of generated functions</li>
    <li>[BUG]/[FEATURE] Better feedback for stale or corrupt project permissions</li>
    <li>[BUG] Fix bug where Package.swift files in root directory cause permission errors</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">1.0.2</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>[BUG] Exclude optional symbol from stubbed subscript properties</li>
    <li>[BUG] Default subscript generics with no type requirement to Any when expanding</li>
    <li>[BUG] Honour optional outputs in subscripts</li>
    <li>[BUG] Enforce standardised init order</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">1.0.1</summary>
  <ul style="margin: 0.75rem 0 0; color: var(--text-muted-color);">
    <li>Added support for Swift Playground project types</li>
    <li>Fixed bug where duplicate keywords would appear on some initializers</li>
    <li>Ensured redundant convenience init is not included in output when not required</li>
    <li>Fixed bug parsing some attributes in function parameters</li>
  </ul>
</details>

<details style="background: var(--card-bg); border-radius: 10px; padding: 1.25rem 1.5rem; margin-bottom: 0.75rem; box-shadow: var(--card-shadow);">
  <summary style="cursor: pointer; font-weight: 600;">1.0.0</summary>
  <p style="margin: 0.75rem 0 0; color: var(--text-muted-color);">Initial release.</p>
</details>