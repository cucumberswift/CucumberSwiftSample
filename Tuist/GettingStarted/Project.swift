import ProjectDescription

// The smallest working CucumberSwift setup: one macOS unit test bundle that runs the
// feature files in Tests/Features.
//
// The sample depends on the latest CucumberSwift release. To build it against a local
// CucumberSwift checkout instead, set CUCUMBER_SWIFT_PATH and generate through mise,
// from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .upToNextMajor(from: "6.3.0"))
}()

let project = Project(
    name: "GettingStarted",
    packages: [cucumberSwift],
    targets: [
        .target(
            name: "GettingStartedTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.GettingStartedTests",
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
            name: "GettingStarted",
            buildAction: .buildAction(targets: ["GettingStartedTests"]),
            testAction: .targets(["GettingStartedTests"])
        ),
    ]
)
