# PRO CALENDAR — Web/PWA Support Plan

## 1. Objective

Add web support to the existing PRO CALENDAR Flutter app so it can be deployed as a PWA on GitHub Pages or any static host.

## 2. Current Limitation

The app uses Drift with `dart:ffi` SQLite, which is unavailable on web. `flutter run -d chrome` fails with `dart:ffi` errors.

## 3. Solution: Drift Web Backend

Drift officially supports web via `drift_web`, which uses IndexedDB instead of native SQLite.

### 3.1 Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  drift_web: ^2.0.0
  flutter_web_plugins:
    sdk: flutter
```

### 3.2 Conditional Database Initialization

Create `lib/core/database/database_provider.dart`:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_web/drift_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'app_database.dart';

AppDatabase createDatabase() {
  if (kIsWeb) {
    return AppDatabase.forWeb();
  }
  return AppDatabase();
}
```

Update `lib/core/database/app_database.dart`:

```dart
// Add this constructor for web
AppDatabase.forWeb() : super(_openConnectionWeb());

LazyDatabase _openConnectionWeb() {
  return LazyDatabase(() async {
    // drift_web handles IndexedDB automatically
    return WebDatabase('fitness_trainer_db');
  });
}
```

### 3.3 Update main.dart

```dart
import 'package:fitness_trainer_app/core/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = createDatabase();
  runApp(ProviderScope(overrides: [
    Provider<AppDatabase>((ref) => db),
  ], child: const ProCalendarApp()));
}
```

## 4. PWA Configuration

### 4.1 Web Manifest

Create `web/manifest.json`:
```json
{
  "name": "تقویم حرفه‌ای",
  "short_name": "PRO CALENDAR",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#EFF2EA",
  "theme_color": "#88A36B",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 4.2 Update index.html

Add to `web/index.html`:
```html
<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#88A36B">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
```

### 4.3 Generate PWA Icons

Create placeholder icons in `web/icons/`:
- `Icon-192.png` (192x192)
- `Icon-512.png` (512x512)

## 5. Platform-Specific Considerations

### 5.1 File Paths
- Web: Use IndexedDB via `drift_web`
- Mobile/Desktop: Use native SQLite via `NativeDatabase`

### 5.2 SharedPreferences
- Already works on web via `shared_preferences_web`

### 5.3 Fonts
- Vazirmatn fonts must be declared in `pubspec.yaml` and will work on web

## 6. Testing

```bash
# Test web build
flutter build web

# Test locally
flutter run -d chrome

# Verify PWA manifest
# Open Chrome DevTools > Application > Manifest
```

## 7. Deployment to GitHub Pages

### 7.1 Build
```bash
flutter build web --base-href /fitness_trainer_app/
```

### 7.2 GitHub Pages Setup
1. Create `docs/` folder in repo
2. Copy `build/web/` contents to `docs/`
3. Enable GitHub Pages in repo settings
4. Set source to `docs/` folder

### 7.3 Alternative: gh-pages Branch
```bash
git subtree push --prefix build/web origin gh-pages
```

## 8. Implementation Steps

1. Add `drift_web` to `pubspec.yaml`
2. Create `database_provider.dart` with conditional initialization
3. Update `app_database.dart` with web constructor
4. Update `main.dart` to use `createDatabase()`
5. Create `web/manifest.json`
6. Update `web/index.html` with PWA meta tags
7. Add placeholder icons
8. Test on Chrome: `flutter run -d chrome`
9. Build web: `flutter build web`
10. Verify PWA installation in Chrome

## 9. Acceptance Criteria

- `flutter run -d chrome` compiles and runs without `dart:ffi` errors
- `flutter build web` succeeds
- App functions identically on web and mobile
- PWA manifest is valid and installable
- Data persists across browser sessions via IndexedDB

## 10. Out of Scope

- Service workers for offline caching (can be added later)
- Push notifications
- Advanced PWA features like file upload/download
