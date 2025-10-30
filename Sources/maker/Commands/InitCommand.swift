import ArgumentParser
import Foundation

extension Maker {
    struct Init: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Initialize a new maker project structure"
        )
        
        @Option(name: .shortAndLong, help: "Directory to initialize (default: makers)")
        var path: String = "makers"
        
        func run() throws {
            let fileManager = FileManager.default
            
            print("🎨 Initializing maker project in '\(path)'...")
            
            let directories = ["templates", "components", "configs", "assets", "output"]
            for directory in directories {
                let directoryPath = "\(path)/\(directory)"
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
                print("  ✓ Created \(directory)/")
            }
            
            let exampleTemplatePath = "\(path)/templates/Example"
            try fileManager.createDirectory(atPath: exampleTemplatePath, withIntermediateDirectories: true)
            
            let templateContent = try ScaffoldResources.exampleTemplate()
            try templateContent.write(
                to: URL(fileURLWithPath: "\(exampleTemplatePath)/Template.swift"),
                atomically: true,
                encoding: .utf8
            )
            
            let paramsPath = "\(exampleTemplatePath)/params"
            try fileManager.createDirectory(atPath: paramsPath, withIntermediateDirectories: true)
            
            let paramsContent = try ScaffoldResources.defaultParams()
            try paramsContent.write(
                to: URL(fileURLWithPath: "\(paramsPath)/default.json"),
                atomically: true,
                encoding: .utf8
            )
            
            let batchConfig = try ScaffoldResources.batchConfig()
            try batchConfig.write(
                to: URL(fileURLWithPath: "\(path)/configs/example.json"),
                atomically: true,
                encoding: .utf8
            )
            
            let presetsContent = try String(data: ScaffoldResources.presetsJSON(), encoding: .utf8) ?? ""
            try presetsContent.write(
                to: URL(fileURLWithPath: "\(path)/presets.json"),
                atomically: true,
                encoding: .utf8
            )
            
            print("\n✅ Project initialized successfully!")
            print("\nNext steps:")
            print("  cd \(path)")
            print("  maker list                  # List available templates")
            print("  maker render Example         # Render example template")
            print("  maker batch configs/example  # Run example batch")
        }
    }
}
