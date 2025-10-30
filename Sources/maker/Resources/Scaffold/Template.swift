import SwiftUI

struct Template: View {
    struct Params: Codable {
        let title: String
        let subtitle: String
        let backgroundColor: String
        let accentColor: String
    }
    
    let params: Params
    
    init(json: String) {
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(Params.self, from: data) {
            self.params = decoded
        } else {
            self.params = Params(
                title: "HELLO",
                subtitle: "WORLD",
                backgroundColor: "#FFFFFF",
                accentColor: "#007AFF"
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: params.backgroundColor)
            
            VStack(spacing: 20) {
                Text(params.title)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Color(hex: params.accentColor))
                
                Text(params.subtitle)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(Color(hex: params.accentColor).opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
