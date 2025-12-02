# 💰 budget_app — Personal Finance & Budget Tracker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<strong>A polished, production-ready Flutter app for tracking expenses, managing budgets, and visualizing your finances.</strong>

[Features](#-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Tech Stack](#-tech-stack) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

budget_app is a comprehensive personal finance manager built with Flutter and modern best practices. It helps you record transactions, analyze spending, create budgets, and export professional reports — all with a clean, responsive UI and offline-first storage.

### 🎯 Highlights

- Clean Architecture (domain/data/presentation separation)
- Riverpod-based state management (reactive, testable)
- Local storage (Hive/SQLite) for fast offline access
- Modern Material 3 UI with theming and dark mode
- Analytics dashboards and charts (FL Chart / Syncfusion)
- Biometric authentication and local notifications
- Export to PDF/CSV, advanced filters, and search

---

## ✨ Features

### 💸 Transactions
- Add/edit/delete income and expenses
- Custom categories with color and icons
- Notes and optional receipt images
- Recurring transactions (daily/weekly/monthly/yearly)
- Unified quick-add modal from anywhere (FAB, nav, dashboard)
- Searchable category Autocomplete for faster selection
- Inline bottom sheet date picker for rapid date changes
- Two-decimal amount enforcement & keyboard optimizations

### 📊 Analytics & Insights
- Income vs Expense overview (monthly)
- Category breakdown with top spenders
- Recent activity and trends
- Multiple chart types and time ranges
- Memoized monthly & category totals (performance)
- Animated transaction list entries (smooth state feedback)

### 🎯 Budgets
 - Per-category or overall budgets
 - Real-time progress indicators
 - Alerts at thresholds (e.g., 80%)

### 🔐 Security & Utilities
- Biometric auth (Face ID / Touch ID / fingerprint)
- Local notifications and reminders
- PDF reports with charts, CSV export
- Multi-currency support
- Encrypted Hive box for transactions (secure local storage)
- PIN lock with timeout & improved back navigation handling

---

## 🏗️ Architecture

This app follows Clean Architecture principles to keep code scalable and testable.

```
lib/
├── core/                   # Core utilities and base classes
│   ├── error/              # Error handling
│   └── usecase/            # Base use case abstractions
├── data/                   # Data layer (models, repositories impl)
│   ├── models/
│   └── repositories/
├── domain/                 # Business logic (entities, repos, usecases)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/           # UI layer (providers, screens)
│   ├── providers/
│   └── ...
├── services/               # Device/services (DB, notifications, PDF)
└── utils/                  # Themes and helpers
```

Related docs in repo:
- IMPLEMENTATION_SUMMARY.md
- RECENT_UPDATES.md
- RECENT_UI_IMPROVEMENTS.md
- LATEST_FIXES_OCT15.md
- MONTHLY_SELECTION_ENHANCEMENT_OCT16.md

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+

### Setup
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run
```bash
flutter run
```

### Platform notes
- Web: `flutter run -d chrome`
- Desktop: Enable platform (Windows/Linux/macOS) in Flutter config

- Flutter 3 • Dart 3
- Riverpod 2.4+ for state management
- Charts: fl_chart, syncfusion_flutter_charts
- Auth/Notifications: local_auth, flutter_local_notifications, timezone
- Exports: pdf, printing, csv
- UI/UX: google_fonts, lottie, shimmer, animations
See `pubspec.yaml` for full dependency list.

---

## 🖼️ Screenshots

Add screenshots under `docs/screenshots/` and reference them here:

```
docs/
└── screenshots/
	├── dashboard.png
	├── analytics.png
	└── add_transaction.png
```

---

## 🧪 Testing

```bash
flutter test
```

### Planned / In Progress Enhancements
- Incremental aggregates stored in `AppState` for O(1) reads
- Pagination + `LazyBox` adoption for large data sets
- Attachments image compression & path storage
- Material 3 surface container theme refinements
- Advanced recurrence: skip-once & auto-catch-up logic
- Quiet hours for notification scheduling
- Provider, integration & golden tests expansion
- Minimal logging abstraction (replacing raw prints)

---

## �️ Roadmap

- Cloud sync
- Investment tracking
- ML-based spending insights
- Web dashboard

Track ongoing updates in the repo's markdown logs listed above.

### Recent Implementations
- Category Autocomplete
- Inline CalendarDatePicker sheet
- SliverList conversion with keep-alive
- Transaction item fade/slide animations
- Hive AES encryption (secure key via flutter_secure_storage)
- Memoized derived totals providers
- Quick-add tooltip on Transactions tab
- PopScope migration for lock screen

---

## 🤝 Contributing

Contributions are welcome! Please open an issue to discuss changes. Follow conventional commits where possible (e.g., `feat:`, `fix:`, `chore:`).

---

## � License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

---

<div align="center">

Made with ❤️ using Flutter

</div>
