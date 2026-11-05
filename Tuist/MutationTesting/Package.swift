// swift-tools-version:6.1
import PackageDescription

// The same code and scenarios as Project.swift, as a Swift package, for `swift package mutation-test`.
// Mutation testing runs on Swift packages: it copies this package to a temporary folder, changes
// Sources/Shop there, and runs `swift test` against each change. It never changes this folder.
//
// Mutation testing reads Swift code with swift-syntax, so CucumberSwift's Macros trait is on. To use a
// local CucumberSwift checkout, set CUCUMBER_SWIFT_PATH, as for Project.swift:
//
//     CUCUMBER_SWIFT_PATH=~/src/CucumberSwift swift package mutation-test
let cucumberSwift: Package.Dependency = {
    if let path = Context.environment["CUCUMBER_SWIFT_PATH"], !path.isEmpty {
        return .package(name: "CucumberSwift", path: path, traits: ["Macros"])
    }
    return .package(url: "https://github.com/cucumberswift/CucumberSwift.git", from: "6.9.0", traits: ["Macros"])
}()

let package = Package(
    name: "MutationTesting",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Shop", targets: ["Shop"])
    ],
    dependencies: [
        cucumberSwift,
        // Before Swift 6.4, SwiftPM needs this to resolve the Macros trait. No target uses it.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"605.0.0")
    ],
    targets: [
        .target(name: "Shop", path: "Sources/Shop"),
        .testTarget(
            name: "MutationTestingTests",
            dependencies: [
                "Shop",
                .product(name: "CucumberSwift", package: "CucumberSwift")
            ],
            path: "Tests",
            resources: [.copy("Features")]
        )
    ]
)
