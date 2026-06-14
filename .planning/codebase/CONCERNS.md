# Concerns

## Technical Debt & Areas of Concern

### 1. SDK Support Limits
- **Concern**: The project is constrained to Dart SDK `>=2.19.2 <3.0.0`.
- **Risk**: Newer versions of packages (like `mobile_scanner` or `macos_ui`) and newer Flutter SDK features cannot be used until the project's SDK constraint is bumped.

### 2. Camera Sandbox Permissions
- **Concern**: QR code scanning requires camera hardware access.
- **Risk**: If the application is distributed on the Mac App Store, App Sandbox entitlements must explicitly configure `com.apple.security.device.camera` to prevent quiet capture failures.

### 3. WiFi Automatic Connection Restrictions
- **Concern**: Triggering WiFi connection from a scanned QR payload.
- **Risk**: macOS sandboxing restricts direct WiFi configuration APIs. Automatic connection may require helper services, platform alerts, or clipboard fallback to copy-paste passwords.

### 4. Riverpod v3 Lifecycle & State Persistence
- **Concern**: Riverpod state management handles the current theme mode selection dynamically.
- **Risk**: Without persistent storage (e.g., `shared_preferences`), the theme switches back to system default on every app restart, hurting user experience.

### 5. macos_ui Deprecations & Future Flutter Upgrades
- **Concern**: Relying heavily on specific `macos_ui` design widgets.
- **Risk**: Rapid updates in the Flutter SDK framework often break custom canvas/rendering widgets, meaning updates to Flutter could require rewriting sidebar navigation.

---
*Date mapped: 2026-06-14*
