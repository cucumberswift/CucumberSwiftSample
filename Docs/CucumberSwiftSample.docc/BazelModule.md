# BazelModule

CucumberSwift in a Bazel project: one test target, one feature file and its step definitions, run on macOS and on an iOS simulator.

## Overview

| | |
|---|---|
| Platform | macOS and iOS |
| Test targets | A `macos_unit_test`, `BazelModuleTests`, with a macOS 14.0 minimum, and an `ios_unit_test`, `BazelModuleTests_iOS`, with an iOS 17.0 minimum, both running one `swift_library` of step definitions built in Swift 6 language mode |
| Xcode | 16.3 or later |
| Bazel | [Bazelisk](https://github.com/bazelbuild/bazelisk), which runs the version in the sample's `.bazelversion` |
| CucumberSwift | 6.4.0 or later |
| Source | [`Bazel/BazelModule`](https://github.com/cucumberswift/CucumberSwiftSample/tree/main/Bazel/BazelModule) |
| README | [BazelModule's README](https://github.com/cucumberswift/CucumberSwiftSample/blob/main/Bazel/BazelModule/README.md) |

### What it shows

- `MODULE.bazel`, which adds CucumberSwift and CucumberSwiftExpressions, which it depends on, with `bazel_dep`. A `git_override` for each fetches its release tag from GitHub. It also adds `rules_apple` and `rules_swift`, which build and run the tests.
- `BUILD.bazel`, with a `swift_library` for the step definitions, a `macos_unit_test` and an `ios_unit_test` that run them, and an `apple_resource_group` that puts the `Tests/Features` folder at the root of the test bundle as `Features`, where CucumberSwift looks for feature files.
- `Tests/Features/Calculator.feature` and `Tests/StepDefinitions.swift`, the same feature file and step definitions as <doc:GettingStarted>.

The `swift_library` is `testonly`, because CucumberSwift links XCTest and only test targets can depend on it.

### Run it

From the sample's folder, with Xcode 16.3 or later and Bazelisk installed as `bazel`:

```bash
cd Bazel/BazelModule
bazel test //...
```

That runs `BazelModuleTests` on macOS and `BazelModuleTests_iOS` on an iOS simulator, which rules_apple creates and boots the first time. From the repository root, `mise run test BazelModule` runs the same tests and checks that each test target ran its scenarios.

### Add CucumberSwift to your own Bazel project

Add both modules to your `MODULE.bazel`, each with a `git_override` to its release tag:

```
bazel_dep(name = "cucumberswift", version = "6.4.0")
git_override(module_name = "cucumberswift", remote = "https://github.com/cucumberswift/CucumberSwift.git", tag = "6.4.0")
bazel_dep(name = "cucumberswift_expressions", version = "1.4.1")
git_override(module_name = "cucumberswift_expressions", remote = "https://github.com/cucumberswift/CucumberSwiftExpressions.git", tag = "1.4.1")
```

Then add `@cucumberswift//:CucumberSwift` to the `deps` of the `testonly` `swift_library` that holds your step definitions, put that library in your `macos_unit_test` or `ios_unit_test`, and put your feature files in a `Features` folder at the root of the test bundle, as the sample's `BUILD.bazel` does. The README walks through each step, and shows how to build the sample against a local CucumberSwift checkout with `--override_module`.
