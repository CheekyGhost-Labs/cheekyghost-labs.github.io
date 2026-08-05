---
title: My Problem With Contacts
description: Reviving the Consynki app with a focus on privacy
date: 2023-02-14 10:00:00 +1000
categories: [privacy, product]
tags: []
image:
  path: /assets/img/posts/my-problem-with-contacts/cover.png
  alt: My Problem With Contacts
  lqip: data:image/webp;
---

*Reviving the Consynki app with a focus on privacy*

Sharing contact information is an essential part of networking and connecting with others on various services and applications, however, the way details are currently shared and accessed feels a bit on the '*fast and loose*' side. Mix this with services requiring you to upload your address book to search for people that **might** also be using the service, and you can start to see a few privacy holes and general flaws.

## Some Context

For some context, I have never liked the contacts app on mobile phones (or desktop/web etc). It's something that has not changed in forever, and when it comes to making yourself reachable by others, these applications do not provide the privacy that (I feel) should be facilitated. There are a few services around today that endeavour to make the process easy, some friends and I also built an app a while back too and fell into the same traps.

This post looks at that app, the lessons we learnt, and introduces a new project I am starting in the contacts space named `Deets` (name will probably change). It is more accurate to describe this project as **revisiting and reviving** a previous service my friends and I built named `Consynki`, but with more experience and a stronger focus on privacy and enabling developers.

A quick TLDR; on Consynki:

Consynki was a service (with a companion app) that let you manage your own contact information, and then connect with others to share your profile with them. You could control what contact details a connection could see via a simple tagging/grouping system (i.e. "work" and "personal" etc).

The core approach for the experience revolved around:

* You manage your own contact information
* Connect with other people who manage their contact information
* When you change your details your connections don't need to update your info themselves
* When your connections change their details you don't need to update their info yourself
* Provide visibility/access control to ensure you control both **who** has the means to contact you, and **what** means they can contact you with.

The new project "Deets" will still revolve around the same core question we had when we built Consynki:

> "Why do I have to update the contact details for someone else"

however, I want Deets to have a stronger focus on privacy, simplifying the education of the privacy mechanism from an experience perspective, and to look at addressing some of the "leak" points where your information could still be made visible.

My ultimate goal with this new project is to provide a means to connect and contact others without having to directly share your actual details. I also want to investigate providing an API, SDK, and app extensions/plugins to facilitate contact searching and autofill etc. While full [Homomorphic Encryption](https://en.wikipedia.org/wiki/Homomorphic_encryption?ref=cheekyghost.com) is unfortunately not quite there yet in terms of efficiency and practicality, I want to look at leveraging some existing standard technologies to facilitate this idea. Fortunately, with technologies like WebAuthn/FIDO (PassKey) becoming the new standard, there are some options I think have merit that will provide a flexible and scalable starting point.

So let's begin, first with what my mindset is about the current state of contacts.

## My problem with Contacts

As stated earlier, sharing contact information is an essential part of networking and connecting with others on various services and applications. However, immediately there are some things that always bugged me from an experience and concept perspective:

* Why do I have to manage the information of someone I know?
* Why does someone need to see my phone number, email, username etc when they just want to call/email/open a profile etc
* Why should I have to upload my contacts to find someone that only **might** be using the same service
* Why do companies insist on the contact uploading approach (regardless of how "secure" they say they can make it
* Am I okay with sharing my contact information in a public manner knowing full well it is quite hard to completely undo (without pulling the entire profile), and knowing they could share that information themselves to anyone

As stated before, Contacts for the most part have not changed forever. The contacts app, functionally speaking, has not changed since its launch. Designing a contact form or autofill seems to always take the same approach. Sharing your contact information involves a manual step, or sharing a link to a mostly public profile. When a profile is wrapped behind an auth/connection wall, the raw contact information is still visible in plain text once access is given. Traditionally, when you share your contact information with someone, that person manages that information themselves. These details are usually stored on a smartphone or desktop environment in a native *Contacts* application, but the information is now completely controlled by someone that you have to trust will act responsibly.

There are numerous services that have appeared and gone away (Consynki being one of them), and there are also numerous services around today. When my friends and I entered this space back in 2015-ish, the main focus was on solving the issue of having to manage the details of someone else, this trend has fortunately continued and approaches seem to always shift focus between social and networking. The problem for me comes with the way this information is stored and shared. The larger a service grows, the bigger its target it becomes. It's great for the business that their user base is growing, but it's the attacks you don't hear about that are making a lot of money off these sites. I always seem to come back to the questions and concerns I previously mentioned.

Most of the services I have looked into also rely on obfuscated urls to share their end data (profile/contact card/information). A common setup (from the services I have seen) is that you create a profile or card that gets created under your user id along the lines of `https://someservice.com/user_id/cards/123abc` and you share a url to the card, which equates to something along the lines of `https://someservice.xx/123abc`. Arguably there is an element of security using obfuscation, in that it is quite tricky to de-obfuscate urls and writing a crawler/scraper would take some time. However, depending on the tech stack or vendor used to drive the service, there are other ways to poke and prod and leverage exploits to list out shared data from users. For some this may not be a concern, for me, however, I see it as a risk... *tightens tin foil hat*. Find someone with slightly fewer morals and a bit of time and they could discreetly resolve and collate data into a profitable database to sell to the highest bidder.

Once you share your details, even if via an obfuscated URL, that information is available to whoever has the URL. This may be the point of some services, but for me this is not what I want. I don't like that someone else can share that url, or copy/paste the information wherever they want. While ultimately, at some point, even a privacy-focused solution will have this issue - in that even if you call a number via a  convenience action it will still show in the call history and recipient area of the phone app (same with messaging and email etc) - but there is nothing wrong with making it more difficult if you can provide a nice experience around it.

Another issue I have with the state of contacts, and related services, is that it led to the adoption of the "upload your contacts" approach for finding people you know on various services. My *personal* take on this is that if I see an app or service using this approach - I delete my account and keep my distance. They can advertise that it is "secure" as much as they like, drop buzz words and say "it's end to end encrypted"  and promise that "they are thinking about your privacy and experience" all day long - but all I see is a shortcut being taken rather than build a better means for their users to discover and connect that actually compliments their platform.

Uploading the contact information of people that trusted me to use it responsibly always irked me. Ultimately, I just don't think it's fair that I get to decide what to do with **someone else's details**.

Finally, as a designer and developer, it frustrates me that if you want to facilitate pre/autofill in an app (mobile, web or other) then you are constrained by inconsistent implementations and mechanisms. If the product has it's own contacts setup then:

* You are limited to those you have added and are managing (inconvenience)
* That information has to be managed twice (inconvenience)
* You are putting someone else's information on another service (risk)
* Depending on the company, you have to push for API or SDK support

If the product uses an external service, there are the same concerns but with more risk (depending on the service). If the product integrates the native platform options (Apple Contacts for example) there are a few options that suffer similar concerns, but also introduce other complexities.

Ultimately, I don't like the current state of contact management. I certainly don't have the magic pill to solve it, however, there are some concerns I think can be addressed quite sensibly.

## Consynki

### (it's long dead)

So some friends and I built "Consynki" back around 2015/2016. We decided to build it when our friend was planning their wedding and realised he had out-of-date information for people he was trying to contact. He would get back the classic "Who dis?"/"Who is this?" message and was complaining about it - to which we replied, "yeah why should they have to update your number when you change it?"

### What was it?:

Consynki was a simple service and application based around solving the core question of:

> Why should I have to manage someone else's contact information?

The question led to a solution that had been built before in one way or another:

* Users manage their contact profile
* Users share their profiles with people
* User A/B updates their info
* User A/B's info is then synced to their connections

A good comparison is pretty much any profile-driven social or network service. You maintain your profile, you connect with others, and they can read your profile and get alerted when you update your info. At the time however, privacy was not the biggest concern for the majority of these undertakings - the topic of privacy usually drove the focus to "data security" which was usually answered with *"make sure data is encrypted at rest"* - and at the time this wasn't always implemented well 😅 So while we did ensure the data was "secure" at the time, the larger question of privacy and data security was not a problem we were equipped to solve. The conversation did lead us to also introduce a basic form of access control for a profile, however,

* Users tag contact details with one or more tags "work" "family" "personal" etc
* Users assign these tags to connections
* Connections can only see contact details with matching tags

Once the data synced to the device, however, users could read/copy/do whatever with it. If you turn your internet off, you would never sync the permissions removal etc

The last thing we did, which in hindsight could be argued as both good and bad, provided the functionality to sync data from Consynki automatically to the application's Contacts app. In theory, it sounded good, so any native apps that used the Apple/Android contacts SDKs for pre/autofill would be using the latest contact information. What it did do, however, is lead to annoying comparison code and most likely users wondering why they would use both contacts and Consynki.

### Technical Strategy:

From a technical perspective, the project was pretty straightforward:

* The server provided an API and stored data
* API was over SSL
* A web app was in the works
* Mobile apps used the hosted API to send/receive data
* Mobile apps locally store synced data for offline use
* Local storage used platform disk encryption
* Mobile apps synced details to the native contacts app

I won't go into the nitty gritty but suffice it to say that it was a pretty standard approach to a data-driven application. We didn't want to over-architect it, and while I am not the biggest fan of the term "fail fast", we wanted to have something scalable and flexible for any learnings.

### Design Approach:

**Note:** Some of these may have been from the re-designed but never released update 😅

Design-wise we approached the app with the following three concepts in mind:

* The contact sheet should provide standard details + social links
* The profile should be as clean as possible to avoid it appearing noisy when a user has heaps of details
* A contact sheet should provide quick action links to calls/email/message etc
* When possible we should introduce a mascot

Ultimately it ended up looking pretty standard, here are some old screenshots from the app (or from a re-design back when):

![Consynki app screenshot](/assets/img/posts/my-problem-with-contacts/consynki-screenshot-1.jpeg)

![Consynki app screenshot](/assets/img/posts/my-problem-with-contacts/consynki-screenshot-2.jpeg)

![Consynki app screenshot](/assets/img/posts/my-problem-with-contacts/consynki-screenshot-3.jpeg)

![Consynki app screenshot](/assets/img/posts/my-problem-with-contacts/consynki-screenshot-4.jpeg)

![Consynki app screenshot](/assets/img/posts/my-problem-with-contacts/consynki-screenshot-5.jpeg)

It served its purpose, and let us get a product out pretty fast. Was it the best-designed app? No - was it functional and stable - Yes... for the most part.

### Pain Points and Lessons Learnt:

I learnt quite a bit from the Consynki endeavour, mainly about user complacency, convenience not equating to function, and that there was much more to the problem space of contacts and networking than just sharing information:

* Your typical user may have plenty of contacts, but they rarely keep all of them up to date
* People didn't want to directly enter or copy + enter details to contact someone
* Users would re-enter their information rather than import from their contact sheet in the native contacts app (implying they don't keep their own info up to date?)
* Your typical user had the same level of trust when giving someone access to their contact profile as they did provide their details directly to someone they know
* People were open to privacy, but only if it was simple and things still "just worked"
* People trusted when they read that "your data is secure" without researching what that meant

Another thing I better understood after this was around increasing usability by removing functionality - which sounds odd - but TLDR; just because there is an address section in the native contacts applications does not mean you inherently need to support it 😅

Ultimately we all had aspirations in progressing our career paths, which led to us not continuing to work on Consynki, which led to it being taken down and discontinued.

## Deets

### Revisiting Contacts

I have always wanted to revisit the Consynki concept, primarily as there is not a service I have found that achieves what I want - both from a functional and privacy perspective. Now that I have researched and worked in the privacy and security sphere for a bit (last 8 years), I wanted to see if I could find a happy medium in the contacts space, or at least learn new lessons.

## Goals for the project:

Approaching this, I have a list of things I want to achieve:

* Utilize passwordless authentication. Ideally PassKey due to the cross-platform and browser support
* End-to-End encrypt contact data
* Enable users to only manage their own information
* Provide as simple connect and share experience as possible
* Avoid showing contact information in plain text where possible
* Look into app extensions to enable other applications to fill in contact details
* Look into using the app extension to search for your connections using the same services as you
* Open source the project
* Share any learnings and products with others in the Contacts space

I also want to look at the practicality and risk around:

* Providing a secure API to interact with the service
* Providing an SDK for developers to use within applications

however, due to the way Passkey stores credentials, the above may be a lower priority than the app/browser extension initially. There may be sandbox or security grouping enforcements that prevent use in other apps/services. Will be interesting to look into.

Ultimately, my goal is to create a privacy-focused contacts service. Ideally, from a user perspective, they should be able to:

* Create an account on a native mobile app or web-app
* Fill out their profile
* Import initial info from their contacts app (if they feel comfortable doing so)
* Access their account from Android, iOS, or web (passkey-driven)
* Connect with other users via a re-usable profile element
* Access contact info in other applications or websites via app/browser extension (think 1Password style)
* Provide (in the extension) to search for connections using the same service as you

In terms of connecting with other users, my initial thoughts are around:

* User creates a "connect with me" link they can share
* Users already on the service can scan/follow this link to send a connection request
* Users not on the service can very quickly create an account with PassKey in their browser when they follow the link. A connection request will then be sent.
* Users can also send a one-time "access my deets" request to other users to initiate a connection
* Users have full control over what details are shared with their connections via a simple grouping/tagging setup

From the design side, ideally, I would like to provide an app and browser extension similar to 1Password to provide a means for other applications to leverage iOS, Android, and Web autofill functionality.

For a stretch goal from the technical side, ideally, I would like to provide a secure API and SDK to enable developers to:

* Allow users of their application to authorize their Deets account to be accessed via PassKey
* Initiate contact methods, such as calling, sms, email etc without having to present the actual contact details
* Pre-fill information as needed within their application

The API/SDK does provide challenges and may not come to life. As noted before, sandboxing and related security may prevent this from being practical. There is also the question of  "what is the risk of other applications accessing the service in this manner" that comes to mind. However, even if the answer is "no this is not ideal/practical" I still want to look into the optionality.

### Notes on Extensions/Browser Plugins:

I referenced 1Password earlier as it is the simplest comparison for the purposes of this post. Ultimately the goal is to provide a means to populate valid fields with your connections details as simply as possible. In the mobile space, it might be an app extension that you can select a connection from and have it populate the field/s you are filling out, it might also be a custom keyboard that lets you achieve the same task. On the web side, it may be as simple as having a browser plugin that detects a contact form field and lets you select a connection to pre-fill with. There will be some minutia around this of course, but from a design perspective, it is a pretty clear goal.

## Tech Stack:

I try not to start with the 'how' for a product or service, however as the 'why' is pretty well defined, I have landed on some technical decisions

* The server will be written in either Swift or Elixir
* Will hopefully contribute to and use the Swift WebAuthn library if Elixir is not chosen
* Can use [passwordless.dev](https://www.passwordless.dev/?ref=cheekyghost.com) to fast track the authentication if the Swift WebAuthn is not at production yet
* iOS App will use SwiftUI with a CLEAN and modular architecture
* The Front-end web app will use a minimal approach in terms of dependencies and libraries
* Android app will use Jetpack Compose + Flow (lower priority)
* Will use an Atomic Design system for delivering branding and designing UI components

## Cold Start Problem:

This is a project that relies on networking effects, and while initially the target audience may be specific, if this is something that I want to build into a product I will need to keep that in mind as decisions are made and things come to life. The Cold Start Problem is something that will always be on my mind and influence numerous decisions. It is a great read/resource, and for more insight into this I would recommend picking up a copy of [The Cold Start Problem](https://www.amazon.com.au/Cold-Start-Problem-business-launch-pad/dp/1847942784/ref=sr_1_1?adgrpid=84377689102&gclid=EAIaIQobChMI4-jG4pSW_QIVwV1gCh3ewAgcEAAYASAAEgI8t_D_BwE&hvadid=591228529574&hvdev=c&hvlocphy=1000339&hvnetw=g&hvqmt=e&hvrand=2397843973135254459&hvtargid=kwd-1164758991056&hydadcr=8244_357829&keywords=the+cold+start+problem&qid=1676417212&sr=8-1&ref=cheekyghost.com)

As privacy is the focus here, I will also need to ensure that anything I introduce endeavours to streamline the user experience. Often privacy features can compound the cold start problem, and my approaches to this will change as the project evolves. My goal remains the same from the experience side, however, it will be very interesting to see if and how the target audience and product direction change when accounting for some of these topics.

## Open Issues:

I noted earlier that some issues will still exist with this approach, specifically around the following:

* Even if data is not visible, when the act of contacting happens (call/sms/email etc) the shared contact detail may be visible in the call history, message recipient etc
* The person you shared the information with could still leak your info if they wanted to
* If an offline mode is enabled, removing access to a connection needs to sync with the server before this takes place

I don't have the solution to the above issues (not yet anyway), but my main goal is to make it as inconvenient and difficult as possible to abuse the setup. Most people who would use a service like this would not be gearing to share your info around.

## Timeline/Roadmap

### (a rough estimate)

I have already begun work on Deets, mainly from a design and product side. However, now that I have some clear requirements and goals outlined I am planning on the following rough timeline (subject to life of course):

### February:

* Finalise tech stack decisions
* Finalise branding and foundational Atomic Design system
* Setup hosting

### March:

* Complete authentication stack on the foundational server
* Complete core database storage setup
* Complete user account structure and add grouping/tagging support
* Complete initial user connection mechanics

### April:

* Complete initial contact detail support
* Build iOS app with a focus on functionality

### May:

* Build web app
* Finalise design system UI components

### June:

* Style/Polish iOS app
* Style/Polish Web App
* Explore extension/plugin approaches

### July:

* Finalise extension/plugin approaches
* Open Source project

### August:

* Write an Android app if can't find someone who is better at Android to do it

## Wrapping Up

So it is an ambitious timeline, but have always done that 🙃 Ultimately I have been wanting to revive Consynki with a focus on privacy for the last 5-6 years, and now that I have the time to focus on it, I fully intend to. I am also wrapping up the open-sourcing of the library powering [Mimic](https://cheekyghost.com/mimic) over the next month, so will have a bit more time coming my way then too.

Contacts have always bugged me, and the outcome of this project should ultimately be one of the following:

* Many great lessons learnt
* Many great lessons learnt + a successful product
* Many great lessons learnt + a successful service

so it's a win regardless from my perspective. I am excited to build this, mainly as it has a clear purpose (which is what ultimately drives passion), am also looking forward to sharing (or ranting and grumbling) about the many road bumps along the way 😅 Am also excited to work on something that I intend to open-source as I like to keep my code quality, documentation, and testing up to (my own) strict standards.