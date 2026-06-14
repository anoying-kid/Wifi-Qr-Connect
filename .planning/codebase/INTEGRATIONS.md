# Integrations

## External Services & System Integrations

### Camera & Scanner
- **Plugin**: `mobile_scanner`
- **Purpose**: Integrates with the native macOS camera capture system to read barcode and QR code feeds in real-time.

### macOS Native Window API
- **Plugin**: `macos_window_utils` / `WindowManipulator`
- **Purpose**: Styles the window structure to match Apple design conventions:
  - Sets minimum window size to `800x600`.
  - Hides standard native titles and makes the titlebar transparent.
  - Enables full-size content view boundaries.

### Platform Alert System
- **Plugin**: `flutter_platform_alert`
- **Purpose**: Accesses AppKit's native modal alert window APIs to show alerts and confirmation dialogs.

### code-review-graph MCP Server
- **Implementation**: Exposes Tree-sitter codebase mapping tools to the Antigravity CLI via standard stdin/stdout JSON RPC (Model Context Protocol).
- **Hooks**: Automatically updates the knowledge graph database (`graph.db`) after code files are written or modified.

---
*Date mapped: 2026-06-14*
