import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

/// Prints `coverage/annotations.txt`, next to the Xcode project, in the form that Xcode reads as build
/// issues: `path:line:column: warning: message`. Xcode shows only the first issue that a command
/// prints, so annotate.py separates the issues with a blank line, and this plugin runs one command for each.
@main struct CoverageAnnotations: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        []
    }

    func commands(annotations: URL, work: URL) -> [Command] {
        guard let text = try? String(contentsOf: annotations, encoding: .utf8) else { return [] }
        return text.components(separatedBy: "\n\n").enumerated().map { index, block in
            // Xcode marks a command as failed when its output folder doesn't exist.
            let output = work.appending(path: "\(index)")
            try? FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            return .prebuildCommand(
                displayName: "Coverage annotation \(index + 1)",
                executable: URL(filePath: "/usr/bin/printf"),
                arguments: ["%s\\n"] + block.split(separator: "\n").map(String.init),
                outputFilesDirectory: output
            )
        }
    }
}

#if canImport(XcodeProjectPlugin)
extension CoverageAnnotations: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        commands(
            annotations: context.xcodeProject.directoryURL.appending(path: "coverage/annotations.txt"),
            work: context.pluginWorkDirectoryURL
        )
    }
}
#endif
