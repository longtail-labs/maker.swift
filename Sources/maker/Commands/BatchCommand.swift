import ArgumentParser
import Foundation

extension Maker {
    struct Batch: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Run batch rendering from config file"
        )
        
        @Argument(help: "Path to batch config JSON")
        var config: String
        
        @Option(name: .long, help: "Project directory (default: current directory)")
        var project: String = "."
        
        func run() throws {
            let projectURL = URL(fileURLWithPath: project).standardizedFileURL
            guard let configPath = PathResolver.firstExisting(
                candidates: [config],
                relativeTo: projectURL
            ) else {
                print("❌ Config file not found. Tried: \(config) relative to \(projectURL.path)")
                throw ExitCode.failure
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let batchConfig = try JSONDecoder().decode(BatchConfig.self, from: data)
            
            let outputDir = PathResolver.makeAbsolute(
                batchConfig.outputDirectory ?? "output",
                relativeTo: projectURL
            )
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            print("📦 Running batch: \(batchConfig.screens.count) screens")
            print("📂 Output directory: \(outputDir)")
            
            let presets = PresetsLibrary.load(projectPath: projectURL.path)
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
                
                let outputPath = {
                    if let rawOutput = screen.output {
                        return PathResolver.makeAbsolute(rawOutput, relativeTo: projectURL)
                    } else {
                        let name = screen.name ?? "\(timestamp)-\(index + 1)"
                        return URL(fileURLWithPath: outputDir)
                            .appendingPathComponent("\(name).jpg")
                            .path
                    }
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
                    if let params = screen.params {
                        paramsPath = PathResolver.firstExisting(
                            candidates: [params],
                            relativeTo: projectURL
                        )
                    } else {
                        paramsPath = nil
                    }
                }
                
                let templatePathCandidates: [String]
                if screen.template.hasSuffix(".swift") {
                    templatePathCandidates = [screen.template]
                } else {
                    templatePathCandidates = [
                        screen.template,
                        "templates/\(screen.template)/Template.swift"
                    ]
                }
                
                guard let templatePath = PathResolver.firstExisting(
                    candidates: templatePathCandidates,
                    relativeTo: projectURL
                ) else {
                    let screenName = screen.name ?? "(unnamed)"
                    print("  ❌ Template not found for screen \(screenName). Skipping.")
                    continue
                }
                
                try renderTemplate(
                    templatePath: templatePath,
                    paramsPath: paramsPath,
                    outputPath: outputPath,
                    size: size,
                    projectPath: projectURL.path
                )
                
                if screen.paramsInline != nil, let paramsPath {
                    try? FileManager.default.removeItem(atPath: paramsPath)
                }
            }
            
            print("\n✅ Batch completed!")
        }
    }
}
