import ProjectDescription

// How scenarios read in Xcode's test navigator: readable test names, failures at the
// feature file's line, Scenario Outline examples, skipped scenarios and a test plan per tag.
//
// These features are on CucumberSwift's main branch but not released yet. Until they are,
// this sample depends on main; once they ship, it moves to the release that has them.
// To build it against a local CucumberSwift checkout instead, set
// CUCUMBER_SWIFT_PATH and generate through mise, from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .branch("main"))
}()

let project = Project(
    name: "TestNavigator",
    packages: [cucumberSwift],
    targets: [
        .target(
            name: "TestNavigatorTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.TestNavigatorTests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Tests/**/*.swift"],
            // A folder reference keeps the feature files in a "Features" folder inside the
            // test bundle, where CucumberSwift looks for them.
            resources: [.folderReference(path: "Tests/Features")],
            dependencies: [.package(product: "CucumberSwift")],
            settings: .settings(base: [
                "SWIFT_VERSION": "6.0",
                // Lets the sample build and run without a signing team.
                "CODE_SIGN_IDENTITY": "-",
            ])
        ),
    ],
    schemes: [
        .scheme(
            name: "TestNavigator",
            buildAction: .buildAction(targets: ["TestNavigatorTests"]),
            // The first test plan is the default: it runs every scenario. The others run
            // the scenarios with one tag each, through CUCUMBER_TAGS.
            testAction: .testPlans([
                "TestPlans/TestNavigator.xctestplan",
                "TestPlans/Smoke.xctestplan",
                "TestPlans/Checkout.xctestplan",
            ])
        ),
    ]
)
