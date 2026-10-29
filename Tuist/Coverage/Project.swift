import ProjectDescription

// Code coverage for each scenario: a macOS unit test bundle runs the feature files in
// Tests/Features against the Calculator framework, and CucumberSwift writes the coverage of
// each scenario to a file.
//
// The sample depends on CucumberSwift 6.8.0, the first release that writes coverage. Until
// that release, build it against a local CucumberSwift checkout. Set CUCUMBER_SWIFT_PATH and
// generate through mise, from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .upToNextMajor(from: "6.8.0"))
}()

let project = Project(
    name: "Coverage",
    packages: [
        cucumberSwift,
        // Shows the coverage of each scenario on the feature file, as Xcode warnings and errors.
        // See README.md.
        .local(path: "CoverageAnnotations"),
    ],
    targets: [
        // The code that the scenarios cover.
        .target(
            name: "Calculator",
            destinations: .macOS,
            product: .framework,
            bundleId: "org.cucumberswift.samples.Calculator",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Sources/Calculator/**/*.swift"],
            settings: .settings(base: [
                "SWIFT_VERSION": "6.0",
                "CODE_SIGN_IDENTITY": "-",
            ])
        ),
        .target(
            name: "CoverageTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.cucumberswift.samples.CoverageTests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Tests/**/*.swift"],
            // A folder reference keeps the feature files in a "Features" folder inside the
            // test bundle, where CucumberSwift looks for them.
            resources: [.folderReference(path: "Tests/Features")],
            dependencies: [
                .target(name: "Calculator"),
                .package(product: "CucumberSwift"),
                // CucumberSwiftLint checks the feature files on every build, and shows each problem as
                // a warning. See README.md.
                .package(product: "CucumberSwiftLint", type: .plugin),
                // CoverageAnnotations shows the coverage that annotate.py wrote, on the next build.
                .package(product: "CoverageAnnotations", type: .plugin),
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
            name: "Coverage",
            buildAction: .buildAction(targets: ["CoverageTests"]),
            testAction: .targets(
                ["CoverageTests"],
                // CUCUMBER_COVERAGE turns on CucumberSwift's per-scenario files, and
                // CUCUMBER_COVERAGE_PATH is the folder they go to. Xcode expands $(PROJECT_DIR)
                // because the scheme expands variables based on the test target.
                arguments: .arguments(environmentVariables: [
                    "CUCUMBER_COVERAGE": "YES",
                    "CUCUMBER_COVERAGE_PATH": "$(PROJECT_DIR)/coverage",
                ]),
                expandVariableFromTarget: "CoverageTests",
                // After the tests, annotate.py turns the new coverage files into the annotations that
                // the next build shows on the feature file.
                postActions: [
                    .executionAction(
                        title: "Annotate the feature files",
                        scriptText: "python3 \"$PROJECT_DIR/annotate.py\"",
                        target: "CoverageTests"
                    ),
                ],
                // Xcode builds only these targets with code coverage, and CucumberSwift writes
                // the coverage of each binary that was built with it.
                options: .options(coverage: true, codeCoverageTargets: ["Calculator"])
            )
        ),
    ]
)
