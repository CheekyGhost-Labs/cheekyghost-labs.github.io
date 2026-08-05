---
title: Xcode Extensions, Code Signing, and TestFlight Woes
date: 2022-08-27 10:00:00 +1000
categories: [ios, swift, tooling]
tags: []
image:
  path: /assets/img/posts/xcode-extensions-code-signing-and-testflight-woes/cover.png
  alt: Xcode Extensions, Code Signing, and TestFlight woes
  lqip: data:image/webp;
---

Do you know what is not ideal for an app that generates code based on a vast array of different coding styles and disciplines? Not being able to use TestFlight for the beta testing 😩

I have come to rely so heavily on TestFlight to get a bunch of early bugs and improvements implemented before a release. I am strict on unit testing, but that does not mean I missed a bug, and my assumptions about some things can be far from what some would call "normal". Being able to get people to use your app before you release it and provide bug reports and feedback is a crucial step before an initial release - but this time TestFlight said no.

## Debugging/Confirming the Issue

TLDR; Code Signing strikes again 😂

Once Mimic was at a stable enough point to get some TestFlight users to have at it, I submitted the build and went through the motions. The issue came when installing via the TestFlight application. Essentially the beta users could:

* Download the build
* Launch the application
* See extension in System Preferences (and enable/disable etc)

Schweet, but then when Xcode was launched the extension would not appear in the `Edit` menu 🔥

![Extension not appearing in Edit menu](/assets/img/posts/xcode-extensions-code-signing-and-testflight-woes/edit-menu-missing.png)

### Debugging the issue:

So the first question I asked myself was "did this even install the extension???". To answer that I used the built in `pluginkit` CLI helper tools to check it appeared. This is easy enough, the command is as follows:

```bash
pluginkit -m -p com.apple.dt.Xcode.extension.source-editor -A -D -vvv
```

which outputs any installed extensions to the terminal window:

```bash
-    com.cheekyghost.mimic.XcodeExtension(1.0.0)
	            Path = /Applications/Mimic.app/Contents/PlugIns/MimicExtension.appex
	            UUID = 9ABC42A4-E867-4A27-95AF-EDBAEB447B3E
	       Timestamp = 2022-08-26 00:49:53 +0000
	             SDK = com.apple.dt.Xcode.extension.source-editor
	   Parent Bundle = /Applications/Mimic.app
	    Display Name = Mimic
	      Short Name = Mimic
	     Parent Name = Mimic

 (1 plug-in)
```

So on the plus side, the extension was installed. Yay. So why didn't it show up? Well that took some log diving and investigation.

To start with I setup the `Console.app` to focus on Xcode output, which led me to find this:

```bash
IDEExtensionManager: 
Xcode Extension does not meet code signing requirement: com.cheekyghost.mimic.XcodeExtension
(file:///Applications/Mimic.app/Contents/PlugIns/MimicExtension.appex/), 
Error Domain=DVTSecErrorDomain Code=-67050 "code failed to satisfy specified 
code requirement(s)" UserInfo={NSLocalizedDescription=code failed to satisfy 
specified code requirement(s)}
```

As any iOS/macOS developer knows, as soon as you see `code signing` in your issues list you pretty much feel like you are in a souls game:

![Code signing souls game](/assets/img/posts/xcode-extensions-code-signing-and-testflight-woes/code-signing-souls-game.png)

However, this log did contain something that made it easier to focus on the Apple code signing docs:

```bash
code failed to satisfy specified code requirement
```

### Confirming the Code Signing issue:

Considering (at some point) code from the app store needs to be signed by Apple as *Apple Code* - this led to using the `codesign` CLI tool to run a quick code-sign check:

```bash
codesign -vvvv -R="anchor apple" /Applications/Mimic.app
```

This will perform a code-sign check on the app and it's embedded extensions, which had the following output:

```bash
--prepared:/Applications/Mimic.app/Contents/PlugIns/MimicExtension.appex
--validated:/Applications/Mimic.app/Contents/PlugIns/MimicExtension.appex
--prepared:/Applications/Mimic.app/Contents/Frameworks/lib_InternalSwiftSyntaxParser.dylib
--validated:/Applications/Mimic.app/Contents/Frameworks/lib_InternalSwiftSyntaxParser.dylib
--prepared:/Applications/Mimic.app/Contents/Frameworks/libswift_Concurrency.dylib
--validated:/Applications/Mimic.app/Contents/Frameworks/libswift_Concurrency.dylib
Mimic.app: valid on disk
Mimic.app: satisfies its Designated Requirement
test-requirement: code failed to satisfy specified code requirement(s)
```

and there we have fun times. The `test-requirement` is failing, and as it has a different requirement structure than app store distributions, the assumption was that Xcode does not support this requirement structure.

### Confirming with Apple:

So my next step was to confirm this with Apple, I ended up using a technical support ticket. And to ensure it was as reproducible as possible I provided a very basic example app with a source editor extension.

I heard back within 72 hours which was great, but the resolution was not what I was hoping for:

> Our engineers have reviewed your request and have determined that you are experiencing a known issue for which there is no known workaround at this time.

But the positive was that it was a `known issue`, so logically it's being actioned right? - Yes, yes it was 🎉 - but was it being actioned in the current public versions?

![Not resolved in current public version](/assets/img/posts/xcode-extensions-code-signing-and-testflight-woes/not-in-current-version.png)

No... no it wasn't

No.. no it wasn't. This is annoying as such a specific issue could be resolved with a patch update. However, it is what it is. On the plus side though, the issue has been resolved in the Xcode 14 beta, which should be public in September 🤞

### Some Links and Resources:

* [**Apple Developer Forum thread I started**](https://developer.apple.com/forums/thread/710925?ref=cheekyghost.com)
* [**Apple Docs on Inside Code Signing**](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements?ref=cheekyghost.com) (has example cli commands etc)

## In the meantime

Okay so not the most ideal setup, so my cautiously optimistic thought to this debacle was:

> I will just give some notarized builds to testers

So, I set up an Apple DeveloperID cert stack, uploaded the stable build/s to the Apple notary service, and then exported a build that would actually appear in Xcode on testers' machines.

What I did not count on was how frequently I was sending out updates and the concept fell apart pretty quickly. Essentially each time I had fixes or improvements it would be:

* Cut a build branch
* Archive
* Upload to notary service
* Export to binary
* Distribute manually to testers
* Wait for feedback
* Repeat

The problem was really that the testers found it disruptive to receive and manually download a build for an app/extension, re-authorize/confirm opening something not on the app store, deal with the permissions around this process, and then remembering to send feedback via email or slack etc.

I don't blame them either, it is cumbersome. The whole point of TestFlight is you can get automatic updates and provide feedback far easier when an issue pops up. So about 2 weeks into this I just stopped in favour of sourcing as many different coding styles as I could to generate from.

## Closing Thoughts

Ultimately relatively soon after realising that the Xcode 14 beta would need to be made public for TestFlight to work, I accepted that I might have to release an app that probably will have a period of quick turn-around improvements and fixes. It's not ideal, I didn't like it, but it is what it is. The irony that this app was built to encourage and aid with testing was not lost on me, however, I did use the generator as it progressed to set up all the tests for the Mimic app in an attempt to eat my own dog food per sè and try to find as many issues as I could 😅

What this whole process did make me realise is how reliant on TestFlight I have become. It's always there in the background, used to distribute builds for internal QA and the like - but most of those projects have gone through the initial teething problems - problems I was hoping to not have for Mimic.

---

Mimic 1.0.2 is Currently available for purchase on the app store!

[![Mimic on the App Store](/assets/img/posts/xcode-extensions-code-signing-and-testflight-woes/app-store-badge.png)](https://apps.apple.com/us/app/mimic-mockgenerator-for-xcode/id1640010185?ref=cheekyghost.com)