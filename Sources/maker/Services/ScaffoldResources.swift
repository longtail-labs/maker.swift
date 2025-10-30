import Foundation

enum ScaffoldResources {
    private static let scaffoldSubdirectory = "Scaffold"
    
    static func exampleTemplate() throws -> String {
        try loadString(named: "Template", withExtension: "swift")
    }
    
    static func defaultParams() throws -> String {
        try loadString(named: "default", withExtension: "json")
    }
    
    static func batchConfig() throws -> String {
        try loadString(named: "example", withExtension: "json")
    }
    
    static func presetsJSON() throws -> Data {
        try loadData(named: "presets", withExtension: "json")
    }
    
    static func defaultPresets() -> [String: ScreenSize] {
        guard
            let data = try? presetsJSON(),
            let library = try? JSONDecoder().decode([String: ScreenSize].self, from: data)
        else {
            return [:]
        }
        return library
    }
    
    private static func loadString(named name: String, withExtension ext: String) throws -> String {
        let url = try resourceURL(named: name, withExtension: ext)
        return try String(contentsOf: url)
    }
    
    private static func loadData(named name: String, withExtension ext: String) throws -> Data {
        let url = try resourceURL(named: name, withExtension: ext)
        return try Data(contentsOf: url)
    }
    
    private static func resourceURL(named name: String, withExtension ext: String) throws -> URL {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: scaffoldSubdirectory
        ) else {
            throw ResourceError.missingResource(name: name, ext: ext)
        }
        return url
    }
    
    enum ResourceError: Error, LocalizedError {
        case missingResource(name: String, ext: String)
        
        var errorDescription: String? {
            switch self {
            case .missingResource(let name, let ext):
                return "Unable to locate scaffold resource \(name).\(ext)"
            }
        }
    }
}
