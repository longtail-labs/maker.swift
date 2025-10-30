# Maker Project Guide

## Quick Start (Mint)

```
# scaffold a new workspace in ./makers
mint run longtail-labs/maker.swift init --path makers

# list templates from repo root
mint run longtail-labs/maker.swift list --project makers

# render the example template
mint run longtail-labs/maker.swift render Example --project makers --output output/example.jpg

# run the sample batch config
mint run longtail-labs/maker.swift batch configs/example.json --project makers
```

## Quick Start (SwiftPM)

```
swift run maker init --path makers
swift run maker list --project makers
swift run maker render Example --project makers
swift run maker batch configs/example.json --project makers
```

### Notes
- `--project` defaults to the current directory; pass it when invoking the CLI from outside the project root.
- Paths you supply (params, templates, configs, output) are resolved relative to the project unless you pass an absolute path.

## Repository Layout

```
Sources/maker/
├── Commands/               # ArgumentParser subcommands
├── Models/                 # Codable structs shared by commands
├── Services/               # Preset loader, renderer, scaffold helpers
├── Utilities/              # Path helpers, DateFormatter extensions
└── Resources/Scaffold/     # Files copied during `maker init`
```

Generated workspaces (default `makers/`) contain:

```
makers/
├── templates/
│   └── Example/Template.swift
│       └── params/default.json
├── components/
├── configs/example.json
├── assets/
├── output/
├── presets.json
└── CLAUDE.md
```

## Template Authoring Cheatsheet

1. Create a folder under `templates/YourTemplate`.
2. Add `Template.swift` exporting a `Template` struct that conforms to `View`.
3. Define an inner `Params: Codable` and decode it inside `init(json:)`.
4. Use the injected globals `canvasWidth` and `canvasHeight` if needed.
5. Prefer composing shared SwiftUI code inside `components/` (global) or `templates/.../components/`.

Example skeleton:

```swift
import SwiftUI

struct Template: View {
    struct Params: Codable {
        let title: String
        let accentColor: String
    }

    let params: Params

    init(json: String) {
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(Params.self, from: data) {
            self.params = decoded
        } else {
            self.params = Params(title: "Fallback", accentColor: "#FF9500")
        }
    }

    var body: some View {
        ZStack {
            Color(hex: params.accentColor)
            Text(params.title)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

## Rendering Tips

- `maker render TemplateName --params custom --preset instagram-square`
- Use `--size 1200x628` for custom dimensions.
- Outputs are JPEG with a fixed compression factor of 0.95.
- For batch jobs, `paramsInline` lets you embed JSON objects directly in your config.

## Troubleshooting

- **Template not found**: ensure the `.swift` file exists or pass an explicit path; remember to add `--project` when running from outside the workspace.
- **Preset missing**: edit `presets.json` in the project root, then rerun `maker presets` to confirm.
- **Compilation errors**: the tool prints Swift compiler diagnostics from the generated temporary file (`/tmp/maker-render-*.swift`).

## Working with AI Assistants

- Share this `CLAUDE.md` to provide context quickly.
- Keep templates modular—complex views can be split into helpers under `components/`.
- Document param expectations alongside templates to reduce back-and-forth during automation.
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
