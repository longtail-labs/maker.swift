import ArgumentParser
import Foundation

extension Maker {
    struct Batch: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Run batch rendering from config file"
        )
        
        @Argument(help: "Path to batch config JSON")
        var config: String
        
        func run() throws {
            guard FileManager.default.fileExists(atPath: config) else {
                print("❌ Config file not found: \(config)")
                throw ExitCode.failure
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: config))
            let batchConfig = try JSONDecoder().decode(BatchConfig.self, from: data)
            
            let outputDir = batchConfig.outputDirectory ?? "output"
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            print("📦 Running batch: \(batchConfig.screens.count) screens")
            print("📂 Output directory: \(outputDir)")
            
            let presets = PresetsLibrary.load()
            let timestamp = DateFormatter.timestamp.string(from: Date())
            
            for (index, screen) in batchConfig.screens.enumerated() {
                print("\n[\(index + 1)/\(batchConfig.screens.count)] Rendering \(screen.name ?? "screen-\(index + 1)")")
                
                let size: ScreenSize
                if let screenSize = screen.size {
                    size = screenSize
                } else if let preset = screen.preset,
                          let presetSize = presets[preset.lowercased()] {
                    size = presetSize
                } else {
                    size = ScreenSize(width: 1080, height: 1350)
                }
                
                let outputPath = screen.output ?? {
                    let name = screen.name ?? "\(timestamp)-\(index + 1)"
                    return "\(outputDir)/\(name).jpg"
                }()
                
                let paramsPath: String?
                if let inlineParams = screen.paramsInline {
                    let tempPath = "/tmp/maker-params-\(UUID().uuidString).json"
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let inlineData = try encoder.encode(inlineParams)
                    try inlineData.write(to: URL(fileURLWithPath: tempPath))
                    paramsPath = tempPath
                } else {
                    paramsPath = screen.params
                }
                
                try renderTemplate(
                    templatePath: screen.template,
                    paramsPath: paramsPath,
                    outputPath: outputPath,
                    size: size
                )
                
                if screen.paramsInline != nil, let paramsPath {
                    try? FileManager.default.removeItem(atPath: paramsPath)
                }
            }
            
            print("\n✅ Batch completed!")
        }
    }
}
