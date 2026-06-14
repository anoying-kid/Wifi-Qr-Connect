# Tech Stack

## Core Technologies
- **Language**: Dart (SDK version `>=2.19.2 <3.0.0`)
- **Framework**: Flutter (for desktop application development)
- **State Management**: `flutter_riverpod` (Riverpod version `^3.0.1` for state and theme management)
- **UI System**: Native macOS styling via the `macos_ui` package (`^2.2.0`)

## Key Libraries & Dependencies
- **`mobile_scanner` (version `^7.0.1`)**: Used to read/decode QR codes via camera.
- **`pretty_qr_code` (version `^3.5.0`)**: Used to generate high-fidelity, customized QR codes.
- **`flutter_platform_alert` (version `^0.8.0`)**: Displays native macOS alert dialogues.
- **`macos_window_utils`**: (transitive or embedded utility) Used via `WindowManipulator` to style transparency, hide titles, and apply full-size content views.

## Target Execution Environment
- **Target OS**: macOS 10.15+ (AppKit compatibility layer).
- **Visuals**: Fully optimized for macOS 14+ Sonoma/Sequoia native translucent window designs.

## Local Analysis Tools
- **Tree-sitter**: Powers structural indexing for `code-review-graph`.
- **Linter**: `flutter_lints` version `^6.0.0` integrated into VS Code or custom terminal compilers.

---
*Date mapped: 2026-06-14*
