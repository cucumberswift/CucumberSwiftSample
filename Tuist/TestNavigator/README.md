# TestNavigator

How your scenarios read in Xcode's test navigator and test report: test names as you
wrote them, failures at the feature file's line, Scenario Outline examples, skipped
scenarios, and a test plan per tag.

**CucumberSwift version:** the latest 6.x release, 6.3.0 or later. 6.3.0 added these
features ([cucumberswift/CucumberSwift#253](https://github.com/cucumberswift/CucumberSwift/pull/253)).
With 6.2.0 the sample
builds and runs, but its tests are named in camel case, its failure is reported in
`StepDefinitions.swift`, and the skipped scenario fails instead.

[TestNavigator in the documentation](https://cucumberswift.org/CucumberSwiftSample/documentation/cucumberswiftsample/testnavigator/) says what it shows, its platform and test target, and the Xcode and CucumberSwift it needs.

## What it shows

Four feature files in `Tests/Features`, about a shop:

| Feature file | Shows |
|---|---|
| `Checkout.feature` | A failing scenario, a skipped scenario, a Scenario Outline whose examples include a repeated row, and tags |
| `Cart.feature` | A `Background`, a data table and a `Rule` |
| `Account.feature` | A Scenario Outline with two named `Examples` tables, and a doc string |
| `Search.feature` | Plain scenarios, one of them tagged `@Smoke` |

In the test navigator, each scenario is a test class named after its feature and scenario,
such as `Checkout › Pay with a gift card`, and each step is a numbered test in it, such as
`3 › Then the order total is 10`. Each example of a Scenario Outline is named after its
values, such as `Sign in before paying (email: bob@x.com, role: admin)`, and an example
that repeats another gets its number too, as in `(email: amy@x.com, role: customer,
example 3)`. Readable names
are on by default; `Cucumber.readableTestNames = false` in `setupSteps()`, or the
environment variable `CUCUMBER_READABLE_TEST_NAMES=NO`, turns them off.

### The failing scenario

`Checkout › Apply a discount code` fails on purpose, so you can see where Xcode reports a
failing step. Its step definition remembers the discount code but never takes it off the
total, so `Then the order total is 18` fails with `("20") is not equal to ("18")`. Click
the failure, and Xcode opens `Checkout.feature` at that step. The call stack still leads to
the assertion in `StepDefinitions.swift`. The scenario's last step does not run, and shows
as skipped.

So the default and `Checkout` test plans end with one failure. This repository's CI expects
exactly that one, and fails if any other test fails, or if this one stops failing.

### The skipped scenario

`Checkout › Pay at the card terminal` stops at its second step, `the card terminal is
offline`, which throws `XCTSkip`. The steps after it show as skipped, with the reason.

### A test plan per tag

The scheme has three test plans, in `TestPlans/`:

| Test plan | Runs | `CUCUMBER_TAGS` |
|---|---|---|
| `TestNavigator` (default) | Every scenario | not set |
| `Smoke` | Scenarios tagged `@Smoke` | `Smoke` |
| `Checkout` | Scenarios tagged `@Checkout` | `Checkout` |

Choose one in the menu at the top of the test navigator, or pass `-testPlan Smoke` to
`xcodebuild`. A test plan names its test target by the target's ID in the generated
project, so if you rename the project or the target, open each plan in Xcode and add the
target again.

## Run it

You need Xcode 16.3 or later and [mise](https://mise.jdx.dev), which installs the version of
[Tuist](https://tuist.dev) this repository pins. From the repository root:

```bash
mise install
mise run generate
open Tuist/TestNavigator/TestNavigator.xcodeproj
```

Then press ⌘U. The test navigator shows the scenarios after the first run, because
CucumberSwift creates the tests when the bundle starts.

From the command line, `mise run test TestNavigator` generates the project and runs each
test plan, checking that only the failing scenario fails.

## Copy it into a project of your own

Copy this folder and the repository's `.mise.toml`, then rename the project and target in
`Project.swift` and add the target to each test plan again (see above).

To bring one part into an existing project instead, copy the feature file you want, its
steps from `Tests/StepDefinitions.swift`, and for test plans per tag, the test plans and
the `CUCUMBER_TAGS` setting in each. [GettingStarted](../GettingStarted/README.md) shows
how to add CucumberSwift to a test target.

To try the sample with a local CucumberSwift checkout, set `CUCUMBER_SWIFT_PATH` to its
absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.
