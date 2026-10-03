import ProjectDescription

// Step definitions written as macros, #Given, #When and #Then, which the compiler checks:
// one macOS unit test bundle that runs the feature files in Tests/Features.
//
// The macros are the CucumberSwiftMacros product, which CucumberSwift only builds when its
// Macros package trait is on. Setting a package's traits in an Xcode project needs Xcode 26.4
// or later; with an earlier Xcode the trait is not applied and the macros do not exist.
//
// The sample depends on the latest CucumberSwift release. To build it against a local
// CucumberSwift checkout instead, set CUCUMBER_SWIFT_PATH and generate through mise,
// from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package.Dependency = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .package(path: .path(path), traits: ["Macros"]) }
    return .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "6.4.0", traits: ["Macros"])
}()

let project = Project(
    name: "StepDefinitionMacros",
    packages: [cucumberSwift],
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
            // CucumberSwiftMacros brings CucumberSwift with it.
            dependencies: [.package(product: "CucumberSwiftMacros")],
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
