# StepDefinitionMacros

Step definitions written as macros, `#Given`, `#When` and `#Then`, which the compiler checks
where you write them: a macOS unit test bundle that runs two feature files, one in English and
one in Spanish.

**CucumberSwift version:** 6.4.0 or later, the first release with the step definition macros.

[StepDefinitionMacros in the documentation](https://cucumberswift.org/CucumberSwiftSample/documentation/cucumberswiftsample/stepdefinitionmacros/) says what it shows, its platform and test target, and the Xcode and CucumberSwift it needs.

## Requirements

- **Xcode 16.3 (Swift 6.1) or later, on macOS 15.2 or later.** Swift 6.1 is the first with
  package traits, which the macros are behind.
- **The tests run wherever CucumberSwift runs:** macOS 10.15, iOS 13 and tvOS 13 or later.
  Each macro becomes an ordinary step definition when the code compiles, so it adds no
  runtime requirement.
- **Swift Package Manager only.** Carthage builds CucumberSwift from its Xcode project, which
  cannot deliver macros. A Carthage install keeps the step definition functions, such as
  `Given`.

An Xcode project can turn on a package's traits itself only from Xcode 26.4. This sample works
with earlier versions too, because a small local package, `MacrosTrait`, turns the trait on
instead (see [below](#turn-on-the-macros-in-your-own-project)).

## What it shows

- `Tests/StepDefinitions.swift`, the step definitions, written with the macros:
  - a Cucumber expression whose closure takes typed arguments, `{int}` as an `Int` and
    `{string}` as a `String`;
  - a regular expression whose capture group is a `String` argument;
  - a step that takes the `Step`, to read its data table;
  - `#ES_Dado` and `#ES_Entonces`, the macros for steps in Spanish;
  - the mistakes the compiler finds, commented out, one of each.
- `Tests/Features/Basket.feature` and `Tests/Features/Cesta.feature`, the feature files they
  match.
- `Project.swift`, which adds CucumberSwift and the `CucumberSwiftMacros` library.
- `MacrosTrait/`, a local Swift package that only turns on CucumberSwift's `Macros` trait.

## Run it

You need Xcode 16.3 or later and [mise](https://mise.jdx.dev), which installs the version of
[Tuist](https://tuist.dev) this repository pins. From the repository root:

```bash
mise install
mise run generate
open Tuist/StepDefinitionMacros/StepDefinitionMacros.xcodeproj
```

Then press ⌘U. The first time you build, Xcode asks you to trust the macros from the
CucumberSwift package: choose **Trust & Enable**. Xcode's test navigator shows the scenarios
and their steps after the first run.

From the command line, `mise run test StepDefinitionMacros` generates the project and runs its
tests. `xcodebuild` cannot ask, so the script passes `-skipMacroValidation`; do the same in
your own CI.

If the trait is not on, the macros do not exist, and each one is an error:

```
'Given' is unavailable: Turn on CucumberSwift's Macros package trait to use the step definition macros. In an Xcode project, that needs Xcode 26.4 or later.
```

## Check the feature files as you build

`Project.swift` adds CucumberSwift's `CucumberSwiftLint` plugin to the test target, so each
build checks the feature files and shows each problem as a warning at its line. Keep it on in
CI too, with `-skipPackagePluginValidation`: see
[GettingStarted](../GettingStarted/README.md#check-the-feature-files-as-you-build).

## Turn on the macros in your own project

The macros are the `CucumberSwiftMacros` library, which CucumberSwift only builds when its
`Macros` package trait is on. Turn the trait on, add the library to your test target, then
`import CucumberSwiftMacros` where you write step definitions. It imports CucumberSwift as
well.

### With any Xcode from 16.3: a local package

A Swift package can turn on its dependencies' traits in its own `Package.swift`, with any Xcode
that has Swift 6.1, and SwiftPM then builds CucumberSwift with the trait for the whole project.
This sample's `MacrosTrait` package does only that:

```swift
// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "MacrosTrait",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MacrosTrait", targets: ["MacrosTrait"])
    ],
    dependencies: [
        .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0", traits: ["Macros"])
    ],
    targets: [
        // Depends on a CucumberSwift product, so that SwiftPM counts the dependency, and its
        // trait, as used.
        .target(
            name: "MacrosTrait",
            dependencies: [.product(name: "CucumberSwiftMacros", package: "CucumberSwift")])
    ]
)
```

Its target needs one source file, which can be empty: `Sources/MacrosTrait/MacrosTrait.swift`.
Set `platforms` to your own deployment targets.

1. Copy the `MacrosTrait` folder next to your project.
2. Add it to the project as a local package, without linking its product to any target. In
   Tuist, add `.package(path: "MacrosTrait")` to `Project.packages`, as this sample does. In
   Xcode, choose File → Add Package Dependencies… → **Add Local…**, select the folder, and add
   its product to no target.
3. Add CucumberSwift to the project as usual, without the trait: `.package(url:
   "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0")` in Tuist, or File → Add
   Package Dependencies… in Xcode.
4. Add the `CucumberSwiftMacros` library to your unit test target: `.package(product:
   "CucumberSwiftMacros")` in Tuist, or under the target's **General** tab, **Frameworks and
   Libraries**, in Xcode.

### With Xcode 26.4 or later: the trait in the project

Xcode 26.4 can turn on a package's traits in the project itself, so `MacrosTrait` is not
needed. Your step definitions don't change.

- **In Tuist**, add `traits:` to CucumberSwift in `Project.swift`, and remove `MacrosTrait`:

  ```swift
  .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0", traits: ["Macros"]),
  ```

  Use `.package(...)` here, not `.remote(url:requirement:)`, which has no traits.
- **In Xcode**, select the project in the project navigator, open **Package Dependencies**,
  select CucumberSwift, and turn on its **Macros** trait.

### The rest of the setup

The rest is the same as without macros: a `Features` folder reference in the test target, and
an extension of `Cucumber` that conforms to `StepImplementation`. See
[GettingStarted](../GettingStarted/README.md).

You can mix both styles in one target: the macros and the step definitions you already have
match and run the same way.

## Write a step definition

Each macro takes the pattern, a string literal, and a closure. The closure takes one argument
for each parameter of a Cucumber expression, or each capture group of a regular expression, in
the order they appear, and each argument needs its type:

| In the pattern | The argument's type |
|---|---|
| `{int}` | `Int` |
| `{float}` | `Float` |
| `{double}` | `Double` |
| `{string}`, `{word}` or `{}` | `String` |
| A capture group, in a pattern that starts with `^`, ends with `$` or is written between `/` | `String` |
| A custom parameter type, such as `{color}` | The parameter's output type |

```swift
#Given("I have {int} cukes in my {string}") { (count: Int, container: String) in
    cukes = count
}
```

Swift checks a macro's arguments before the macro runs, so it cannot work the types out from
the pattern: write them out. If one is wrong, the compiler says which type to use.

To read the step itself, for example its data table or doc string, add a last argument of type
`Step`:

```swift
#When("I eat these cukes:") { (step: Step) in
    let rows = try XCTUnwrap(step.dataTable?.rows, "List the cukes in a data table.")
    cukes -= rows.count
}
```

`#Given`, `#When`, `#Then`, `#And`, `#But` and `#MatchAll` fit the step definition functions
of the same names. Every localized step definition has a macro too, such as `#ES_Dado` for a
step that starts with "Dado".

## Mistakes the compiler finds

Each mistake is an error on the line that has it. Click the error's icon to see the whole
message, and where there is a fix, click **Apply**. `Tests/StepDefinitions.swift` has one
example of each, commented out: uncomment one to see it.

| Mistake | Example | Fix that Xcode offers |
|---|---|---|
| The closure takes too few or too many arguments | `#Given("I have {int} cukes in my {string}") { (count: Int) in }` | Change the closure's parameters to `(count: Int, string: String)` |
| An argument has the wrong type | `#When("I eat {int} cukes") { (count: String) in }` | Change the type to `Int` |
| A parameter is missing its closing brace | `#Given("I have {int cukes") { (count: Int) in }` | Insert `}` |
| Any other mistake in a Cucumber expression, such as empty optional text | `#Given("I have () cukes") {}` | None: the error says what is wrong |
| A pattern that is read as a regular expression does not compile | `#Then("the basket holds {int} cukes$") { (count: Int) in }`, where the `$` makes it a regular expression | Use it as a Cucumber Expression, which removes the `$` |
| The pattern is not a string literal | `#Given("I have \(thing)") {}` | None: write the pattern out |

A pattern that compiles but matches no step in your feature files is not a compile error,
because a macro cannot read files. CucumberSwift reports those steps when the tests run, as
GettingStarted shows.

## See what a macro does

Right-click a macro and choose **Expand Macro**. The expansion is the step definition the macro
stands for, and you can set breakpoints in it. The first step definition in this sample expands
to:

```swift
Given("I have {int} cukes in my {string}" as CucumberExpression) { match, _ in
    let count: Int = try match.first(\.int)
    let container: String = try match.first(\.string)
    XCTAssertFalse(container.isEmpty)
    cukes = count
}
```

and the regular expression's capture group is read as `match.first(\.anonymous)`.

## Copy it into a project of your own

Copy this folder, `MacrosTrait` included, and the repository's `.mise.toml`, then rename the
project and target in `Project.swift`. If you don't use mise, install Tuist another way and run `tuist generate` in
the folder.

To try the sample with a local CucumberSwift checkout instead of the release, set
`CUCUMBER_SWIFT_PATH` to its absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.
The checkout's folder must be named `CucumberSwift`: Xcode then uses it in place of the
CucumberSwift that `MacrosTrait` asks for, with the trait on.

## Learn more

- [Checking step definitions when they compile](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/checking-step-definitions),
  CucumberSwift's guide to the macros
- [GettingStarted](../GettingStarted/README.md), the same setup with the step definition
  functions
