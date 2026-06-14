# Testing

## Test Framework
- **Framework**: `flutter_test` (built-in Flutter unit and widget testing package).
- **Assertion library**: standard Dart matches (expect, find, pumpWidget).

## Run Commands
Run all unit and widget tests:
```bash
flutter test
```

Run a single specific test file:
```bash
flutter test test/widget_test.dart
```

## Structure & Mocking
- Test files are located in the `test/` directory, mirroring the structure of `lib/` where possible.
- Mocks and integrations can be added using the standard testing framework.

## Widget Testing Patterns
- Use `tester.pumpWidget()` to build and render the widget tree in a test environment.
- Use `find.byType()` or `find.text()` to verify UI elements are rendered correctly.
- Use `tester.tap()` to simulate user click/tap interactions.
- Always call `tester.pump()` or `tester.pumpAndSettle()` to handle animations and transitions.

---
*Date mapped: 2026-06-14*
