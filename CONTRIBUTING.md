# Contributing

Thanks for helping improve EchoType.

## Development Setup

Requirements:

- macOS 14 or newer.
- Xcode Command Line Tools.

Build:

```bash
swift build
```

Run:

```bash
swift run EchoType
```

Smoke tests:

```bash
swift run EchoTypeCoreSmokeTests
swift run EchoTypeRecorderSmokeTests
swift run EchoType --notify-smoke-test
```

Build a release artifact:

```bash
./scripts/build-app.sh
```

## Pull Requests

- Keep changes focused and easy to review.
- Add or update smoke tests when behavior changes.
- Update README or CHANGELOG when user-facing behavior changes.
- Do not commit API keys, local audio, transcript history, or generated `dist/` artifacts.

## Release Notes

Public releases use semantic version tags such as `v0.1.0`.
