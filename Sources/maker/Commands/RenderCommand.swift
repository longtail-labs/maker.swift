import ArgumentParser
import Foundation

extension Maker {
    struct Render: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Render a single template"
        )
        
        @Argument(help: "Template name or path")
        var template: String
        
        @Option(name: .shortAndLong, help: "Parameters JSON file or name")
        var params: String?
        
        @Option(name: .long, help: "Size preset (e.g., instagram-square)")
        var preset: String?
        
        @Option(name: .shortAndLong, help: "Custom size (WIDTHxHEIGHT)")
        var size: String?
        
        @Option(name: .shortAndLong, help: "Output path")
        var output: String?
        
        func run() throws {
            let templatePath: String
            if template.hasSuffix(".swift") {
                templatePath = template
            } else {
                templatePath = "templates/\(template)/Template.swift"
            }
            
            guard FileManager.default.fileExists(atPath: templatePath) else {
                print("❌ Template not found: \(templatePath)")
                throw ExitCode.failure
            }
            
            let paramsPath: String?
            if let params = params {
                if params.hasSuffix(".json") || params.contains("/") {
                    paramsPath = params
                } else {
                    let templateName = template.split(separator: "/").last ?? Substring(template)
                    paramsPath = "templates/\(templateName)/params/\(params).json"
                }
            } else {
                paramsPath = nil
            }
            
            let renderSize: ScreenSize
            if let sizeStr = size {
                let parts = sizeStr.split(separator: "x")
                if parts.count == 2,
                   let width = Double(parts[0]),
                   let height = Double(parts[1]) {
                    renderSize = ScreenSize(width: width, height: height)
                } else {
                    print("❌ Invalid size format. Use WIDTHxHEIGHT")
                    throw ExitCode.failure
                }
            } else if let preset = preset {
                let presets = PresetsLibrary.load()
                if let presetSize = presets[preset.lowercased()] {
                    renderSize = presetSize
                } else {
                    print("❌ Unknown preset: \(preset)")
                    print("Run 'maker presets' to see available presets.")
                    throw ExitCode.failure
                }
            } else {
                renderSize = ScreenSize(width: 1080, height: 1350)
            }
            
            let outputPath = output ?? {
                let timestamp = DateFormatter.timestamp.string(from: Date())
                let templateName = URL(fileURLWithPath: templatePath)
                    .deletingPathExtension()
                    .lastPathComponent
                return "output/\(timestamp)-\(templateName)-\(renderSize.description).jpg"
            }()
            
            print("🎨 Rendering template...")
            print("  Template: \(templatePath)")
            if let paramsPath {
                print("  Params: \(paramsPath)")
            }
            print("  Size: \(renderSize.description)")
            print("  Output: \(outputPath)")
            
            try renderTemplate(
                templatePath: templatePath,
                paramsPath: paramsPath,
                outputPath: outputPath,
                size: renderSize
            )
        }
    }
}
