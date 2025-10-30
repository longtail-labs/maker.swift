import ArgumentParser

extension Maker {
    struct Presets: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List available size presets"
        )
        
        func run() {
            let presets = PresetsLibrary.load()
            
            print("📐 Available presets:\n")
            for (name, size) in presets.sorted(by: { $0.key < $1.key }) {
                let paddedName = name.padding(toLength: 20, withPad: " ", startingAt: 0)
                print("  \(paddedName) → \(size.description)")
            }
        }
    }
}
