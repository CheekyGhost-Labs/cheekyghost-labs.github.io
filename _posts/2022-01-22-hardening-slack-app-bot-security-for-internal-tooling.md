---
title: Hardening Slack App Bot Security for Internal Tooling
date: 2022-01-22 10:00:00 +1000
categories: [casual, security, tooling]
tags: [casual, security, tooling]
image:
  path: /assets/img/posts/hardening-slack-app-bot-security/cover.jpeg
  alt: Hardening Slack App Bot security
  lqip: data:image/webp;
---

## Pre-reading

The idea for this post came from a joke I made recently. The context was that I was made aware (by a friend who still works at a past employer) of someone mimicking what I used to post each day in the company slack channel. I was catching up with some friends (who still work there) and mentioned it in passing, and the response changed from the initial chuckles to:

> "wait, how do you know what is on the company slack?"

This is a completely fair and appropriate response. However, being a sarcastic idiot who speaks in memes, I said (with my best evil voice):

> "*I used the slack bot access token - all your base are belong to us... ha ha ha*"

Again, a few chuckles that faded into a look that said:

> holy crap I wonder if they really are reading our messages

The whole situation sat on my mind for a few days, at first I found myself concerned and thinking:

> *I hope they don't think I was serious.*

and then, upon remembering just how many people usually have access to bot tokens within a company, I found myself thinking about how often i've seen these tokens used for internal tooling... and how most are created as non-expiring.

We all hear horror stories about disgruntled ex-employees and contractors who come across things like these and choose not to immediately delete them. While an unauthorised or unusual message posted using this token would be immediately noticed and actioned, the read-access becomes far harder to notice and detect without strong discipline and access log monitoring.

I wanted to outline a common scenario at workplaces and some steps you can take, both on Slack and internally, to drastically reduce the risk of these tokens being abused.

## Before we start

I want to make it clear that myself, and the other engineers here, **are extremely serious** when it comes to the obligation of **erasing any intellectual property and credentials** from machines when leaving the employ of a business. We actually take pride in how well we facilitate this. Unfortunately, not everyone shares this attitude. Stories about disgruntled employees and contractors are common in our industry, and the outcomes can range anywhere from small inconveniences to major theft and disruption. It is often something minor that is overlooked.

I also should make it clear that I am not the biggest fan of Slack, however, most companies do use it for their general internal communications (or similar tools like Teams). Ultimately, my main concerns revolve around:

*   Slack servers hold all message and file history
    
*   Workspace-level access logs require a paid subscription
    
*   Bot tokens default to long-lived
    
*   The reliance on internal discipline for internal security
    

Finally, some of the setups described may hit close to home. If something feels familiar and you think you might be affected - we would suggest reviewing some of the security suggestions at the end of the post.

## Some Context

> a quick overview of the SlackApp Bot User and what internal tooling looks like

### What is a Slack App 'Bot User'?

A Slack bot user is essentially a user within a Slack workspace that performs read/writes via the Slack API, usually on behalf of a [Slack Application](https://api.slack.com/start/planning?ref=cheekyghost.com). These operations are authenticated using an OAuth setup, and the access token is generated with scope-based permissions.

When you create a [Slack API Application](https://api.slack.com/apps?ref=cheekyghost.com), it also creates the slack bot user for the application. Once created, you can generate an access token for the bot that is fully compatible with the Slack API (restricted to the granted scopes, of course).

When a Slack bot is made, there are two options when it comes to tokens:

*   Enable token rotation (expires every 12 hours)
    
*   Use a long-lived token (non-expiring)
    

A lot of companies we have worked with have opted out of the [Slack Token Rotation](https://api.slack.com/authentication/rotation?ref=cheekyghost.com). The nuance and inconvenience around supporting token refreshing, both on the tooling and admin side, made the long-lived token far more popular. You also **can't disable** token rotation once it is enabled.

As a result, these tokens that companies use:

*   Will last until a token is manually rotated/regenerated
    
*   Has permissions that grant **a lot** of read access and significant write access
    
*   Usually kept in a single place, access is given as needed
    
*   Are added (depending on purpose) to multiple public Slack channels
    

While the single place the tokens are stored is usually a controlled solution like 1Password, as more engineering resources are required to maintain internal tools, more access is given.

### What internal tooling usually looks like:

A **very common** usage of a Slack bot user involves using the generated oauth tokens to access the Slack API for internal tooling. These tools usually involve:

*   Reading a channel's messages
    
*   Reading basic channel member information
    
*   Comparing existing messages against data from a 3rd party service
    
*   Posting or updating new messages
    

Some common tooling contexts we have encountered are:

*   Posting who is on leave or out of the office
    
*   Posting links and feedback to code reviews
    
*   Posting when servers are unreachable
    
*   Prompting and recording time sheets
    
*   Posting reminders about company events and meetings
    

A lot of these tools were achieved by using a CLI executable. This was preferred as these operations usually run periodically and it is easier to install them on different operating systems (macOS, linux, windows etc). It also provided a means for maintaining the source code on an internal repo for other engineers to help maintain.

**Note:**

> It is important to remember that convenience will usually win out over security for internal tooling. The mindset when developing internal tools always differs from when you are working on a public or customer project. Internal tools are often developed faster, with less testing, and less thought into the general design.

### How credentials are stored:

We have not found too many **convenient** options for accessing internal tooling credentials outside of a CI job setup. More often than not, internal tools will usually resolve or request credentials from a far less secure location.

We have found that the most common setups are:

*   CLI requests your tokens during setup and stores them on the machine
    
*   CLI will expect the credentials in some format to exist on the machine
    
*   The executable will be compiled with the token hard-coded in the source
    

When the CLI is invoked, it grabs the token from the pre-determined location, and then uses it to access the various APIs.

## Main Problems

> a run-through of issues around access and security

## Main Problems:

### Who has access to the API credentials?

The previously described setups primarily introduce a few problems around managing access to API credentials. It is great that it becoming common practice for companies to use an access-controlled tool (such as [1Password](https://1password.com/?ref=cheekyghost.com)) to store these long-lived tokens. However, as more engineers contribute to these tools, more access to the tokens is required and granted. Furthermore, it is common for engineering employees to also have basic shell access to machines running these internal tools and executables.

More often than not the token would be stored in a [**1Password Vault**](https://support.1password.com/create-share-vaults/?ref=cheekyghost.com), which one or more engineers would have access to. It would usually start with the admin and dev/team management having access, but as time progresses and things need to get done, access is granted to whoever is working on the tool at the time. It is easy enough to forget to revoke temporary access, but the leak does not usually happen at this level. The manner in which the credentials are stored is where the existing security measures can be undone.

If the tokens are stored on disk, or in plain text, then you would also need to ensure that the same engineer **does not** have access to the machine hosting the tool. If they did, they could simply ssh in and locate the token (or executable) with general ease. You also need to remember that most engineers will build and test their work **on their own machine**, and if the tooling expects the token to be on-disk or in a common location, then it is highly likely the tokens exist on the engineer's machine too.

Another thing to note is that these tools usually require access to **multiple services**. Along with the Slack API, tooling we have seen would also access services such as:

*   Github/Gitlab/Bitbucket
    
*   Online HR tooling (BambooHR for example)
    
*   Internal calendars
    
*   Various portions of AWS services
    

As a result, credentials for these services are all usually stored in the same manner as the Slack tokens, ultimately increasing access vectors.

### What can happen with a leaked token?

With Slack, we found that a lot more permission scopes were granted as the tooling became more feature-rich. There is only one bot user for an application, so anything that is built for a large internal audience will usually have access to a bit more.

Something to keep in mind is that a **lot of sensitive information** can be shared in general internal Slack channels. For example:

*   When someone is taking a sick day/who is on leave
    
*   Someone is running late and when they will be in the office
    
*   Updates on confidential business concerns (funding, new hires, etc)
    
*   Updates on internal bug fixes and security issues
    
*   The list goes on...
    

Because the access tokens the tooling use are non-expiring, if one is leaked it becomes very easy to read the information from these communication channels with great discretion. You can even do it from the Slack API "tester" tab, which lets you paste in a token and perform API operations.

So taking the above into account, here are some things that could happen without taking some basic security precautions:

*   Previous employees/contractors can hold onto these non-expiring tokens
    
*   Tokens can be used to discretely read internal Slack messages
    
*   Tokens can be used to read user profile information (general detail scraping)
    
*   These tokens could easily be shared or sold to whoever wants to pay for them
    
*   Information gathered could be sold to whoever wants to pay for them
    
*   Malicious and phishing messages can be posted as a very trusted source
    

## Slack Based Security Tips

> small things that are not too inconvenient to manage

## Slack Security Tips:

### Restricting token use by IP address:

[Restricting token use by IP address](https://api.slack.com/authentication/best-practices?ref=cheekyghost.com#ip_allowlisting) is the **first and immediate step** you should take when you are using a Slack App for internal tooling. Essentially, this helps prevent unauthorised external use of your token. It also should not cause too many issues as internal tooling should be run on machines owned by the company, and usually on the company network. If the ip address is not in your network (or known ranges), it can be declined by Slack.

If you are using a bot access token from a dedicated machine, you should consider restricting the use of that token to the ip address of the machine. It's dead simple to setup:

*   Head to the slack application settings/admin
    
*   Click the **OAuth & Permissions** from the left menu
    
*   Scroll down to the **Restrict API Token Usage** section
    
*   Add your explicit address, or an address range
    

![Hardening Slack App Bot security for internal tooling](/assets/img/posts/hardening-slack-app-bot-security/ip-restrict-1.png)

![Hardening Slack App Bot security for internal tooling](/assets/img/posts/hardening-slack-app-bot-security/ip-restrict-2.png)

When an engineer needs to maintain or update the tooling, they can simply request the Slack admin/owner to add their ip address to the list temporarily. Once their work is finished, tested, and deployed they can remove it from the list.

**Pros:**

*   Prevents unauthorised use of the access token
    
*   Supports explicit and address range restrictions
    
*   Reduces the risk of tokens that have less restricted access
    
*   Workspace admin access is much much more controlled (usually 1-2 persons)
    
*   Workspace admins have full control over the ip address range
    
*   Engineers can request temporary access for their ip addresses
    

**Cons (or things to keep in mind):**

*   Depending on how many engineers work on a tool, explicit addresses might increase security requests
    
*   Another security review point for security managers and admins
    
*   Does not prevent malicious operations from being run from authorized ip addresses
    

### Reviewing Access Logs:

One of my gripes with Slack is that you **need a paid subscription to review access logs** for a workspace. I think this is a feature that should be available for free.

If you are an admin, and you have not restricted token access by ip address, you should endeavour to frequently review your workspace access logs. It covers general sign-in for accounts, as well as when users and bots access the API. It logs their ip address, user/app name, and what was accessing the service (web app, mac app, api etc).

You can find this by:

*   Opening the **workspace admin**
    
*   Click **Settings & Permissions** from the left menu
    
*   Click the top right **Access Logs** tab
    

![Hardening Slack App Bot security for internal tooling](/assets/img/posts/hardening-slack-app-bot-security/access-logs.png)

Specifically, you can quickly review the IP address access from Slack bots as they have the Slack icon and app name next to them. If an IP address looks unfamiliar - just rotate the token or disable the app immediately.

**Some notes about recourse:**

The nice thing about having the IP address logged is that it makes it easier to determine if the access was **intentional or not**. If an employee's access has been revoked, but they are in the process of removing artefacts and credentials etc, you might see one or two access logs around the time they left - this is probably fine.

However, **if you see infrequent repeated access** past the time they left, then you should disable the app or rotate the token immediately and decide if you think access is intentional or not. If the employee is someone **you don't think would be intentionally malicious**, a good additional step is to reach out and just politely ask if they have overlooked something when they were off-boarding. Most of the time the response is from an embarrassed engineer saying:

> *I am so sorry. I have removed this and apologize for any inconvenience caused.*

### Reviewing channel access:

Slack bot users can only access channels they have **been added to**. If your default is to add the app to new channels, this can cause some issues if someone gains access to your token.

As noted earlier, **a lot of sensitive information** can be shared in general channels. If someone has a token that gets read access to these, they can usually go unnoticed for a long time. If you have a paid subscription, you can monitor the access logs for a workspace, but this really depends on the discipline and time your admins have.

A great step you can take right now is to look at the purpose of your Slack app/bot and make sure it is confined to a **single and purposeful channel**.

For example, let's take the internal tool of posting who is on leave. It is far more ideal to have a single "#office-leave" channel rather than giving access to a more general channel for the posts. This way if a token is being used to read messages in a channel, the content is at least restricted. It is not ideal that they are being read, but it at least reduces the effect.

### Enable Token Rotation:

[Token rotation](https://api.slack.com/authentication/rotation?ref=cheekyghost.com) is one of those things that can be considered an inconvenience, and it does not really solve the issue of where to store client keys/secrets and refresh tokens. However, what it does do, is make it harder for external entities to maintain their access discretely. Refreshing a token will appear on the access logs, and anyone wanting to keep long-term access would need to keep track of the client id and secret at a minimum.

You can set this up pretty easily by:

*   Open the application admin area
    
*   Click the **OAuth & Permissions** item in the left menu
    
*   Enable token rotation in the **OAuth Tokens for Your Workspace**
    

![Hardening Slack App Bot security for internal tooling](/assets/img/posts/hardening-slack-app-bot-security/token-rotation.png)

**Note:** If you already have a non-expiring token, you will need to exchange it for a rotating token. The easiest way is to use a curl command:

```swift
curl -XGET "https://slack.com/api/oauth.v2.exchange?client_id=<client_id>&client_secret=<client_secret>&token="
```

This will ensure your previous non-expiring token is no longer valid and a rotating token is used. Your CLI or scripts can detect when an API request fails due to an expired token and can simply refresh it as part of their general operations.

**Pros:**

*   This makes it more difficult to maintain long-term external access
    
*   It reduces the risk of tokens that have less restricted access being used
    
*   Workspace admins can easily regenerate the client secret for token management
    
*   Workspace admins can easily alter scopes for a token
    

**Cons (or things to keep in mind):**

*   Token rotation **cannot be turned off** once it is enabled.
    
*   The client id, secret, and a refresh token still need to be used to refresh access
    
*   The storage location for the client id/secret will probably have the same issues as the long-lived token
    
*   Another security review point for security managers and admins
    

## Internal Security Tips

> minor considerations to make when implementing your tooling

## Internal Security Tips:

### Build your CLI for use by a CI utility:

One common issue with using a CLI or script for these kinds of tools is that the credentials are stored in a somewhat insecure manner. This is mainly due to the requirement of it being an **internal tool**.  When something is internal, it is easy to overlook a few things in favour of convenience and development speed. So while you may have limited access to the machines that host the executable or script, storing credentials in an insecure manner on these machines can lead to some security issues in the long run.

One approach we looked at during the planning phase was to design the CLI tool to be used by a CI utility. CI utilities, like Jenkins/Github/Gitlab, often have support for **CI Variables.** A CI Variable is a key-pair-based value that usually only admins or project owners can control, and other users can utilise but not view/edit the value.

With this in mind, we figured that we could force each CLI command to also require the access token (or client id/secret etc for rotating tokens) as an input. We found that this allowed admins to tightly control what credentials are being used in an already tightly controlled environment. It also meant that we would not need to locally store any credentials during setup (manual or automated).

For example:

*   Admin/Owner of the CI can create a masked variable named SLACK\_BOT\_TOKEN
    
*   Non-admins/owners can use the value of this token via the SLACK\_BOT\_TOKEN variable name
    
*   Non-admins/owners are unable to edit or view the raw contents of this variable
    
*   The token is not logged or posted in the console outputs
    

This means that you can set up a recurring operation on your CI that manually invokes the command using these variables:

```swift
SomeTool fetchLeaveSummary --token SLACK_BOT_TOKEN SomeTool fetchLeaveSummary --clientId SLACK_CLIENT_ID --clientSecret SLACK_CLIENT_SECRET // etc
```

### Setup a scheduled token rotation:

If using the built-in token rotation is not an ideal option, you should discuss and schedule a frequent time to **manually rotate** any slack access tokens. Your management and security officers **will never be annoyed** if you want to discuss potential security risks, and it is a great way to make sure everyone is on the same page on the purpose of the tool, and what it is accessing.

Rotating tokens is one of those short-term pain/long-term gain deals. Ideally, you should look at performing these rotations:

*   Once every 3 months
    
*   When you off-board an employee or contractor
    
*   When you suspect someone unauthorised may be accessing your Slack communications (intentional or not)
    

## Wrapping Up

## Summary

To summarize, SlackApps and Bot Users are excellent ways to create some useful internal tools. From automation to advertising internal work, they can provide a maintainable and testable solution.

However, depending on how you implement these tools, you should set up a meeting or Zoom call with your general manager and security officer to discuss any credentials and who should have access to them. It is a great chance to discuss how the tool will work, and what services it will access, and gives your security officer a chance to review key security points.

A general check-list:

*   Restrict slack bot user token use by IP address ([documentation](https://api.slack.com/authentication/best-practices?ref=cheekyghost.com#ip_allowlisting))
    
*   Enable token rotation ([documentation](https://api.slack.com/authentication/rotation?ref=cheekyghost.com))
    
*   Setup a scheduled review of the access logs for your Slack workspace
    
*   Setup a scheduled token rotation (if the token rotation feature is not available)
    
*   Use 1Password for storing the token
    
*   Tightly control who has access to the vault that contains the token
    
*   Consider making a CLI that **requires** credential input with the command. CI's can utilise this, and it means you don't have to store credentials locally.