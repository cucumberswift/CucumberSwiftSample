# Contributing

Thank you for helping. This repository holds CucumberSwift's sample projects. Changes to
CucumberSwift itself belong in [cucumberswift/CucumberSwift](https://github.com/cucumberswift/CucumberSwift),
which has its own [contributing guide](https://github.com/cucumberswift/CucumberSwift/blob/main/CONTRIBUTING.md).

Start from an issue: say what you want to change, or which sample you want to add, before
you open a pull request. Name the pull request after the issue, and put `Closes #<issue>`
in its description.

## Working on a sample

```bash
mise install                 # once: installs the pinned Tuist
mise run generate            # after adding, removing or renaming a file, or changing a Project.swift
mise run test [SampleName]   # what CI runs
```

The generated `.xcodeproj` and `.xcworkspace` are not committed: commit `Project.swift`
and the sources, and regenerate.

To test a sample against a CucumberSwift change, set `CUCUMBER_SWIFT_PATH` to the
absolute path of your CucumberSwift checkout when you generate. Tuist only passes
variables that start with `TUIST_` to a manifest, so `.mise.toml` hands it on as
`TUIST_CUCUMBER_SWIFT_PATH`, and that is what each `Project.swift` reads. Running
`tuist` directly, outside mise, set `TUIST_CUCUMBER_SWIFT_PATH` instead.

## Adding a sample

Each sample shows one way of using CucumberSwift, and works on its own when copied out of
this repository.

1. **Create `Tuist/<SampleName>/`**, named in PascalCase after what it shows, such as
   `AsyncSteps` or `Hooks`. A sample that needs only Swift Package Manager, with no Xcode
   project, goes in `SwiftPM/<SampleName>/` instead.
2. **Add `Tuist.swift` and `Project.swift`.** Start from
   [GettingStarted](Tuist/GettingStarted). Keep its `cucumberSwift` package: it depends
   on the latest CucumberSwift release, and switches to `CUCUMBER_SWIFT_PATH` when that is
   set. Name the scheme after the folder, because `mise run test` and CI look for it.
   Prefer a macOS test target, which runs in CI without a simulator, unless the sample is
   about another platform.
3. **Add the feature files and step definitions** under `Tests/`. Match steps with
   Cucumber Expressions and typed parameters (`match.first(\.int)`), not closures that take
   `[String]`, which are deprecated.
4. **Add test plans, if the sample needs more than one**, in `TestPlans/`, and list them in
   the scheme's test action; the first is the default. A test plan names its test target
   by ID: generate the project, then create the plan in Xcode, or copy one from
   [TestNavigator](Tuist/TestNavigator/TestPlans) and put the target's ID from the
   generated `project.pbxproj` in it. `mise run test` runs every test plan in the scheme.
5. **Write its `README.md`**: what it shows, how to run it, how to copy it into a project
   of your own, and which CucumberSwift version it needs. Use
   [GettingStarted's](Tuist/GettingStarted/README.md) as the model.
6. **Add it to the table in the [README](README.md).**
7. **Run `mise run test <SampleName>`.** Every test must pass. A sample that fails on
   purpose, to show a failure, lists the failing scenario in `expected_failures` in
   `scripts/test-sample.sh` and explains it in its README. The script then fails if any
   other test fails, or if that scenario stops failing.

CI finds every folder in `Tuist/` that has a `Project.swift`, so a new sample needs no
workflow change. It is tested on each pull request, and every night against the latest
CucumberSwift release and CucumberSwift's `main`.

## When CucumberSwift changes

A CucumberSwift pull request that adds or changes something users see should add or update
a sample here, or link an issue for one. If the nightly run against `main` fails, a
CucumberSwift change broke a sample: fix the sample, or raise it on the CucumberSwift
change.
