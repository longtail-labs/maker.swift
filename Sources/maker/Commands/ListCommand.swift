import ArgumentParser
import Foundation

extension Maker {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "List available templates"
        )
        
        func run() throws {
            let templatesDir = "templates"
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: templatesDir) else {
                print("❌ No templates directory found. Run 'maker init' first.")
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
