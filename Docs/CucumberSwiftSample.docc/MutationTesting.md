# MutationTesting

Find the scenarios that still pass when the code they test is wrong, and fail the tests in Xcode until they don't.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `MutationTestingTests`, that tests a framework, `Shop`, with a macOS 14.0 deployment target, built in Swift 6 language mode |
| Xcode | 16.3 or later |
| CucumberSwift | 6.9.0 or later |
| Source | [`Tuist/MutationTesting`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/MutationTesting) |
| README | [MutationTesting's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/MutationTesting/README.md) |

### What it shows

The sample tests a shopping basket, `Sources/Shop/Basket.swift`, with three feature files. `Basket.feature`, tagged `@before`, has scenarios that miss 2 mutants. `Basket-killed.feature`, tagged `@after`, adds the 2 scenarios that kill them. `Basket-overlap.feature`, also tagged `@after`, has two scenarios that each check something the other misses, so the redundancy score warns on both until you combine them. Between them, the sample shows each result that mutation testing gives: killed and surviving mutants, an equivalent mutant that a `cucumberswift:mutation-ignore` comment marks as ignored, and code that no scenario runs.

The sample's `Package.swift` describes the same code and tests as its `Project.swift`, because `swift package mutation-test` runs on Swift packages. The Xcode project has two schemes, `MutationTesting` and `MutationTesting-Killed`, one for each tag. Both run the tests with code coverage, and the step definitions turn on `Cucumber.mutationTesting` with the last run's report, so each feature's `Coverage scores` suite has a `Mutation` test. It fails with `MutationTesting` and passes with `MutationTesting-Killed`.

### Run it

In `Tuist/MutationTesting`, run the mutation testing on the scenarios tagged `@before`:

```bash
swift package mutation-test --tags before
```

Then, from the repository root, open the Xcode project and press ⌘U with the `MutationTesting` scheme:

```bash
mise install
mise run generate
open Tuist/MutationTesting/MutationTesting.xcodeproj
```

Run the command again with `--tags after`, and test the `MutationTesting-Killed` scheme, to see the Mutation test pass.

### Where to go next

The README walks through each result, with the code that gives it, and shows how to copy the setup into a project of your own. CucumberSwift's [Mutation testing](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/mutation-testing) article describes the command, its options and its reports.
