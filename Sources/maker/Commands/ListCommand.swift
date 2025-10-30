import ArgumentParser
import Foundation

extension Maker {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List available templates"
        )
        
        @Option(name: .long, help: "Project directory (default: current directory)")
        var project: String = "."
        
        func run() throws {
            let fileManager = FileManager.default
            let projectURL = URL(fileURLWithPath: project).standardizedFileURL
            let templatesDir = projectURL.appendingPathComponent("templates").path
            
            guard fileManager.fileExists(atPath: templatesDir) else {
                print("❌ No templates directory found in \(projectURL.path).")
                print("   Run 'maker init' first or pass --project to point at an existing workspace.")
                return
            }
            
            let templates = try fileManager.contentsOfDirectory(atPath: templatesDir)
                .filter { item in
                    var isDir: ObjCBool = false
                    let path = "\(templatesDir)/\(item)"
                    return fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
                }
                .filter { fileManager.fileExists(atPath: "\(templatesDir)/\($0)/Template.swift") }
            
            if templates.isEmpty {
                print("No templates found.")
                return
            }
            
            print("📦 Available templates:\n")
            for template in templates {
                print("  • \(template)")
                
                let paramsDir = "\(templatesDir)/\(template)/params"
                if fileManager.fileExists(atPath: paramsDir) {
                    if let params = try? fileManager.contentsOfDirectory(atPath: paramsDir)
                        .filter({ $0.hasSuffix(".json") })
                        .map({ $0.replacingOccurrences(of: ".json", with: "") }) {
                        if !params.isEmpty {
                            print("    params: \(params.joined(separator: ", "))")
                        }
                    }
                }
            }
        }
    }
}
