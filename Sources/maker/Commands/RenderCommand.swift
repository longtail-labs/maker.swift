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
        
        @Option(name: .long, help: "Project directory (default: current directory)")
        var project: String = "."
        
        func run() throws {
            let projectURL = URL(fileURLWithPath: project).standardizedFileURL
            
            let templateCandidates: [String]
            if template.hasSuffix(".swift") {
                templateCandidates = [template]
            } else {
                templateCandidates = [
                    "templates/\(template)/Template.swift",
                    template
                ]
            }
            
            guard let templatePath = PathResolver.firstExisting(
                candidates: templateCandidates,
                relativeTo: projectURL
            ) else {
                let candidateList = templateCandidates.joined(separator: ", ")
                print("❌ Template not found. Tried: \(candidateList) relative to \(projectURL.path)")
                throw ExitCode.failure
            }
            
            let templateFolder = URL(fileURLWithPath: templatePath)
                .deletingLastPathComponent()
                .lastPathComponent
            
            let paramsPath: String?
            if let params = params {
                let paramsCandidates: [String]
                if params.hasSuffix(".json") || params.contains("/") {
                    paramsCandidates = [params]
                } else {
                    paramsCandidates = [
                        "templates/\(templateFolder)/params/\(params).json",
                        params
                    ]
                }
                paramsPath = PathResolver.firstExisting(
                    candidates: paramsCandidates,
                    relativeTo: projectURL
                )
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
                let presets = PresetsLibrary.load(projectPath: projectURL.path)
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
            
            let outputPath = {
                if let custom = output {
                    return PathResolver.makeAbsolute(custom, relativeTo: projectURL)
                } else {
                    let timestamp = DateFormatter.timestamp.string(from: Date())
                    let templateName = URL(fileURLWithPath: templatePath)
                        .deletingPathExtension()
                        .lastPathComponent
                    let relativeOutput = "output/\(timestamp)-\(templateName)-\(renderSize.description).jpg"
                    return PathResolver.makeAbsolute(relativeOutput, relativeTo: projectURL)
                }
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
                size: renderSize,
                projectPath: projectURL.path
            )
        }
    }
}
