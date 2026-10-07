# CucumberSwiftSample

Working projects for CucumberSwift 6.x, each a starting point for one way of using it.

@Metadata {
    @TechnologyRoot
}

## Overview

[CucumberSwiftSample](https://github.com/cucumberswift/CucumberSwiftSample) holds working sample projects for [CucumberSwift](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/), the Gherkin/BDD test framework for Swift. Each sample shows one way of using CucumberSwift, and works on its own when you copy it out of the repository.

The samples are built and tested on every change and every night, against the latest CucumberSwift release and against CucumberSwift's `main`, so they keep working as CucumberSwift changes. Each samples release carries the version of the CucumberSwift release it was tested with, such as 6.3.0, shown above the title. This page shows the latest samples release, and the latest samples release of each CucumberSwift major stays online at `/CucumberSwiftSample/N.x/`, such as `/CucumberSwiftSample/6.x/`. The earlier samples, step-by-step CocoaPods, Carthage and Swift Package Manager setups for CucumberSwift 3.x, are kept at the [`legacy-3.x`](https://github.com/cucumberswift/CucumberSwiftSample/tree/legacy-3.x) tag. They are no longer maintained or tested.

### How the samples are built

[Tuist](https://tuist.dev) generates each sample's Xcode project from its `Project.swift`, so the repository holds the manifest and the sources, not an `.xcodeproj`. [mise](https://mise.jdx.dev) installs the Tuist version that `.mise.toml` pins.

### Run a sample

You need the Xcode that the sample's article names, and mise. Clone the repository, generate the projects, and open one:

```bash
git clone https://github.com/cucumberswift/CucumberSwiftSample.git
cd CucumberSwiftSample
mise install
mise run generate
open Tuist/GettingStarted/GettingStarted.xcodeproj
```

Press ⌘U to run its tests. Xcode's test navigator shows the scenarios after the first run, because CucumberSwift creates the tests when the test bundle starts.

From the command line, `mise run test` builds and tests every sample, and `mise run test GettingStarted` tests one. Use the folder name of the sample, as in `mise run test [Name]`.

To get the samples as they were tested with one CucumberSwift release, check out the samples release with the same version, such as `git checkout 6.3.0`, before you generate the projects. `main` can already hold samples for the next CucumberSwift release.

### Use a local CucumberSwift checkout

The samples depend on CucumberSwift from GitHub. To build them against a checkout of your own, for example while you work on CucumberSwift, set `CUCUMBER_SWIFT_PATH` to its absolute path when you generate the projects:

```bash
CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
```

### The samples

| Sample | Shows | Platform and test target | Xcode | CucumberSwift |
|---|---|---|---|---|
| <doc:GettingStarted> | The smallest working setup: one test target, one feature file, its step definitions | macOS unit test bundle | 16.3 or later | 6.3.0 or later |
| <doc:TestNavigator> | How scenarios read in Xcode's test navigator: readable test names, failures at the feature file's line, Scenario Outline examples, skipped scenarios, a test plan per tag | macOS unit test bundle | 16.3 or later | 6.3.0 or later |
| <doc:StepDefinitionMacros> | Step definitions written as macros, `#Given`, `#When` and `#Then`, checked when they compile: typed closure arguments, the `Step` argument, a localized macro, and the compiler's errors and fixes | macOS unit test bundle | 16.3 or later | 6.4.0 or later |
| <doc:ParallelTesting> | Scenarios run side by side with Xcode's parallel testing, through CucumberSwift's experimental parallel testing setting, with a serial test plan to compare | macOS unit test bundle | 16.3 or later | 6.4.0 or later |

### Add CucumberSwift to your own project

CucumberSwift's step-by-step tutorials set up a test target from scratch, with [Swift Package Manager](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/spm-step-by-step/) or [Carthage](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/carthage-step-by-step/). <doc:GettingStarted> is a working, tested setup to compare yours with.

## Topics

### The samples

- <doc:GettingStarted>
- <doc:TestNavigator>
- <doc:StepDefinitionMacros>
- <doc:ParallelTesting>
