# GettingStarted

The smallest working CucumberSwift setup: a macOS unit test bundle that runs one feature file.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `GettingStartedTests`, with a macOS 14.0 deployment target, built in Swift 6 language mode |
| Xcode | 16.3 or later |
| CucumberSwift | The latest 6.x release, 6.3.0 or later |
| Source | [`Tuist/GettingStarted`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/GettingStarted) |
| README | [GettingStarted's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/GettingStarted/README.md) |

### What it shows

- `Tests/Features/Calculator.feature`, a feature file with one scenario.
- `Tests/StepDefinitions.swift`, the step definitions for it. CucumberSwift finds them through an extension of `Cucumber` that conforms to `StepImplementation`.
- `Project.swift`, which adds CucumberSwift as a Swift package and copies the `Tests/Features` folder into the test bundle, where CucumberSwift looks for feature files.

Each step is matched with a [Cucumber Expression](https://github.com/cucumber/cucumber-expressions#readme), such as `I have entered {int} into the calculator`, and `match.first(\.int)` reads the number back as an `Int`.

The test target builds in Swift 6 language mode, so the conformance is marked `@retroactive`. In Swift 5 mode, leave `@retroactive` out.

### Run it

From the repository root, with Xcode 16.3 or later and mise:

```bash
mise install
mise run generate
open Tuist/GettingStarted/GettingStarted.xcodeproj
```

Then press ⌘U. From the command line, `mise run test GettingStarted` generates the project and runs its tests.

### Where to go next

The README shows how to write the steps for a new scenario from the step definition CucumberSwift generates, and how to copy the sample into a project of your own. To add CucumberSwift to a project you already have, follow CucumberSwift's step-by-step tutorials with [Swift Package Manager](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/spm-step-by-step/) or [Carthage](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/carthage-step-by-step/). <doc:TestNavigator> is the next sample: how scenarios appear in Xcode's test navigator.
