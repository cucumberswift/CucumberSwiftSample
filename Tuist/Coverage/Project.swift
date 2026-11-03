import ProjectDescription

// Code coverage scores for each feature: a macOS unit test bundle runs the feature files in
// Tests/Features against the Calculator and Account frameworks, and CucumberSwift scores each
// feature's coverage and redundancy, and shows a warning or an error for a score past its level.
// Each feature file that raises an issue has an optimized version next to it that raises none.
//
// The sample depends on CucumberSwift 6.8.1 or later, which measures coverage and only warns about it by default. To build
// it against a local CucumberSwift checkout instead, set CUCUMBER_SWIFT_PATH and generate through
// mise, from anywhere in this repository:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift mise run generate
//
// Tuist only passes variables that start with TUIST_ to a manifest, so mise hands it on
// as TUIST_CUCUMBER_SWIFT_PATH. Run tuist directly with that name instead.
let cucumberSwift: Package = {
    let path = Environment.cucumberSwiftPath.getString(default: "")
    guard path.isEmpty else { return .local(path: .path(path)) }
    return .remote(url: "https://github.com/cucumberswift/CucumberSwift", requirement: .upToNextMajor(from: "6.8.1"))
}()

let project = Project(
    name: "Coverage",
    packages: [
        cucumberSwift,
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
        // The code that the ProfileMenu scenarios cover.
        .target(
            name: "Account",
            destinations: .macOS,
            product: .framework,
            bundleId: "org.cucumberswift.samples.Account",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Sources/Account/**/*.swift"],
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
                .target(name: "Account"),
                .package(product: "CucumberSwift"),
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
            name: "Coverage",
            buildAction: .buildAction(targets: ["CoverageTests"]),
            testAction: .targets(
                ["CoverageTests"],
                // CucumberSwift scores coverage and redundancy because the scheme builds the
                // Calculator and Account frameworks with code coverage. CUCUMBER_REDUNDANCY_ERROR_LEVEL turns on
                // the redundancy's error, and CUCUMBER_COVERAGE_ERROR_LEVEL turns on the coverage
                // error. Both are off by default. CUCUMBER_COVERAGE_PATH is the
                // folder for each scenario's coverage file. Xcode expands $(PROJECT_DIR) because
                // the scheme expands variables based on the test target.
                arguments: .arguments(environmentVariables: [
                    "CUCUMBER_COVERAGE_ERROR_LEVEL": "50",
                    "CUCUMBER_REDUNDANCY_ERROR_LEVEL": "40",
                    "CUCUMBER_COVERAGE_PATH": "$(PROJECT_DIR)/coverage",
                ]),
                expandVariableFromTarget: "CoverageTests",
                // Xcode builds only these targets with code coverage, and CucumberSwift measures
                // the code of each binary that was built with it.
                options: .options(coverage: true, codeCoverageTargets: ["Calculator", "Account"])
            )
        ),
    ]
)
