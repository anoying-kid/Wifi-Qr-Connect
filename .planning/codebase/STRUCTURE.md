# Structure

## Directory Layout

```
Wifi-Qr-Connect/
├── pubspec.yaml                   # Project dependencies and configurations
├── analysis_options.yaml          # Linting rules for Dart/Flutter
├── lib/
│   ├── main.dart                  # Application entry point & window utils setup
│   ├── core/                      # Shared resources and utilities
│   │   ├── constants/             # Global routing constants
│   │   ├── utils/                 # Dark/light mode theme selectors
│   │   └── widgets/               # Reusable custom UI components (e.g. MacosCard)
│   └── presentation/              # App presentation logic
│       ├── pages/                 # UI screens (home, scanner, wifi QR generator)
│       ├── provider/              # Riverpod theme toggles
│       └── router/                # Router path handlers
├── test/
│   └── widget_test.dart           # Widget integration tests
├── .code-review-graph/            # Local Tree-sitter knowledge database (graph.db)
└── .gemini/                       # AI workspace hooks, settings, and custom skills
```

---
*Date mapped: 2026-06-14*
