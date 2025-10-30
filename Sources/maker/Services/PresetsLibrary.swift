import Foundation

struct PresetsLibrary {
    static func load(projectPath: String = ".") -> [String: ScreenSize] {
        let projectURL = URL(fileURLWithPath: projectPath).standardizedFileURL
        let presetsURL = projectURL.appendingPathComponent("presets.json")
        
        if let data = try? Data(contentsOf: presetsURL),
           let presets = try? JSONDecoder().decode([String: ScreenSize].self, from: data) {
            return presets
        }
        return bundledPresets
    }
    
    private static let bundledPresets: [String: ScreenSize] = {
        if let data = try? ScaffoldResources.presetsJSON(),
           let presets = try? JSONDecoder().decode([String: ScreenSize].self, from: data) {
            return presets
        }
        return fallbackPresets
    }()
    
    private static let fallbackPresets: [String: ScreenSize] = [
        "instagram-square": ScreenSize(width: 1080, height: 1080),
        "instagram-portrait": ScreenSize(width: 1080, height: 1350),
        "instagram-landscape": ScreenSize(width: 1080, height: 566),
        "appstore-iphone": ScreenSize(width: 1284, height: 2778),
        "appstore-ipad": ScreenSize(width: 2048, height: 2732)
    ]
}
