# MutationTesting

Find the scenarios that still pass when the code they test is wrong, with CucumberSwift's mutation testing, and fail
the tests in Xcode until they don't.

**CucumberSwift version:** 6.9.0 or later, the first with mutation testing. Until 6.9.0 is released, the sample builds
only against a CucumberSwift checkout (see [Use a local CucumberSwift checkout](#use-a-local-cucumberswift-checkout)).

## What it shows

The sample tests a shopping basket, `Sources/Shop/Basket.swift`, with three feature files:

- `Tests/Features/Basket.feature`, tagged `@before`, whose scenarios miss 2 mutants.
- `Tests/Features/Basket-killed.feature`, tagged `@after`, which adds the 2 scenarios that kill them.
- `Tests/Features/Basket-overlap.feature`, tagged `@after`, with two scenarios that each check something the other misses.

Between them, the sample shows each result that mutation testing gives: killed and surviving mutants, an equivalent mutant
that a comment marks as ignored, and code that no scenario runs. It also shows how mutation testing changes which
scenarios the redundancy score marks. `Package.swift` describes the same code and tests as a
Swift package, because mutation testing runs on Swift packages. `Project.swift` generates the Xcode project,
with one scheme for each version of the feature.

## Run mutation testing on the scenarios with gaps

In this folder, with Swift 6.1 or later, run the scenarios tagged `@before`:

```bash
swift run cucumberswift-mutation-test --tags before
```

The command works on a throwaway copy of the package in a temporary folder, changes `Basket.swift` there in 17 small ways,
one at a time, and runs the scenarios against each change. It never changes the files here. It ends with:

```
Mutation score: 85.7% (12 of 14 mutants detected)
Killed 12, timed out 0, survived 2, did not build 0, ignored 2, in code no scenario runs 1

Mutants that no test noticed:
  Sources/Shop/Basket.swift:4:39 BooleanLiteral false → true
    Scenarios that run this code: Two items pay shipping (line 5), Three items get a discount (line 9), Checking out saves the basket (line 13)
  Sources/Shop/Basket.swift:22:27 RelationalOperator > → >=
    Scenarios that run this code: Two items pay shipping (line 5), Three items get a discount (line 9)
```

### The 2 surviving mutants

The basket's shipping rule is the second one. No scenario has a total of exactly 100, so changing `>` to `>=` changes
nothing that a scenario checks:

```swift
public var total: Int {
    let sum = prices.reduce(0, +)
    // Takes 10% off when the basket has 3 or more items. Integer division rounds the result down.
    let discounted = prices.count >= 3 ? sum * 9 / 10 : sum
    return discounted > 100 ? discounted : discounted + 5
}
```

The first is the basket's `isSaved` flag. The scenarios check that checking out saves a basket with items, but none
checks that an empty basket isn't saved, so a basket that starts out saved passes them all:

```swift
public private(set) var isSaved = false
```

### Kill them

`Basket-killed.feature` has the same 3 scenarios and adds one scenario for each survivor:

```gherkin
  Scenario: A total of exactly 100 pays shipping
    Given a basket with items costing 50 and 50
    Then the total is 105

  Scenario: An empty basket isn't saved
    Given an empty basket
    When I check out
    Then the basket isn't saved
```

Run its scenarios, tagged `@after`:

```bash
swift run cucumberswift-mutation-test --tags after
```

Every mutant is now killed:

```
Mutation score: 100.0% (14 of 14 mutants detected)
Killed 14, timed out 0, survived 0, did not build 0, ignored 2, in code no scenario runs 1
```

### An equivalent mutant, ignored by a comment

Some mutants change the code without changing what it does, and no scenario can kill them. Removing the call to
`reserveCapacity` only changes how fast the basket grows, so the command would report it as a survivor forever. A
`cucumberswift:mutation-ignore` comment marks the next line, and the text after it gives the reason:

```swift
public func add(contentsOf more: [Int]) {
    // cucumberswift:mutation-ignore - reserving capacity changes speed, not results
    prices.reserveCapacity(prices.count + more.count)
    prices.append(contentsOf: more)
}
```

The command neither tests nor counts the 2 mutants on that line, and the report lists them as ignored, with the reason.
A comment at the end of a line marks that line instead.

### Code that no scenario runs

No scenario prints a receipt, so no scenario can notice a change to `receipt()`. The command doesn't test its mutant,
and reports it as in code that no scenario runs. That is a coverage gap, not a scenario that misses a change, so it
doesn't count in the mutation score. The coverage summary shows it only in its share of all measured code:

```swift
public func receipt() -> String {
    prices.isEmpty ? "Nothing to pay" : "Total: \(total)"
}
```

## Fail the tests in Xcode

You need Xcode 16.3 or later and [mise](https://mise.jdx.dev). From the repository root:

```bash
mise install
mise run generate
open Tuist/MutationTesting/MutationTesting.xcodeproj
```

The project has two schemes. Both run the tests with code coverage, which mutation testing needs:

| Scheme | Runs | After `swift run cucumberswift-mutation-test` with | The Mutation test |
|---|---|---|---|
| `MutationTesting` | `Basket.feature` (`CUCUMBER_TAGS=before`) | `--tags before` | Fails |
| `MutationTesting-Killed` | `Basket-killed.feature` and `Basket-overlap.feature` (`CUCUMBER_TAGS=after`) | `--tags after` | Passes |

`StepDefinitions.swift` turns on `Cucumber.mutationTesting` and sets `Cucumber.mutationReport` to the report of the last
`swift run cucumberswift-mutation-test` run. Each feature's `Coverage scores` suite then has a `Mutation` test. With the
`MutationTesting` scheme, it fails with an error on the `Feature:` line and on each scenario that runs a surviving mutant's
code:

```
Basket.feature:1   Mutation testing: the scenarios still pass after 2 of the 14 changes to the code they run, …
Basket.feature:5   This scenario still passes when false at Basket.swift:4 is changed to true. Add a step that checks this code.
Basket.feature:9   This scenario still passes when false at Basket.swift:4 is changed to true. Add a step that checks this code.
Basket.feature:13  This scenario still passes when false at Basket.swift:4 is changed to true. Add a step that checks this code.
Basket.feature:5   This scenario still passes when > at Basket.swift:22 is changed to >=. Add a step that checks this code.
Basket.feature:9   This scenario still passes when > at Basket.swift:22 is changed to >=. Add a step that checks this code.
```

Run `swift run cucumberswift-mutation-test` with the same tags as the scheme, because the Mutation test reads the last
run's report. It fails with an error that the report is from a run of other scenarios when the tags differ. It also
fails with an error that the report is out of date after you change `Basket.swift`, until you run the command again.
Without a report, mutation testing stays off and the suite has no `Mutation` test, as in a fresh checkout.

From the command line, `mise run test MutationTesting` generates the project and runs the `MutationTesting` scheme.

## Find the scenarios to remove or combine

With mutation testing on, the `Redundancy` test compares the scenarios by the mutants they fail on as well as by the code
they run. The `MutationTesting-Killed` scheme shows two results.

In `Basket-killed.feature`, "Two items pay shipping" and "A total of exactly 100 pays shipping" run the same code, but
only the second fails when `>` becomes `>=`. The first is redundant:

```
Basket-killed.feature:5  Scenario adds nothing of its own: other scenarios run all the code it runs after the Background, and fail on every mutant it fails on. It took 0.01 s. Consider a Scenario Outline for other values, or remove it.
```

By code alone, without mutation testing, the second would be the redundant one, though it is the stronger scenario.

In `Basket-overlap.feature`, each scenario has something the other lacks:

```gherkin
  Scenario: Checking out a basket of 100
    Given a basket with items costing 50 and 50
    When I check out
    Then the basket is saved
    And the total is at least 100

  Scenario: A basket of 100 pays shipping
    Given a basket with items costing 50 and 50
    Then the total is 105
```

The first runs the checkout code, and only the second fails when the shipping rule changes. Neither is redundant, so
both get a warning, and each warning names what the other one adds:

```
Basket-overlap.feature:5   Scenario overlaps the scenario at line 11. This scenario runs 2 regions that one doesn't. Only this one fails when ! at Basket.swift:26 is removed or true at Basket.swift:27 is changed to false. Only that one fails when > at Basket.swift:22 is changed to <=, > at Basket.swift:22 is changed to >= or discounted > 100 ? discounted : discounted + 5 at Basket.swift:22 is changed to discounted > 100 ? discounted + 5 : discounted. Combine the best of both into one scenario, or into a Scenario Outline for different values.
```

Checking that the total is 105 in the first scenario does the work of both. The redundancy warns and never fails a test
here, so the scheme still passes.

## Use a local CucumberSwift checkout

Set `CUCUMBER_SWIFT_PATH` to the absolute path of a CucumberSwift checkout, for both the Xcode project and the package:

```bash
CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
CUCUMBER_SWIFT_PATH=~/src/CucumberSwift swift run cucumberswift-mutation-test --tags before
```

## Copy it into your project

Copy the CucumberSwift and swift-syntax lines of `Package.swift` into your package, with the `Macros` trait, and run
`swift run cucumberswift-mutation-test` in its folder. To fail your tests on a surviving mutant, turn on
`Cucumber.mutationTesting`, set `Cucumber.mutationReport` to the report's path, as `StepDefinitions.swift` does, and run
your tests with code coverage on.
