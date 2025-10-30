import ArgumentParser
import Foundation

extension Maker {
    struct Presets: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List available size presets"
        )
        
        @Option(name: .long, help: "Project directory (default: current directory)")
        var project: String = "."
        
        func run() {
            let projectURL = URL(fileURLWithPath: project).standardizedFileURL
            let presets = PresetsLibrary.load(projectPath: projectURL.path)
            
            print("📐 Available presets:\n")
            for (name, size) in presets.sorted(by: { $0.key < $1.key }) {
                let paddedName = name.padding(toLength: 20, withPad: " ", startingAt: 0)
                print("  \(paddedName) → \(size.description)")
            }
        }
    }
}
