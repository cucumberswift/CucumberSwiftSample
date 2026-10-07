# ParallelTesting

Scenarios that run side by side with Xcode's parallel testing, through CucumberSwift's experimental parallel testing setting.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `ParallelTestingTests`, without a host app, with a macOS 14.0 deployment target, built in Swift 6 language mode |
| Xcode | 16.3 or later to build and run it. Parallel testing is verified on Xcode 26, as the next section says |
| CucumberSwift | 6.4.0 or later, the first release with parallel testing |
| Source | [`Tuist/ParallelTesting`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/ParallelTesting) |
| README | [ParallelTesting's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/ParallelTesting/README.md) |

Parallel testing is experimental, so read [Before you rely on it](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/ParallelTesting/README.md#before-you-rely-on-it) in the README, and CucumberSwift's documentation of it, before you turn it on in a project of your own.

### Where it is verified

CucumberSwift's own CI runs every combination of platform and kind of test target with Xcode 26, and the iOS and Mac Catalyst ones also with Xcode 16.0. This sample is a macOS unit test target without a host app, and that combination is verified on Xcode 26: it passed in CucumberSwift's nightly runs on 2026-10-05 and 2026-10-06. CucumberSwift's CI doesn't run macOS with Xcode 16, so this sample doesn't claim it, although it builds with Xcode 16.3. This sample's own CI runs on the macOS runner's default Xcode. Check the [CucumberSwift documentation](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/running-tests-in-xcode) for what has been tried on other platforms and with UI tests or a host app.

### What it shows

- `TestPlans/Parallel.xctestplan`, the default test plan. It turns on **Execute in parallel** for the test target and sets the environment variable `CUCUMBER_PARALLEL_TESTING` to `YES`, so that Xcode runs the scenarios in several worker processes at once.
- `TestPlans/Serial.xctestplan`, the same scenarios with neither, one after another, to compare their times and their numbers of tests.
- `Tests/Features`, three features with twelve scenarios, including a Background, a data table and a Scenario Outline. Each scenario waits about a second for a stand-in warehouse, as a UI test or a test of a slow service would.
- `Tests/StepDefinitions.swift`, whose state belongs to one scenario and is reset in `BeforeScenario`. A worker is a process of its own, so nothing is shared between scenarios.

You need both settings: Xcode's parallel testing, and CucumberSwift's. Without CucumberSwift's, Xcode can't hand the scenarios to different workers.

### Run it

From the repository root, with Xcode 16.3 or later and mise:

```bash
mise install
mise run generate
open Tuist/ParallelTesting/ParallelTesting.xcodeproj
```

Then press ⌘U to run the `Parallel` test plan, or choose the `Serial` one under **Product → Test Plan**. From the command line, `mise run test ParallelTesting` generates the project and runs both test plans. It fails unless both run the same number of tests and the `Parallel` test plan runs them in more than one worker.

### Where to go next

The README shows how to turn parallel testing on in your own project, and lists what to check before you rely on it. <doc:GettingStarted> is the smallest working setup, and <doc:TestNavigator> shows how a test plan chooses scenarios by tag.
