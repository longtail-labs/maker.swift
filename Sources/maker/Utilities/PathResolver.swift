import Foundation

enum PathResolver {
    static func makeAbsolute(_ path: String, relativeTo baseURL: URL) -> String {
        let expanded = expand(path)
        if expanded.hasPrefix("/") {
            return URL(fileURLWithPath: expanded).standardizedFileURL.path
        } else {
            return baseURL.appendingPathComponent(expanded)
                .standardizedFileURL.path
        }
    }
    
    static func firstExisting(candidates: [String], relativeTo baseURL: URL) -> String? {
        let fileManager = FileManager.default
        for candidate in candidates {
            let absolutePath = makeAbsolute(candidate, relativeTo: baseURL)
            if fileManager.fileExists(atPath: absolutePath) {
                return absolutePath
            }
        }
        return nil
    }
    
    private static func expand(_ path: String) -> String {
        NSString(string: path).expandingTildeInPath
    }
}
