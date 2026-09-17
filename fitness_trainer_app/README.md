# PRO CALENDAR (تقویم حرفه‌ای)

Personal Trainer Management App built with Flutter.

## Features

- Client management with tags
- Plan templates and active plans tracking
- Attendance tracking with Jalali (Persian) calendar
- Dashboard with statistics
- PWA support for web deployment

## Getting Started

### Prerequisites

- Flutter SDK 3.13.2 or higher
- Dart SDK 3.13.2 or higher

### Installation

```bash
flutter pub get
flutter run
```

## Web / PWA Build

### Build for web

```bash
flutter build web --base-href /PRO-CALENDAR/
```

The built web app will be in `build/web/`.

### Deploy to GitHub Pages

1. Push the `build/web/` contents to a `gh-pages` branch, or
2. Use GitHub Actions with the following workflow (`.github/workflows/deploy.yml`):

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.13.2'
      - run: flutter pub get
      - run: flutter build web --base-href /PRO-CALENDAR/
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

3. In your repo Settings → Pages, set Source to `gh-pages` branch.

### Run locally on Chrome

```bash
flutter run -d chrome
```

Data persists via IndexedDB on web and SQLite on mobile/desktop.

## Running Tests

```bash
flutter test
```
