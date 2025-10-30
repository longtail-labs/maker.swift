import ArgumentParser

struct Maker: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "maker",
        abstract: "SwiftUI template renderer for social media assets",
        version: "1.0.0",
        subcommands: [Init.self, List.self, Render.self, Batch.self, Presets.self]
    )
}
