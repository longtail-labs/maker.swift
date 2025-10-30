# Maker Development Guide

## Overview
Maker is a Swift CLI tool that renders SwiftUI templates to JPEG images for social media assets. It works by dynamically compiling SwiftUI code at runtime with parameters from JSON files.

## Architecture

### Core Components

1. **CLI Interface** (`Sources/main.swift`)
   - Built with swift-argument-parser
   - Commands: init, list, render, batch, presets
   - Handles argument parsing and validation

2. **Template System**
   - Templates are SwiftUI views that accept JSON parameters
   - Must export a `Template` struct with `init(json: String)`
   - Access to global `canvasWidth` and `canvasHeight` variables

3. **Rendering Engine**
   - Creates temporary Swift file with template + rendering code
   - Compiles and executes using `/usr/bin/swift`
   - Renders to NSImage then saves as JPEG

### Directory Structure
```
makers/
├── templates/          # SwiftUI template definitions
│   └── Example/
│       ├── Template.swift
│       ├── params/     # Template-specific parameters
│       └── components/ # Template-specific components
├── components/         # Shared SwiftUI components
├── configs/            # Batch rendering configurations
├── assets/             # Image assets referenced by templates
├── output/             # Generated images
└── presets.json        # Size preset definitions
```

## Key Concepts

### Templates
Templates are SwiftUI views with specific requirements:
- Must have a `Template` struct implementing `View`
- Must have `init(json: String)` constructor
- Should decode JSON to strongly-typed params
- Can use `Color(hex:)` extension for colors
- Access canvas dimensions via global variables

Example:
```swift
struct Template: View {
    struct Params: Codable {
        let title: String
        let backgroundColor: String
    }
    
    let params: Params
    
    init(json: String) {
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(Params.self, from: data) {
            self.params = decoded
        } else {
            self.params = Params(title: "Default", backgroundColor: "#FFFFFF")
        }
    }
    
    var body: some View {
        // Your view implementation
    }
}
```

### Parameters
- JSON files containing template parameters
- Stored in `templates/[TemplateName]/params/`
- Can be inline in batch configs with `paramsInline`

### Batch Configs
JSON files defining multiple renders:
```json
{
    "outputDirectory": "output/campaign",
    "screens": [
        {
            "name": "slide-1",
            "template": "templates/Minimal/Template.swift",
            "params": "templates/Minimal/params/default.json",
            "preset": "instagram-square"
        }
    ]
}
```

### Presets
Predefined canvas sizes for social media platforms:
- instagram-square: 1080x1080
- instagram-portrait: 1080x1350
- appstore-iphone: 1284x2778
- Custom presets in presets.json

## Commands

### `maker init`
Creates project structure with example template.

### `maker list`
Lists available templates and their parameters.

### `maker render [template]`
Renders single template with options:
- `--params/-p`: JSON file or param name
- `--preset`: Size preset name
- `--size/-s`: Custom size (WIDTHxHEIGHT)
- `--output/-o`: Output path

### `maker batch [config]`
Runs batch rendering from JSON config.

### `maker presets`
Lists available size presets.

## Development Tips

### Adding New Templates
1. Create folder in `templates/`
2. Add `Template.swift` with required structure
3. Create `params/` subfolder with JSON examples
4. Optional: Add template-specific components

### Testing Templates
```bash
# Quick test with default params
maker render MyTemplate

# Test with specific params and size
maker render MyTemplate -p custom --preset instagram-square

# Test batch rendering
maker batch configs/test.json
```

### Debugging
- Compilation errors show Swift compiler output
- Templates compile to `/tmp/maker-render-*.swift`
- Check escaped JSON in temp files for param issues

### Performance
- Templates compile on each render (intentional for flexibility)
- Batch rendering reuses timestamp for consistent naming
- Component loading is hierarchical (global → template-specific)

## Common Issues

### Template Not Found
- Ensure Template.swift exists in template folder
- Check path resolution (relative to project root)

### JSON Parse Errors
- Verify JSON is valid
- Check parameter types match Codable struct
- Ensure proper escaping in batch configs

### Render Failures
- Verify SwiftUI code compiles standalone
- Check image asset paths are correct
- Ensure output directory is writable

## Extension Points

### Custom Components
Place shared SwiftUI components in `components/`:
```swift
// components/Badge.swift
struct Badge: View {
    let text: String
    var body: some View {
        // Implementation
    }
}
```

### Size Presets
Edit `presets.json` to add custom sizes:
```json
{
    "tiktok-vertical": {"width": 1080, "height": 1920}
}
```

### Template Metadata
Optional `metadata.json` for template info:
```json
{
    "displayName": "Minimal",
    "summary": "Clean typography layout"
}
```

## Build & Distribution

### Local Development
```bash
swift build
swift run maker init
```

### Release Build
```bash
swift build -c release
cp .build/release/maker /usr/local/bin/
```

### Package Distribution
Can be installed via Swift Package Manager or Homebrew (with formula).

## Architecture Decisions

### Why Runtime Compilation?
- Allows true SwiftUI templates without recompilation
- Templates can be edited without rebuilding CLI
- Enables LLM-generated templates

### Why JSON Parameters?
- Simple for non-developers to edit
- Easy to generate programmatically
- Works well with batch configs

### Why JPEG Output?
- Best compatibility with social platforms
- Good quality/size ratio
- Simpler than multi-format support