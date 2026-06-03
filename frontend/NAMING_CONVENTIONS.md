# Naming Conventions Policy

This Flutter frontend uses names that describe intent before implementation.

## Files

- Use `snake_case.dart` for Dart files.
- Keep routed pages in `lib/pages/`.
- Prefer one broad feature surface per file until the UI becomes large enough to split.

## Classes

- Use `PascalCase` for public widgets and route screens, such as `DashboardScreen`.
- Use a leading underscore for private implementation widgets, such as `_DashboardContent`.
- Name reusable UI pieces by role, not appearance: `_MetricCard`, `_DataPanel`, `_PageTitle`.

## Routes

- Use lowercase kebab-case paths: `/balance-sheet`, `/notifications`.
- Keep legacy compatibility routes only when needed, such as `/screen1` through `/screen4`.
- Route screen names should match the user-facing page: `SettingsScreen`, `ProfileScreen`.

## Constants

- Use lower camel case for private constants: `_primary`, `_border`.
- Group route labels in one place when labels are reused: `AppRouteNames`.

## UI Content

- Use clear financial/accounting labels.
- Keep rupee values formatted with `₹`.
- Use concise labels for navigation and page titles.
