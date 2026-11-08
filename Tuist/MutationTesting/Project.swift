import ProjectDescription

// Mutation testing: a macOS framework, Shop, and a unit test bundle whose feature files test it.
// `swift package mutation-test`, run in this folder, changes Shop's code in a temporary copy of the
// package that Package.swift describes, and runs the scenarios against each change. This Xcode project
// then shows the last run's results with each feature's coverage scores, as a Mutation test.
//
// The sample depends on the latest CucumberSwift release, from 6.9.0, the first with mutation testing.
// To build it against a local CucumberSwift checkout instead, set CUCUMBER_SWIFT_PATH and generate
// through mise, from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on as
// TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .upToNextMajor(from: "6.9.0"))
}()

let project = Project(
    name: "MutationTesting",
    packages: [cucumberSwift],
    targets: [
        // The code that mutation testing changes.
        .target(
            name: "Shop",
            destinations: .macOS,
            product: .framework,
            bundleId: "org.cucumberswift.samples.Shop",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Sources/Shop/**/*.swift"],
            settings: .settings(base: [
                "SWIFT_VERSION": "6.0",
                "CODE_SIGN_IDENTITY": "-",
            ])
        ),
        .target(
            name: "MutationTestingTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.MutationTestingTests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Tests/**/*.swift"],
            // A folder reference keeps the feature files in a "Features" folder inside the
            // test bundle, where CucumberSwift looks for them.
            resources: [.folderReference(path: "Tests/Features")],
            dependencies: [
                .target(name: "Shop"),
                .package(product: "CucumberSwift"),
                // CucumberSwiftLint checks the feature files on every build, and shows each problem as
                // a warning.
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
        // Runs Basket.feature, tagged @before, whose scenarios miss 2 mutants: the Mutation test fails.
        scheme(name: "MutationTesting", tags: "before"),
        // Runs Basket-killed.feature, tagged @after, which adds the 2 scenarios that kill them: the Mutation test passes.
        scheme(name: "MutationTesting-Killed", tags: "after"),
    ]
)

/// A scheme that runs the scenarios with `tags`, with code coverage on. Coverage matches each mutant to the scenarios
/// that run its code, for the Mutation test. Run `swift package mutation-test` with the same CUCUMBER_TAGS first.
func scheme(name: String, tags: String) -> Scheme {
    .scheme(
        name: name,
        buildAction: .buildAction(targets: ["MutationTestingTests"]),
        testAction: .targets(
            ["MutationTestingTests"],
            arguments: .arguments(environmentVariables: ["CUCUMBER_TAGS": .environmentVariable(value: tags, isEnabled: true)]),
            options: .options(coverage: true, codeCoverageTargets: ["Shop"])
        )
    )
}
