# Maker

SwiftUI-powered asset generation for social media. Create beautiful Instagram posts, App Store screenshots, and more using code-based templates.

## Features

- 🎨 **SwiftUI Templates** - Design assets using familiar SwiftUI syntax
- 📱 **Platform Presets** - Built-in sizes for Instagram, TikTok, App Store
- 🔄 **Batch Rendering** - Generate entire campaigns in one command
- 🎯 **JSON Parameters** - Easy customization without touching code
- 🚀 **LLM-Ready** - Templates work great with AI code generation

## Quick Start

```bash
# Build the tool
swift build

# Initialize a new project
swift run maker init

# List available templates
swift run maker list

# Render a template
swift run maker render Example

# Run a batch job
swift run maker batch configs/example.json
```

## Installation

### From Source

```bash
git clone https://github.com/yourusername/maker.swift
cd maker.swift
swift build -c release
sudo cp .build/release/maker /usr/local/bin/
```

### Usage

```bash
# Initialize a project
maker init

# See available templates
maker list

# Render with default settings
maker render Example

# Render with custom parameters and size
maker render Example -p custom --preset instagram-square

# Render with explicit paths
maker render templates/Example/Template.swift \
  --params templates/Example/params/default.json \
  --size 1080x1080 \
  --output my-image.jpg

# Run batch rendering
maker batch configs/instagram-carousel.json

# List size presets
maker presets
```

## Project Structure

```
makers/                 # Default project directory
├── templates/          # Your SwiftUI templates
│   └── Example/
│       ├── Template.swift      # SwiftUI view
│       └── params/             # Parameter sets
│           └── default.json    # Default parameters
├── components/         # Shared UI components
├── configs/           # Batch job configurations
├── assets/            # Images and resources
├── output/            # Generated images
└── presets.json       # Custom size presets
```

## Creating Templates

Templates are SwiftUI views that accept JSON parameters:

```swift
// templates/MyTemplate/Template.swift
import SwiftUI

struct Template: View {
    struct Params: Codable {
        let title: String
        let subtitle: String
        let primaryColor: String
        let backgroundColor: String
    }
    
    let params: Params
    
    init(json: String) {
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(Params.self, from: data) {
            self.params = decoded
        } else {
            self.params = Params(
                title: "DEFAULT",
                subtitle: "TITLE",
                primaryColor: "#000000",
                backgroundColor: "#FFFFFF"
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: params.backgroundColor)
            
            VStack(spacing: 20) {
                Text(params.title)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color(hex: params.primaryColor))
                
                Text(params.subtitle)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Color(hex: params.primaryColor).opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

## Parameters

Create JSON files to customize templates:

```json
// templates/MyTemplate/params/vibrant.json
{
    "title": "HELLO",
    "subtitle": "WORLD",
    "primaryColor": "#FF6B6B",
    "backgroundColor": "#4ECDC4"
}
```

Use parameters when rendering:
```bash
maker render MyTemplate -p vibrant
```

## Batch Rendering

Create campaigns with multiple screens:

```json
// configs/my-campaign.json
{
    "outputDirectory": "output/campaign",
    "screens": [
        {
            "name": "intro",
            "template": "templates/MyTemplate/Template.swift",
            "params": "templates/MyTemplate/params/vibrant.json",
            "preset": "instagram-square"
        },
        {
            "name": "main",
            "template": "templates/MyTemplate/Template.swift",
            "preset": "instagram-portrait",
            "paramsInline": {
                "title": "SWIPE UP",
                "subtitle": "Learn More",
                "primaryColor": "#FFFFFF",
                "backgroundColor": "#000000"
            }
        }
    ]
}
```

Run the batch:
```bash
maker batch configs/my-campaign.json
```

## Size Presets

Built-in presets for social platforms:

| Preset | Size | Platform |
|--------|------|----------|
| `instagram-square` | 1080×1080 | Instagram Feed |
| `instagram-portrait` | 1080×1350 | Instagram Portrait |
| `instagram-landscape` | 1080×566 | Instagram Landscape |
| `appstore-iphone` | 1284×2778 | App Store Screenshots |
| `appstore-ipad` | 2048×2732 | iPad App Store |

Add custom presets in `presets.json`:
```json
{
    "tiktok-vertical": {"width": 1080, "height": 1920},
    "twitter-header": {"width": 1500, "height": 500}
}
```

## Tips & Tricks

### Using Assets
Reference images in your templates:
```swift
if let image = NSImage(contentsOfFile: "assets/background.jpg") {
    Image(nsImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
}
```

### Global Variables
Templates have access to canvas dimensions:
```swift
Text("Width: \(Int(canvasWidth))")
Text("Height: \(Int(canvasHeight))")
```

### Shared Components
Create reusable components in `components/`:
```swift
// components/Logo.swift
struct Logo: View {
    var body: some View {
        // Your logo implementation
    }
}
```

### Color Extension
Use hex colors in templates:
```swift
Color(hex: "#FF6B6B")  // RGB
Color(hex: "#80FF6B6B") // RGBA
```

## Examples

### Instagram Carousel
```bash
# Create a 5-slide carousel
maker batch configs/instagram-carousel.json
```

### App Store Screenshots
```bash
# Generate device-specific screenshots
maker render AppStoreHero --preset appstore-iphone
```

### Social Media Campaign
```bash
# Render same content for multiple platforms
maker render Campaign --preset instagram-square -o output/instagram.jpg
maker render Campaign --size 1080x1920 -o output/tiktok.jpg
maker render Campaign --size 1200x630 -o output/facebook.jpg
```

## Troubleshooting

**Template not found**
- Ensure Template.swift exists in the template folder
- Check the template name matches the folder name

**JSON parse errors**
- Validate JSON syntax with a JSON validator
- Ensure parameter names match the Codable struct

**Compilation errors**
- Test SwiftUI code in Xcode first
- Check for missing imports or syntax errors

**Image not rendering**
- Verify asset paths are correct
- Ensure images exist in the assets folder

## Contributing

Pull requests are welcome! Please read CLAUDE.md for development guidelines.

## License

MIT