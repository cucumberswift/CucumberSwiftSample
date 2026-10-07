# ParallelTesting

Scenarios that run side by side with Xcode's parallel testing, through CucumberSwift's
parallel testing setting. The setting is **experimental**: read
[Before you rely on it](#before-you-rely-on-it) first.

**CucumberSwift version:** 6.4.0 or later.

[ParallelTesting in the documentation](https://cucumberswift.org/CucumberSwiftSample/documentation/cucumberswiftsample/paralleltesting/) says what it shows, its platform and test target, where parallel testing is verified, and the Xcode and CucumberSwift it needs.

## What it shows

- `TestPlans/Parallel.xctestplan`, the default test plan. It turns on **Execute in
  parallel** for the test target, and sets the environment variable
  `CUCUMBER_PARALLEL_TESTING` to `YES`. Xcode then runs the scenarios in several worker
  processes at once.
- `TestPlans/Serial.xctestplan`, the same scenarios with neither, one after another. Run
  both to compare their times and their numbers of tests.
- `Tests/Features`, three features with twelve scenarios between them, including a
  Background, a data table and a Scenario Outline. Each scenario waits about a second for a
  stand-in warehouse, as a UI test or a test of a slow service would.
- `Tests/StepDefinitions.swift`, whose state belongs to one scenario and is reset in
  `BeforeScenario`, so a scenario passes whichever worker runs it, and whatever that worker
  ran before.

On a Mac with 16 cores, the `Parallel` test plan takes about 9 seconds and the `Serial`
test plan about 19, with `xcodebuild test-without-building`. How many workers Xcode starts
depends on the Mac.

## Run it

You need Xcode 16.3 or later and [mise](https://mise.jdx.dev), which installs the version of
[Tuist](https://tuist.dev) this repository pins. From the repository root:

```bash
mise install
mise run generate
open Tuist/ParallelTesting/ParallelTesting.xcodeproj
```

Then press ⌘U to run the `Parallel` test plan. To run the `Serial` one, choose it under
**Product → Test Plan** and press ⌘U again. The test report shows each scenario as a class
with a test for each step. In Xcode's log, and in `xcodebuild`'s output, each scenario says
which worker ran it: `started on 'My Mac - xctest (12345)'`, where the number is the worker's
process.

From the command line, `mise run test ParallelTesting` generates the project and runs both
test plans. It fails unless both run the same number of tests and the `Parallel` test plan
runs them in more than one worker.

## Turn it on in your own project

Both of these, for the test target that runs your feature files:

1. **Xcode's parallel testing.** In the test plan's **Tests** tab, click the target's
   **Options** and check **Execute in parallel**. Without a test plan, it is in the scheme's
   Test action, under **Info → Options**. On the command line,
   `xcodebuild test -parallel-testing-enabled YES` turns it on for the run.
2. **CucumberSwift's setting.** In the test plan's **Configurations** tab, under
   **Arguments**, add the environment variable `CUCUMBER_PARALLEL_TESTING` with the value
   `YES`, as this sample does. Or turn it on in your `setupSteps()`, for every run:

   ```swift
   public func setupSteps() {
       Cucumber.parallelTesting = true
       // Your steps
   }
   ```

   `xcodebuild` passes a variable that starts with `TEST_RUNNER_` on to the tests without the
   prefix, so `TEST_RUNNER_CUCUMBER_PARALLEL_TESTING=YES xcodebuild test …` sets it for one run.

**You need both.** Without CucumberSwift's setting, Xcode can't hand the scenarios to
different workers: depending on the setup it runs them all in one worker, runs them in
every worker, or drops them, and the run can still pass. Without Xcode's parallel testing,
the setting changes nothing.

## Before you rely on it

The setting is experimental. CucumberSwift's documentation,
[Running Tests in Xcode → Parallel testing](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/running-tests-in-xcode#Parallel-testing),
says where it has been tried and what to watch for. In short:

- **Where it has been tried.** Unit tests without a host app, like this sample's, run in
  parallel on macOS, Mac Catalyst and the iOS and tvOS Simulators. Unit tests hosted in an
  app run in parallel only on macOS; elsewhere Xcode runs them in one worker. UI tests run
  in parallel on the iOS and tvOS Simulators. A sample of an iOS app tested with XCUITest,
  where parallel testing pays off most, is planned in
  [#3](https://github.com/cucumberswift/CucumberSwiftSample/issues/3).
- **Each worker is a process of its own.** State your step definitions share between
  scenarios, such as a counter or a cache, is per worker. Keep each scenario's state to
  itself, as this sample does.
- **Feature hooks run per worker.** `BeforeFeature` runs in each worker that runs one of the
  feature's scenarios, and `AfterFeature` can run before the feature's other scenarios have
  finished in other workers. Scenario and step hooks run as they do in a serial run.
- **On macOS, the workers share one JSON report file**, so it holds one worker's results.
- **It needs a test per step**, the default. With one test per scenario
  (`CUCUMBER_ONE_TEST_PER_SCENARIO`), every scenario is a test of one class, which Xcode
  hands to one worker.
- **It pays off for slow scenarios.** Xcode spends a little time handing out each scenario
  and starting workers, so quick scenarios can take longer in parallel than one after
  another.
- **Check the number of tests** against a serial run, as this sample's script does, when you
  turn it on and when you update Xcode.

## Copy it into a project of your own

**Start a new project from it.** Copy this folder and the repository's `.mise.toml`, then
rename the project and target in `Project.swift`. The test plans name the target by its ID:
generate the project, then open each test plan in Xcode and add the renamed target again
(or put its ID from the generated `project.pbxproj` in the `identifier` fields). If you
don't use mise, install Tuist another way and run `tuist generate` in the folder.

**Add it to an existing project.** Turn on the two settings above for the test target that
runs your feature files, and keep a test plan without them, to compare.

To try the sample with a local CucumberSwift checkout instead of the release, set
`CUCUMBER_SWIFT_PATH` to its absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.

## Learn more

- [Running Tests in Xcode → Parallel testing](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/running-tests-in-xcode#Parallel-testing)
- [GettingStarted](../GettingStarted/README.md), the smallest working setup, and
  [TestNavigator](../TestNavigator/README.md), how scenarios appear in Xcode's test navigator
  and how a test plan chooses scenarios by tag.
