# Coverage

Code coverage scores for each feature: a macOS unit test bundle runs four feature files against a framework, and CucumberSwift scores how much of the framework's code each feature's scenarios test, and how much of it they test more than once. Each feature file is a demo of one issue that the scores raise.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `CoverageTests`, with a macOS 14.0 deployment target, built in Swift 6 language mode, and the `Calculator` framework that it tests |
| Xcode | 16.3 or later, and 26 to see the warnings in the feature files |
| CucumberSwift | 6.8.0 or later |
| Source | [`Tuist/Coverage`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/Coverage) |
| README | [Coverage's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/Coverage/README.md) |

### What it shows

The sample has a framework, `Sources/Calculator`, and a feature file for each issue that the scores raise:

| Feature file | Issue on the `Feature:` line |
|---|---|
| `Dividing.feature` | A coverage warning, at or below 80% |
| `Classifying.feature` | A coverage error, at or below 50% |
| `Subtracting.feature` | A redundancy warning, at or above 30% |
| `Adding.feature` | A redundancy error, at or above 40% |

CucumberSwift records each feature's issues in tests of its own, which run after the feature's scenarios: `Coverage`, `Redundancy` and `Redundant scenarios`, in a suite named after the feature, such as `Adding › Coverage scores`. The errors fail Classifying's `Coverage` test and Adding's `Redundancy` test on purpose, and every scenario passes. Xcode shows the warnings in purple and the errors in red, as it shows every issue that a test records.

`Project.swift` turns on code coverage for the `Calculator` framework only. Its scheme sets `CUCUMBER_COVERAGE` and `CUCUMBER_REDUNDANCY` to turn on the scores, `CUCUMBER_REDUNDANCY_ERROR_LEVEL` to turn on the redundancy's error at 40%, and `CUCUMBER_COVERAGE_PATH` to the folder for each scenario's coverage file.

### Run it

Run it from the repository root, with Xcode 16.3 or later and mise. Until CucumberSwift 6.8.0 is released, build the sample against a CucumberSwift checkout that has the feature:

```bash
mise install
mise run generate
open Tuist/Coverage/Coverage.xcodeproj
```

Press ⌘U, then open each feature file in `Tests/Features`. Classifying's and Adding's `Coverage scores` tests fail on purpose with the errors. From the command line, `mise run test Coverage` generates the project and runs its tests.

### A coverage warning

`Dividing.feature` shows a coverage warning. Coverage 67%: no scenario divides by zero, so the scenario runs 4 of the 6 regions in the functions it enters. That is at or below the warning level of 80%.

![The Dividing feature file in Xcode after the tests ran, with the warning "Feature coverage 67%" on its Feature line, which the Issue navigator lists under the Coverage test.](Coverage-Warning)

### A coverage error

`Classifying.feature` shows a coverage error. Coverage 44%: the scenario runs one of the six cases of `classify(_:)`. That is at or below the error level of 50%, so the feature fails on purpose.

![The Classifying feature file in Xcode after the tests ran, with the error "Feature coverage 44%" on its Feature line, which the Issue navigator lists under the Coverage test.](Coverage-Error)

### A redundancy warning

`Subtracting.feature` shows a redundancy warning. Redundancy 33%: the last scenario subtracts a larger number, as the first does. That is at or above the warning level of 30%, and the two scenarios have a warning that they add no coverage of their own.

![The Subtracting feature file in Xcode after the tests ran, with the warning "Feature redundancy 33%" on its Feature line and a warning on the first and last scenarios, which the Issue navigator lists under the Redundancy and Redundant scenarios tests.](Redundancy-Warning)

### A redundancy error

`Adding.feature` shows a redundancy error. Redundancy 50%: three scenarios add positive numbers. That is at or above the error level of 40% that the scheme sets, so the feature fails on purpose, and the three scenarios have a warning that they add no coverage of their own.

![The Adding feature file in Xcode after the tests ran, with the error "Feature redundancy 50%" on its Feature line and a warning on the three scenarios that add positive numbers, which the Issue navigator lists under the Redundancy and Redundant scenarios tests.](Redundancy-Error)

### Where to go next

The README shows the scores that CucumberSwift prints and the files it writes. [Measuring code coverage](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/measuring-code-coverage) in CucumberSwift's documentation describes the scores, the levels you can set and the limits.
