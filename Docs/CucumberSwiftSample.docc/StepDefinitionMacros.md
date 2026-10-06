# StepDefinitionMacros

Step definitions written as macros, `#Given`, `#When` and `#Then`, which the compiler checks where you write them: a macOS unit test bundle that runs one feature file in English and one in Spanish.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `StepDefinitionMacrosTests`, with a macOS 14.0 deployment target, built in Swift 6 language mode |
| Xcode | 16.3 or later |
| CucumberSwift | 6.4.0 or later, the first release with the step definition macros |
| Source | [`Tuist/StepDefinitionMacros`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/StepDefinitionMacros) |
| README | [StepDefinitionMacros' README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/StepDefinitionMacros/README.md) |

### What it shows

- `Tests/StepDefinitions.swift`, the step definitions, written with the macros:
  - a Cucumber expression whose closure takes typed arguments, `{int}` as an `Int` and `{string}` as a `String`;
  - a regular expression whose capture group is a `String` argument;
  - a step that takes the `Step`, to read its data table;
  - `#ES_Dado` and `#ES_Entonces`, the macros for steps in Spanish;
  - the mistakes the compiler finds, commented out, one of each, with the fix Xcode offers.
- `Tests/Features/Basket.feature` and `Tests/Features/Cesta.feature`, the feature files they match.
- `Project.swift`, which adds CucumberSwift and its `CucumberSwiftMacros` library.
- `MacrosTrait`, a local Swift package that only turns on CucumberSwift's `Macros` package trait, which the macros are behind. An Xcode project can turn on a package's traits itself only from Xcode 26.4; a package can, in its own manifest, with any Xcode that has Swift 6.1.

The macros are Swift Package Manager only: a Carthage install of CucumberSwift has no macros.

### Run it

From the repository root, with Xcode 16.3 or later and mise:

```bash
mise install
mise run generate
open Tuist/StepDefinitionMacros/StepDefinitionMacros.xcodeproj
```

Then press ⌘U. The first time you build, Xcode asks you to trust the macros from the CucumberSwift package: choose **Trust & Enable**. From the command line, `mise run test StepDefinitionMacros` generates the project and runs its tests.

To build it against a local CucumberSwift checkout, the checkout's folder must be named `CucumberSwift`, so that Xcode uses it in place of the CucumberSwift that `MacrosTrait` asks for.

### Where to go next

The README shows how to turn on the macros in your own project, with `MacrosTrait` or, from Xcode 26.4, with the trait set in the project; the argument type each parameter gives; the mistakes the compiler reports and the fixes it offers; and Expand Macro, which shows the step definition each macro stands for. CucumberSwift's guide to the macros is [Checking step definitions when they compile](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/checking-step-definitions). <doc:GettingStarted> is the same setup with the step definition functions.
