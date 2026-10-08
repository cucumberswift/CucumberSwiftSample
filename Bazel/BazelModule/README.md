# BazelModule

CucumberSwift in a Bazel project: one test target, one feature file and its step
definitions, run on macOS and on an iOS simulator.

**CucumberSwift version:** 6.4.0 or later, the first release with a `MODULE.bazel`.

[BazelModule in the documentation](https://cucumberswift.org/CucumberSwiftSample/documentation/cucumberswiftsample/bazelmodule/) says what it shows, its platforms and test targets, and the Xcode, Bazel and CucumberSwift it needs.

## What it shows

- `MODULE.bazel`, which adds CucumberSwift and CucumberSwiftExpressions, which it depends
  on, with `bazel_dep`. A `git_override` for each fetches its release tag from GitHub.
  It also adds `rules_apple` and `rules_swift`, which build and run the tests.
- `BUILD.bazel`, with a `swift_library` for the step definitions, a `macos_unit_test`
  (`BazelModuleTests`) and an `ios_unit_test` (`BazelModuleTests_iOS`) that run them, and
  an `apple_resource_group` that puts the `Tests/Features` folder at the root of the test
  bundle as `Features`, where CucumberSwift looks for feature files.
- `Tests/Features/Calculator.feature`, a feature file with one scenario.
- `Tests/StepDefinitions.swift`, the step definitions for it. CucumberSwift finds them
  through an extension of `Cucumber` that conforms to `StepImplementation`.

Each step is matched with a [Cucumber Expression](https://github.com/cucumber/cucumber-expressions#readme),
such as `I have entered {int} into the calculator`, and `match.first(\.int)` reads the
number back as an `Int`. The step definitions build in Swift 6 language mode
(`-swift-version 6`), so the conformance is marked `@retroactive`. In Swift 5 mode, leave
`@retroactive` out.

The `swift_library` is `testonly`, because CucumberSwift links XCTest and only test
targets can depend on it.

## Run it

You need Xcode 16.3 or later and [Bazelisk](https://github.com/bazelbuild/bazelisk),
installed as `bazel`, which runs the Bazel version in `.bazelversion`. From this folder:

```bash
bazel test //...
```

That builds the step definitions and runs `BazelModuleTests` on macOS and
`BazelModuleTests_iOS` on an iOS simulator, which rules_apple creates and boots the first
time. Run one with `bazel test //:BazelModuleTests`. Each test's log, with XCTest's
output, is in `bazel-testlogs/<target>/test.log`.

rules_apple looks for the iOS simulator runtime that matches your Xcode's SDK. If it
reports "no matching runtimes found", name an installed runtime from
`xcrun simctl list runtimes`: `bazel test //... --ios_simulator_version=26.3.1`.

From the repository root, `mise run test BazelModule` runs the same tests and checks that
each test target ran its scenarios.

## Copy it into a project of your own

**Start a new project from it.** Copy this folder, and rename the module in `MODULE.bazel`
and the targets in `BUILD.bazel`.

**Add CucumberSwift to a Bazel project you already have.**

1. Add both modules to your `MODULE.bazel`, each with a `git_override` to its release tag:

   ```starlark
   bazel_dep(name = "cucumberswift", version = "6.4.0")
   git_override(module_name = "cucumberswift", remote = "https://github.com/cucumberswift/CucumberSwift.git", tag = "6.4.0")
   bazel_dep(name = "cucumberswift_expressions", version = "1.4.1")
   git_override(module_name = "cucumberswift_expressions", remote = "https://github.com/cucumberswift/CucumberSwiftExpressions.git", tag = "1.4.1")
   ```

   You also need `rules_apple` and `rules_swift`, as in this sample's `MODULE.bazel`.
2. Add `"@cucumberswift//:CucumberSwift"` to the `deps` of the `testonly` `swift_library`
   that holds your step definitions, and put that library in the `deps` of your
   `macos_unit_test` or `ios_unit_test`.
3. Put your feature files at the root of the test bundle in a `Features` folder, with an
   `apple_resource_group` like this sample's, in the library's `data`.
4. Copy `Tests/StepDefinitions.swift` into your test sources and replace the steps with
   your own.

To try the sample with a local CucumberSwift checkout instead of the release, override the
module with its absolute path: `bazel test //... --override_module=cucumberswift=$HOME/src/CucumberSwift`.
From the repository root, `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run test BazelModule`
does the same.

## Learn more

- [CucumberSwift's documentation](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/)
- [GettingStarted](../../Tuist/GettingStarted/README.md), the same feature file and step
  definitions in an Xcode project, and how to write the steps for a new scenario from the
  step definition CucumberSwift generates.
- [rules_apple's testing rules](https://github.com/bazelbuild/rules_apple/blob/main/doc/rules-ios.md#ios_unit_test)
