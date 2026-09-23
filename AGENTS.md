# AGENTS.md

## Overview
Flutter package for caching network files using `dio` and `hive`.

## Tooling & SDK
- **FVM**: Flutter SDK version managed via FVM (`.fvmrc` specifies `3.24.3`).
- **Command Prefix**: Always prefix Flutter/Dart CLI commands with `fvm` (e.g., `fvm flutter test`).

## Key Commands
- `fvm flutter pub get` — Fetch dependencies.
- `fvm flutter test` — Run unit tests.
- `fvm flutter pub run build_runner build --delete-conflicting-outputs` — Generate Hive type adapters (`lib/src/record.g.dart`).

## Conventions & Rules
1. Run `build_runner` after modifying Hive models (`lib/src/record.dart`).
2. Do not commit `.fvm/flutter_sdk`.
