# Coverage

Code coverage for each scenario: a macOS unit test bundle runs a feature file against a framework, and CucumberSwift writes the coverage of each scenario to a file.

## Overview

| | |
|---|---|
| Platform | macOS |
| Test target | A unit test bundle, `CoverageTests`, with a macOS 14.0 deployment target, built in Swift 6 language mode, and the `Calculator` framework that it covers |
| Xcode | 16.3 or later |
| CucumberSwift | 6.8.0 or later |
| Source | [`Tuist/Coverage`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Tuist/Coverage) |
| README | [Coverage's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Tuist/Coverage/README.md) |

### What it shows

The sample has five parts:

- `Sources/Calculator`, the framework that the scenarios cover. No scenario calls `squareRoot(of:)`, so a report shows it as not covered.
- `Tests/Features/Arithmetic.feature`, a feature file with three scenarios, and `Tests/StepDefinitions.swift`, the steps for it.
- `Project.swift`, whose scheme turns on code coverage for the `Calculator` framework only, and sets `CUCUMBER_COVERAGE`, which turns on CucumberSwift's coverage files, and `CUCUMBER_COVERAGE_PATH`, the folder they go to.
- `report.py`, which reads the files and prints how much of `Sources/Calculator` each scenario covered.
- `annotate.py` and `CoverageAnnotations`, a plugin that shows each scenario's coverage on its line in the feature file, as Xcode warnings and errors: below 80% a warning, and below 50% an error.

Each run writes a folder with a `manifest.json` and one `.profraw` file for each scenario and each binary that was built with code coverage. Each file contains the coverage of one scenario only.

### Run it

From the repository root, with Xcode 16.3 or later and mise. Until CucumberSwift 6.8.0 is released, build the sample against a CucumberSwift checkout that has the feature:

```bash
mise install
mise run generate
open Tuist/Coverage/Coverage.xcodeproj
```

Press ⌘U, then run `python3 Tuist/Coverage/report.py` to read each scenario's coverage. From the command line, `mise run test Coverage` generates the project and runs its tests.

### See the coverage on the feature file

The scheme runs `annotate.py` after the tests, and the next build shows each scenario's coverage on its line in the feature file. A scenario below 80% of the functions it ran has a warning, and the `Feature:` line has the coverage of all the scenarios together and the functions that no scenario ran:

![The Arithmetic feature file in Xcode. The Feature line has a warning, "Feature coverage 65% of Sources/Calculator", and two scenario lines have a warning, "Scenario coverage 75% of the 2 functions it ran". The Issue navigator lists the same three warnings.](Coverage-Annotations)

### Where to go next

The README shows what CucumberSwift writes, how to read it, and how to turn coverage on in your own project. [Measuring code coverage](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/measuring-code-coverage) in CucumberSwift's documentation describes the settings and their limits.
