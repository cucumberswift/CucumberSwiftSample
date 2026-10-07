import ProjectDescription

// Scenarios run side by side with Xcode's parallel testing, through CucumberSwift's
// experimental parallel testing setting. The Parallel test plan turns both on; the Serial
// test plan runs the same scenarios one after another, to compare.
//
// The sample depends on the latest CucumberSwift release, from 6.4.0, which added parallel
// testing. To build it against a local CucumberSwift checkout instead, set
// CUCUMBER_SWIFT_PATH and generate through mise, from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .upToNextMajor(from: "6.4.0"))
}()

let project = Project(
    name: "ParallelTesting",
    packages: [cucumberSwift],
    targets: [
        .target(
            name: "ParallelTestingTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.ParallelTestingTests",
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
            name: "ParallelTesting",
            buildAction: .buildAction(targets: ["ParallelTestingTests"]),
            // The first test plan is the default. Parallel turns on Execute in parallel and
            // sets CUCUMBER_PARALLEL_TESTING to YES; Serial has neither.
            testAction: .testPlans([
                "TestPlans/Parallel.xctestplan",
                "TestPlans/Serial.xctestplan",
            ])
        ),
    ]
)
