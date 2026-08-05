---
title: OSLogClient
description: adopting unified logging with OSLog while still sending to other vendors
date: 2023-09-04 10:00:00 +1000
categories: [ios, swift, tooling, open-source]
tags: []
image:
  path: /assets/img/posts/oslogclient/cover.png
  alt: OSLogClient
  lqip: data:image/webp;
---

*adopting unified logging with OSLog while still sending to other vendors*

## Context:

Recently, both in personal projects and at work, I have wanted to adopt `OSLog` for a more unified logging approach across swift projects (spanning iOS, macOS, server, CLI tools etc.).

However, a lot of projects (mainly at work) were set up to send logs to one or more external vendors/services. So I kept coming to the same question:

> How might we utilise `OSLog`, which has its own `Logger` instance type, and still support these external vendors or additional log processing?

This post goes into why OSLog is a great option for unified logging, and then into an overview of the `OSLogClient` library I am using moving forward. You can check out the project on GitHub here:

[https://github.com/CheekyGhost-Labs/OSLogClient](https://github.com/CheekyGhost-Labs/OSLogClient)

## Why OSLog?

`OSLog` was introduced as a replacement for the ever-common `print` and `NSLog` methods. For approximately 7 years now, Apple has been recommending and pushing `OSLog` as it offers numerous benefits and enables you to leverage the use of the console app with far more direction. With Xcode 15 coming out of beta soon, it's also a great time to switch as a more enriched logging experience is available via the new Xcode 15 logging console.

OSLog also archives on the device for later retrieval and has an incredibly low-performance overhead. Between the Console app or Xcode 15's logging console, achieving a structured approach to logging with OSLog becomes a far better option than using print statements.

### Availability:

`OSLog` has been available since:

* (as [**os_log**](https://developer.apple.com/documentation/os/os_log)): iOS 10, macOS 10.12, Catalyst 13, watchOS 3, tvOS 10
* iOS 14.0, macOS 10.10, Catalyst 13.0, watchOS 7.0, tvOS 14.0, VisionOS 1.0

The `OSLogStore` that enables this library (more details further down) as introduced in:

* iOS 15.0, macOS 10.15, Catalyst 15.0, tvOS 15.0, watchOS 8.0, VisionOS 1.0

So for all intents and purposes, any references to `OSLog`, `OSLogStore` and `Logger` are based on supporting the minimum versions where `OSLogStore` was introduced.

## Shiny Features:

`OSLog` also comes with some awesome conveniences and niceties related to log security and privacy, preventing PII from being leaked, and providing some awesome formatting options.

These features are available alongside the standard string literals and interpolation that you would expect to use when leveraging the `print` statement.

**Data Privacy:**

For example, let's say you want to write to the log when a user has authenticated but want to keep the username private, using the `Logger` instance from the `OSLog` setup you can simply ask for that value to be made private:

```swift
let logger = Logger(subsystem: "<bundle-id>", category: "ui")

let username = "account@domain.com"
logger.info("User '\(username, privacy: .private)' authenticated successfully")
```

When this method is invoked and attached to the debugger you will see the expected output:

`"User 'account@domain.com' authenticated successfully"`

However, when not attached to the debugger (production, beta testing, not plugged into the machine etc.) the `privacy:` helper will ensure the value is masked and stored:

`"User '<private>' authenticated successfully"`

There are a bunch of variants for this, including the ability to replace the value with a hashed version of the original:

For example:

```swift
logger.info("User '\(username, privacy: .private(mask: .hash))' authenticated")

// Outputs
// "User: <mask.hash: 'KqOmkNC7ohZ77MFM7VtkNA=='> authenticated"
```

**Formatting:**

Another nicety is being able to format log contents to make messages in the Console app far more readable. This is both from an alignment and human-readable perspective.

For human-readable formatting, if we take a look at a few examples:

```swift
let seconds: TimeInterval = 12345.67985
let boolFlag = false

logger.info("Seconds: \(seconds, format: .fixed(precision: 2))")
logger.info("is flag enabled: \(boolFlag, format: .answer)")
logger.info("is flag enabled: \(!boolFlag, format: .truth)")

// Outputs are much more readable now:
// "Seconds: 12345.68"
// "is flag enabled: NO"
// "is flag enabled: true"
```

There are of course a fair few more options than the above, and they will auto-complete based on the inferred type of the value you are logging:

```swift
// The formatting options for Boolean values.
OSLogBoolFormat

// The formatting options for integer values.
OSLogIntegerFormatting

// The formatting options for 32-bit integer values.
OSLogInt32ExtendedFormat 

// The formatting options for double and floating-point numbers.
OSLogFloatFormatting

// The formatting options for pointer data.
OSLogPointerFormat
```

You can check out the docs for these here:

* [**Message Argument Formatters**](https://developer.apple.com/documentation/os/logging/message_argument_formatters)

As for alignment, let's say you are logging a few bits and bobs:

```swift
let logger = Logger(subsystem: "<bundle-id>", category: "network")

func logRequest(_ request: RequestType) {
    logger.debug("\(request.timestamp) \(request.apiSpace) \(request.url)")
}

// Outputs
// [network] 02-09-2023-14:30:30 users https://domain.com/api/v1/some/rest/component
// [network] 02-09-2023-14:30:30 calendars https://domain.com/api/v1/some/rest/component
// [network] 02-09-2023-14:30:30 connections https://domain.com/api/v1/some/rest/component
// [network] 02-09-2023-14:30:30 users https://domain.com/api/v1/some/rest/component
// [network] 02-09-2023-14:30:30 calendars https://domain.com/api/v1/some/rest/component
// [network] 02-09-2023-14:30:30 connections https://domain.com/api/v1/some/rest/component
```

The outputs can become a bit jarring when some sections are different lengths. In the above example, the URLs jump around a bit based on the API space name.

However, using `OSLog` formatting, you can simply tell the log command to align these using the `align: <>` helper:

```swift
...
let maxSpaceLength = APISpace.longestName.count
logger.debug("\(request.timestamp) \(request.apiSpace, align: .left(columns: maxSpaceLength)) \(request.url)")
...
```

This alignment will make the logger output a more readable set of messages:

```swift
[network] 02-09-2023-14:30:30 users        https://domain.com/api/v1/some/rest/component
[network] 02-09-2023-14:30:30 calendars    https://domain.com/api/v1/some/rest/component
[network] 02-09-2023-14:30:30 connections  https://domain.com/api/v1/some/rest/component
[network] 02-09-2023-14:30:30 users        https://domain.com/api/v1/some/rest/component
[network] 02-09-2023-14:30:30 calendars    https://domain.com/api/v1/some/rest/component
[network] 02-09-2023-14:30:30 connections  https://domain.com/api/v1/some/rest/component
```

## OSLogClient: The Problem It Solves:

So `OSLog` is available, which is awesome, however as mentioned earlier, a lot of developers are working on projects that use a bespoke logging service or mechanism. For example, you may be working on a project that sends your logs to NewRelic, Firebase, or stores them to a local file.

So again:

> How might we utilise `OSLog`, which has its own `Logger` instance type, and still support these external vendors or additional log processing?

Well fortunately `OSLog` provides access to a type named `OSLogStore`, which can be queried for recent logs made by `OSLog` 🎉.

The `OSLogClient` library aims to bridge the gap highlighted by the above problem statement by acting as an intermediary to this `OSLogStore` type, enabling developers to leverage the strengths and convenience of `OSLog` and forwarding them into custom logging mechanisms. It does this by polling the underlying `OSLogStore`, assessing the logs, and then forwarding the **post-processed** log messages to registered `LogDriver` instances. As a result, a registered `LogDriver` can receive log messages with all OSLog-based privacy, security, and formatting intact. The driver will also receive metadata such as date-time, log level, logger subsystem, and logger category.

## Architecture Overview:

At a high level, the library is fairly simple. Its main goal is to abstract a client that polls an `OSLogStore` instance and send any valid logs to a registered `LogDriver` instance:

![OSLogClient architecture overview](/assets/img/posts/oslogclient/architecture-overview.png)

If we take a look at a control of flow sequence:

![OSLogClient control flow sequence](/assets/img/posts/oslogclient/control-flow-sequence.jpeg)

It's a fairly straightforward control of flow:

* The client will invoke the poll functionality at the assigned interval
* The poller will query the `OSLogStore` instance
  * If the last-fetched is known (not the first run) a predicate to only include the latest logs will be used
* Valid logs are sorted by date
* For each registered log driver
  * Iterate through the retrieved logs
    * If the source of the log is valid
      * Invoke log handler method on driver
    * If the source of the log is not valid
      * Take no action
* Store the date-time of the last processed log for future queries

## Why not abstract/wrap the Logger?

I looked into a fair few options for adopting `OSLog`, and ultimately I chose not to attempt an abstraction around the `Logger` instance (or similar setup) for a few key reasons:

* You lose access to the privacy, formatting, and alignment features noted earlier
* You would lose access to the additional metadata the `OSLog.Logger` instance captures, as there is no way to wrap the instance and still pass along things such as line, and file etc
* Developers would be beholden to my schedule (or open-source contributions) to add support for any new `OSLog` features and improvements
* Sending a 3rd party logging instance around an entire application introduces a strong coupling
* Removing the library becomes more tedious and complex depending on how coupled and heavily it is utilised across the code base.

With the approach `OSLogClient` takes, the developer has complete opt-in capabilities from a single location in their code base. If they want to stop using it, they can simply retire their custom `LogDriver` instances and remove the package. As the rest of the application is using the standard `OSLog.Logger` instances, nothing needs to change. This is a very non-destructive approach 🙂

## Usage:

### Basic:

Using the `OSLogClient` is straightforward. Below is a simple guide to get you started:

```swift
// Import the library (OSLog is also included in the import)
import OSLogClient

// Initialize the OSLogClient
try OSLogClient.initialize(pollingInterval: .short)

// Register your custom log driver
let myDriver = MyLogDriver(id: "myLogDriver")
OSLogClient.registerDriver(myDriver)

// Start polling
OSLogClient.startPolling()
```

With just these steps, `OSLogClient` begins monitoring logs from `OSLog` and forwards them to your registered log drivers, leaving you to use `OSLog.Logger` instances as normal:

```swift
let logger = Logger(subsystem: "com.company.AppName", category: "ui")

logger.info("Password '\(password, privacy: .private)' did not pass validation")
```

When your driver gets the log message, it will be the processed message that ensures any privacy and formatting have been applied. For example, when not attached to a debugger, the above would invoke with:

> `"Password '<private>' did not pass validation"`

### Subclassing LogDriver:

While the base LogDriver class provides the necessary foundation for handling OS logs, you can easily subclass it for custom processing, such as writing logs to a text file:

```swift
class FileLogDriver: LogDriver {
    let logFilePath: String
    
    init(id: String, logSources: [LogSource] = []) {
        self.logFilePath = logFilePath
        super.init(id: id, logSources: logSources)
    }
    
    override func processLog(level: LogLevel, subsystem: String, category: String, date: Date, message: String) {
        let logMessage = "[\(date)] [\(level)] [\(category)] \(message)\n"
        if let data = logMessage.data(using: .utf8) {
            try? data.append(to: fileURL)
        }
    }
}
```

While the above example is quite contrived, you can see how you might introduce custom log drivers for other scenarios. For example:

* **FirebaseLogDriver**: Forward any received logs to the `Crashlytics.log` helper
* **NewRelicLogDriver:** Forward any received logs to the `NewRelic` SDK log helpers
* etc

### Filtering Logs with LogSource Filters:

Instead of only assessing log level, date, and category in the `processLog` method, you can fine-tune which logs should be processed by a `LogDriver` instance by specifying valid `LogSource` enum cases.

If log sources are present on a log driver (i.e., the list isn't empty), they're used to evaluate incoming log entries, ensuring there's a matching filter.

Currently, there are two source options are supported:

```swift
// Includes logs where the subsystem matches the provided string.
.subsystem(String) 
// Includes logs where the subsystem matches the provided string and
// the log category is in the categories array
.subsystemAndCategories(subsystem: String, categories: [String])
```

For instance, to configure a log driver to only receive `ui` and `api` log entries:

```swift
let apiLogger = Logger(subsystem: "com.company.AppName", category: "api")
let uiLogger = Logger(subsystem: "com.company.AppName", category: "ui")
let storageLogger = Logger(subsystem: "com.vendor.AppName", category: "storage")


myLogDriver.addLogSources([
    .subsystemAndCategories(
        subsystem: "com.company.AppName", // Only listen for subsystem "com.company.AppName"
        categories: ["ui", "api"] // Only listen to "ui" and "api" categories
    ),
])
```

With this setup, logger instances work as usual, but the driver will only capture logs validated by at least one log source:

```swift
// Driver will capture these logs:
apiLogger.info("api info message")
uiLogger.info("button was tapped")

// Driver **won't** capture this log:
storageLogger.error("database error message")
```

This approach facilitates managing loggers with varied categories across distinct driver instances as needed.

### Controlling the Polling Interval:

The `PollingInterval` supports four enumerations:

```swift
.short // 10 second intervals
.medium // 30 second intervals
.long // 60 second intervals
.custom(TimeInterval) // Poll at the given duration (in seconds)
```

**Note:** There is a hard-enforced minimum of 1 second for the `custom` interval option.

## Wrapping up:

This approach offered by `OSLogClient` offers a non-intrusive means to leverage `OSLog`, while still offering the flexibility to plug and play external vendors and logging services in a far more decoupled and testable manner.

Adopting `OSLog` is a smart choice to make in my opinion, not just because Apple recommend it, but also because you can utilise the external Console app found on macOS and Xcode 15's upcoming console refresh to tame your logging strategies and leverage some great privacy and formatting niceties out of the box.

OSLogClient is available on GitHub here:

[https://github.com/CheekyGhost-Labs/OSLogClient](https://github.com/CheekyGhost-Labs/OSLogClient)