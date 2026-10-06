# GettingStarted

The smallest working CucumberSwift setup: a macOS unit test bundle that runs one feature
file.

**CucumberSwift version:** the latest 6.x release (6.3.0 or later).

[GettingStarted in the documentation](https://cucumberswift.org/CucumberSwiftSample/documentation/cucumberswiftsample/gettingstarted/) says what it shows, its platform and test target, and the Xcode and CucumberSwift it needs.

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

You need Xcode 16.3 or later and [mise](https://mise.jdx.dev), which installs the version of
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

## Write the steps for a new scenario

You don't have to write a step definition from scratch. Add a step to the feature file
that nothing matches yet, such as `And the display shows "5"`, and run the tests.
CucumberSwift reports the step at its line in the feature file, and the failure message
contains a step definition for it:

```swift
Then(#/^the display shows \"(.*?)\"$/#) { matches, _ in
    let string = matches.1
    XCTFail("Step not implemented: replace this line with your test code")
}
```

Copy it from the failure in the issue navigator or the test report into `setupSteps()`,
and replace the `XCTFail` line with your test code. CucumberSwift also attaches every
generated step definition to the test `GenerateStepsStubsIfNecessary`: right-click it in
the test navigator, choose **Jump to Report**, and open the file under **Pending Steps**.

The generated definition matches with a regular expression. You can keep it, or rewrite it
as a Cucumber Expression like the other steps in this sample:

```swift
Then("the display shows {string}") { match, _ in
    let string = try match.first(\.string)
}
```

## Copy it into a project of your own

**Start a new project from it.** Copy this folder and the repository's `.mise.toml`, then
rename the project and target in `Project.swift`. The sample depends on the CucumberSwift
release, so it needs no other change. If you don't use mise, install Tuist another way and
run `tuist generate` in the folder.

**Add CucumberSwift to an existing Xcode project.** CucumberSwift's step-by-step
tutorials walk through this with screenshots, [with Swift Package Manager](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/spm-step-by-step/)
or [with Carthage](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/carthage-step-by-step/). In short:

1. Add the package `https://github.com/cucumberswift/CucumberSwift` (File → Add Package
   Dependencies…) and add the `CucumberSwift` library to your unit test target.
2. Create a `Features` folder in the test target, and add it to the target as a folder
   reference (blue folder) so it is copied into the test bundle as a folder.
3. Copy `Tests/StepDefinitions.swift` into the test target and replace the steps with
   your own.

To try the sample with a local CucumberSwift checkout instead of the release, set
`CUCUMBER_SWIFT_PATH` to its absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.

## Learn more

- [CucumberSwift's documentation](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/),
  including the step-by-step tutorials for [Swift Package Manager](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/spm-step-by-step/) and
  [Carthage](https://cucumberswift.org/CucumberSwift/tutorials/cucumberswift/carthage-step-by-step/)
- [TestNavigator](../TestNavigator/README.md), the next sample: how scenarios appear in
  Xcode's test navigator.
