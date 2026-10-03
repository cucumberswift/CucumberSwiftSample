# StepDefinitionMacros

Step definitions written as macros, `#Given`, `#When` and `#Then`, which the compiler checks
where you write them: a macOS unit test bundle that runs two feature files, one in English and
one in Spanish.

**CucumberSwift version:** 6.4.0 or later, the first release with the step definition macros.

## Requirements

- **Xcode 26.4 or later, on macOS 26.2 or later**, to use the macros in an Xcode project, as
  this sample does. Xcode 26.4 is the first Xcode that can turn on a package's traits in a
  project.
- **Xcode 16.3 (Swift 6.1) or later, on macOS 15.2 or later**, to use them from a Swift
  package instead. See [Running tests with Swift Package Manager](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/running-tests-with-swift-package-manager).
- **The tests run wherever CucumberSwift runs:** macOS 10.15, iOS 13 and tvOS 13 or later.
  Each macro becomes an ordinary step definition when the code compiles, so it adds no
  runtime requirement.
- **Swift Package Manager only.** Carthage builds CucumberSwift from its Xcode project, which
  cannot deliver macros. A Carthage install keeps the step definition functions, such as
  `Given`.

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
- `Project.swift`, which adds CucumberSwift with its `Macros` trait turned on, and the
  `CucumberSwiftMacros` library.

## Run it

You need Xcode 26.4 or later and [mise](https://mise.jdx.dev), which installs the version of
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

With an earlier Xcode, the project generates, but Xcode does not turn the trait on, so the
macros do not exist and every one is an error:

```
'Given' is unavailable: Turn on CucumberSwift's Macros package trait to use the step definition macros. In an Xcode project, that needs Xcode 26.4 or later.
```

## Turn on the macros in your own project

The macros are the `CucumberSwiftMacros` library, which CucumberSwift only builds when its
`Macros` package trait is on. Turn the trait on, add the library to your test target, then
`import CucumberSwiftMacros` where you write step definitions. It imports CucumberSwift as
well.

**In a Tuist project**, add CucumberSwift with `traits:` in `Project.swift`, as this sample
does, and depend on the `CucumberSwiftMacros` product:

```swift
let project = Project(
    name: "MyApp",
    packages: [
        .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0", traits: ["Macros"]),
    ],
    targets: [
        .target(
            name: "MyAppTests",
            // …
            dependencies: [.package(product: "CucumberSwiftMacros")]
        ),
    ]
)
```

Use `.package(...)` here, not `.remote(url:requirement:)`, which has no traits.

**In an Xcode project:**

1. Add the package `https://github.com/cucumberswift/CucumberSwift` (File → Add Package
   Dependencies…), if your project does not have it yet.
2. Select the project in the project navigator, open **Package Dependencies**, select
   CucumberSwift, and turn on its **Macros** trait.
3. Add the `CucumberSwiftMacros` library to your unit test target, under the target's
   **General** tab, **Frameworks and Libraries**.

The rest of the setup is the same as without macros: a `Features` folder reference in the test
target, and an extension of `Cucumber` that conforms to `StepImplementation`. See
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
| The pattern is not a string literal | `#Given("I have \(thing)") {}` | None: write the pattern out. Swift reports that a `String` is not a `StaticString`. |

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

Copy this folder and the repository's `.mise.toml`, then rename the project and target in
`Project.swift`. If you don't use mise, install Tuist another way and run `tuist generate` in
the folder.

To try the sample with a local CucumberSwift checkout instead of the release, set
`CUCUMBER_SWIFT_PATH` to its absolute path: `CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate`.
The trait is turned on for the local checkout too.

## Learn more

- [Checking step definitions when they compile](https://cucumberswift.org/CucumberSwift/documentation/cucumberswift/checking-step-definitions),
  CucumberSwift's guide to the macros
- [GettingStarted](../GettingStarted/README.md), the same setup with the step definition
  functions
