# TestNavigator

How your scenarios read in Xcode's test navigator and test report: test names as you wrote them, failures at the feature file's line, Scenario Outline examples, skipped scenarios, and a test plan per tag.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `TestNavigatorTests`, with a macOS 14.0 deployment target, built in Swift 6 language mode, and three test plans |
| Xcode | 16 or later |
| CucumberSwift | The latest 6.x release, 6.3.0 or later |
| Source | [`Tuist/TestNavigator`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/TestNavigator) |
| README | [TestNavigator's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/TestNavigator/README.md) |

6.3.0 added these features ([cucumberswift/CucumberSwift#253](https://github.com/cucumberswift/CucumberSwift/pull/253)). With 6.2.0 the sample builds and runs, but its tests are named in camel case, its failure is reported in `StepDefinitions.swift`, and the skipped scenario fails instead.

### What it shows

Four feature files in `Tests/Features`, about a shop:

| Feature file | Shows |
|---|---|
| `Checkout.feature` | A failing scenario, a skipped scenario, a Scenario Outline whose examples include a repeated row, and tags |
| `Cart.feature` | A `Background`, a data table and a `Rule` |
| `Account.feature` | A Scenario Outline with two named `Examples` tables, and a doc string |
| `Search.feature` | Plain scenarios, one of them tagged `@Smoke` |

In the test navigator, each scenario is a test class named after its feature and scenario, such as `Checkout › Pay with a gift card`, and each step is a numbered test in it, such as `3 › Then the order total is 10`. Each example of a Scenario Outline is named after its values, and an example that repeats another gets its number too. Readable names are on by default; `Cucumber.readableTestNames = false` in `setupSteps()`, or the environment variable `CUCUMBER_READABLE_TEST_NAMES=NO`, turns them off.

### The failing scenario

`Checkout › Apply a discount code` fails on purpose, so you can see where Xcode reports a failing step. Click the failure, and Xcode opens `Checkout.feature` at that step. So the default and `Checkout` test plans end with one failure. The repository's CI expects exactly that one, and fails if any other test fails, or if this one stops failing.

### The skipped scenario

`Checkout › Pay at the card terminal` stops at its second step, `the card terminal is offline`, which throws `XCTSkip`. The steps after it show as skipped, with the reason.

### A test plan per tag

The scheme has three test plans, in `TestPlans/`:

| Test plan | Runs | `CUCUMBER_TAGS` |
|---|---|---|
| `TestNavigator` (default) | Every scenario | not set |
| `Smoke` | Scenarios tagged `@Smoke` | `Smoke` |
| `Checkout` | Scenarios tagged `@Checkout` | `Checkout` |

Choose one in the menu at the top of the test navigator, or pass `-testPlan Smoke` to `xcodebuild`.

### Run it

From the repository root, with Xcode 16 or later and mise:

```bash
mise install
mise run generate
open Tuist/TestNavigator/TestNavigator.xcodeproj
```

Then press ⌘U. From the command line, `mise run test TestNavigator` generates the project and runs each test plan, checking that only the failing scenario fails. See <doc:GettingStarted> for how to add CucumberSwift to a test target.
