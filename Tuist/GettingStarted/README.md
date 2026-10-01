# GettingStarted

The smallest working CucumberSwift setup: a macOS unit test bundle that runs one feature
file.

**CucumberSwift version:** the latest 6.x release (6.2.0 or later).

## What it shows

- `Tests/Features/Calculator.feature`, a feature file with one scenario.
- `Tests/StepDefinitions.swift`, the step definitions for it. CucumberSwift finds them
  through an extension of `Cucumber` that conforms to `StepImplementation`.
- `Project.swift`, which adds CucumberSwift as a Swift package and copies the
  `Tests/Features` folder into the test bundle, where CucumberSwift looks for feature
  files.

Each step is matched with a [Cucumber Expression](https://github.com/cucumber/cucumber-expressions#readme),
such as `I have entered {int} into the calculator`, and `match.first(\.int)` reads the
number back as an `Int`.

The test target builds in Swift 6 language mode, so the conformance is marked
`@retroactive`. In Swift 5 mode, leave `@retroactive` out.

## Run it

You need Xcode 16 or later and [mise](https://mise.jdx.dev), which installs the version of
[Tuist](https://tuist.dev) this repository pins. From the repository root:

```bash
mise install
mise run generate
open Tuist/GettingStarted/GettingStarted.xcodeproj
```

Then press ⌘U. Xcode's test navigator shows the scenario and its steps after the first
run, because CucumberSwift creates the tests when the bundle starts.

From the command line, `mise run test GettingStarted` generates the project and runs its
tests.

## Copy it into a project of your own

**Start a new project from it.** Copy this folder and the repository's `.mise.toml`, then
rename the project and target in `Project.swift`. The sample depends on the CucumberSwift
release, so it needs no other change. If you don't use mise, install Tuist another way and
run `tuist generate` in the folder.

**Add CucumberSwift to an existing Xcode project.**

1. Add the package `https://github.com/cucumberswift/CucumberSwift` (File → Add Package
   Dependencies…) and add the `CucumberSwift` library to your unit test target.
2. Create a `Features` folder in the test target, and add it to the target as a folder
   reference (blue folder) so it is copied into the test bundle as a folder.
3. Copy `Tests/StepDefinitions.swift` into the test target and replace the steps with
   your own.

To try the sample with a local CucumberSwift checkout instead of the release, set
`CUCUMBER_SWIFT_PATH` to its absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.

## Learn more

- [CucumberSwift's documentation](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/)
- [TestNavigator](../TestNavigator/README.md), the next sample: how scenarios appear in
  Xcode's test navigator.
