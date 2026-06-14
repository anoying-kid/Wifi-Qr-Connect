# Conventions

## Coding Standards

### Dart & Flutter Patterns
- Prefer `const` constructors wherever possible to optimize UI rebuilding performance.
- Follow the rules defined in `analysis_options.yaml` (utilizing `flutter_lints` rules).

### UI Styling & Layout
- Replicate native Apple design conventions. Always wrap core screen layouts in `MacosWindow` with matching `Sidebar` and `ContentArea` setups.
- Use `TitlebarSafeArea` to prevent content from bleeding into the custom transparent title bar.
- Prefer `macos_ui` specific design controls over standard Material UI widgets to maintain platform consistency.

### State & Theme Management
- Use Riverpod providers (`ConsumerWidget`, `ConsumerStatefulWidget`, `ref.watch()`) to propagate theme changes and application state.
- Determine the current theme mode dynamically using the `themeProvider` value and context helpers.

### File & Class Naming
- File names must be written in `snake_case` (e.g., `theme_provider.dart`).
- Class names must use `PascalCase` matching their file purpose (e.g., `ThemeProvider`).

### Import Guidelines
- Group imports logically:
  1. Flutter core packages (`package:flutter/...`)
  2. External dependencies (`package:macos_ui/...`)
  3. Internal file paths (`package:qr_wifi_connect/...`)

---
*Date mapped: 2026-06-14*
