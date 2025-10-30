import AppKit
import ArgumentParser
import Foundation
import SwiftUI

func renderTemplate(
    templatePath: String,
    paramsPath: String?,
    outputPath: String,
    size: ScreenSize,
    projectPath: String
) throws {
    let templateCode = try String(contentsOf: URL(fileURLWithPath: templatePath))
    
    let jsonString: String
    if let paramsPath = paramsPath {
        jsonString = (try? String(contentsOf: URL(fileURLWithPath: paramsPath))) ?? "{}"
    } else {
        jsonString = "{}"
    }
    
    let escapedJson = jsonString
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\t", with: "\\t")
    
    let componentsCode = loadComponentSources(
        templatePath: templatePath,
        projectPath: projectPath
    )
    
    let tempFile = "/tmp/maker-render-\(UUID().uuidString).swift"
    let renderCode = """
    import SwiftUI
    import AppKit
    import Foundation
    
    let canvasWidth: Double = \(size.width)
    let canvasHeight: Double = \(size.height)
    
    extension Color {
        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    }
    
    class TemplateRenderer {
        static func render<T: View>(_ view: T, size: CGSize) -> NSImage? {
            let controller = NSHostingController(
                rootView: view.frame(width: size.width, height: size.height)
            )
            controller.view.frame = CGRect(origin: .zero, size: size)
            
            guard let bitmap = controller.view.bitmapImageRepForCachingDisplay(
                in: controller.view.bounds
            ) else {
                return nil
            }
            
            controller.view.cacheDisplay(in: controller.view.bounds, to: bitmap)
            
            let image = NSImage(size: size)
            image.addRepresentation(bitmap)
            
            return image
        }
        
        static func saveImage(_ image: NSImage, to path: String) -> Bool {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData),
                  let jpegData = bitmapRep.representation(
                    using: .jpeg,
                    properties: [.compressionFactor: 0.95]
                  ) else {
                return false
            }
            
            do {
                try jpegData.write(to: URL(fileURLWithPath: path))
                return true
            } catch {
                print("Error saving image: \\(error)")
                return false
            }
        }
    }
    
    \(componentsCode)
    
    \(templateCode)
    
    let jsonString = "\(escapedJson)"
    let template = Template(json: jsonString)
    
    if let image = TemplateRenderer.render(
        template,
        size: CGSize(width: canvasWidth, height: canvasHeight)
    ) {
        let outputURL = URL(fileURLWithPath: "\(outputPath)")
        try? FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        if TemplateRenderer.saveImage(image, to: "\(outputPath)") {
            print("  ✅ Saved to: \(outputPath)")
        } else {
            print("  ❌ Failed to save image")
            exit(1)
        }
    } else {
        print("  ❌ Failed to render template")
        exit(1)
    }
    """
    
    try renderCode.write(to: URL(fileURLWithPath: tempFile), atomically: true, encoding: .utf8)
    
    let process = Process()
    process.launchPath = "/usr/bin/swift"
    process.arguments = [tempFile]
    
    let pipe = Pipe()
    process.standardError = pipe
    
    process.launch()
    process.waitUntilExit()
    
    try? FileManager.default.removeItem(atPath: tempFile)
    
    if process.terminationStatus != 0 {
        let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
        if let errorString = String(data: errorData, encoding: .utf8), !errorString.isEmpty {
            print("  ❌ Compilation error:")
            print(errorString)
        }
        throw ExitCode.failure
    }
}

func loadComponentSources(templatePath: String, projectPath: String) -> String {
    var sources: [String] = []
    let fileManager = FileManager.default
    
    let globalComponentsPath = URL(fileURLWithPath: projectPath)
        .appendingPathComponent("components")
        .path
    if fileManager.fileExists(atPath: globalComponentsPath) {
        sources.append(loadSwiftFiles(from: globalComponentsPath))
    }
    
    let templateDir = URL(fileURLWithPath: templatePath).deletingLastPathComponent().path
    let localComponentsPath = "\(templateDir)/components"
    if fileManager.fileExists(atPath: localComponentsPath) {
        sources.append(loadSwiftFiles(from: localComponentsPath))
    }
    
    return sources.filter { !$0.isEmpty }.joined(separator: "\n\n")
}

func loadSwiftFiles(from directory: String) -> String {
    let fileManager = FileManager.default
    var sources: [String] = []
    
    if let enumerator = fileManager.enumerator(atPath: directory) {
        for case let file as String in enumerator where file.hasSuffix(".swift") {
            let filePath = "\(directory)/\(file)"
            if let content = try? String(contentsOf: URL(fileURLWithPath: filePath)) {
                sources.append(content)
            }
        }
    }
    
    return sources.joined(separator: "\n\n")
}
