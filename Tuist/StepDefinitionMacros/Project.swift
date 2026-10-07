import ProjectDescription

// Step definitions written as macros, #Given, #When and #Then, which the compiler checks:
// one macOS unit test bundle that runs the feature files in Tests/Features.
//
// The macros are the CucumberSwiftMacros product, which CucumberSwift only builds when its
// Macros package trait is on. An Xcode project can turn on a package's traits itself only from
// Xcode 26.4, so MacrosTrait, a local package, turns it on in its own manifest instead. That
// works with any Xcode that has Swift 6.1 (Xcode 16.3). See README.md.
//
// The sample depends on the latest CucumberSwift release. To build it against a local
// CucumberSwift checkout instead, set CUCUMBER_SWIFT_PATH and generate through mise,
// from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// The checkout's folder must be named CucumberSwift: Xcode then uses it in place of the
// CucumberSwift that MacrosTrait asks for. Tuist only passes variables that start with TUIST_
// to a manifest, so mise hands it on as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with
// that name instead.
let cucumberSwift: Package.Dependency = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .package(path: .path(path)) }
    return .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0")
}()

let project = Project(
    name: "StepDefinitionMacros",
    packages: [
        cucumberSwift,
        // Only turns on CucumberSwift's Macros trait. Nothing links it. With Xcode 26.4 or later,
        // add `traits: ["Macros"]` to CucumberSwift above instead, and remove MacrosTrait.
        .package(path: "MacrosTrait"),
    ],
    targets: [
        .target(
            name: "StepDefinitionMacrosTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.StepDefinitionMacrosTests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Tests/**/*.swift"],
            // A folder reference keeps the feature files in a "Features" folder inside the
            // test bundle, where CucumberSwift looks for them.
            resources: [.folderReference(path: "Tests/Features")],
            dependencies: [
                // CucumberSwiftMacros brings CucumberSwift with it.
                .package(product: "CucumberSwiftMacros"),
                // CucumberSwiftLint checks the feature files on every build, and shows each problem as
                // a warning. See README.md.
                .package(product: "CucumberSwiftLint", type: .plugin),
            ],
            settings: .settings(base: [
                "SWIFT_VERSION": "6.0",
                // Lets the sample build and run without a signing team.
                "CODE_SIGN_IDENTITY": "-",
            ])
        ),
    ],
    schemes: [
        .scheme(
            name: "StepDefinitionMacros",
            buildAction: .buildAction(targets: ["StepDefinitionMacrosTests"]),
            testAction: .targets(["StepDefinitionMacrosTests"])
        ),
    ]
)
