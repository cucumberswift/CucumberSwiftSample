// swift-tools-version:6.0
import PackageDescription

// Shows the coverage of each scenario on the feature file, as Xcode warnings and errors, on every
// build. It prints the lines that annotate.py wrote to coverage/annotations.txt, and does nothing
// when the file is missing. See README.md.
let package = Package(
    name: "CoverageAnnotations",
    products: [.plugin(name: "CoverageAnnotations", targets: ["CoverageAnnotations"])],
    targets: [.plugin(name: "CoverageAnnotations", capability: .buildTool())]
)
