import CoreGraphics

struct ScreenSize: Codable {
    let width: Double
    let height: Double
    
    var description: String { "\(Int(width))x\(Int(height))" }
    var cgSize: CGSize { CGSize(width: width, height: height) }
}
