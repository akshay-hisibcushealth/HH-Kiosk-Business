# Contributing Guidelines

Thank you for your interest in contributing! This document outlines the process to help your contributions land smoothly.

## How to Propose Changes
1. Open an issue that describes your proposal or the bug you found.
2. Discuss the approach with maintainers if needed.
3. Fork the repository and create a branch named like `feature/short-description` or `fix/short-description`.

## Development Setup
- Use the latest stable Xcode (15+) and Swift toolchain.
- Resolve Swift Package dependencies via Xcode.
- Prefer Swift Concurrency (async/await) and SwiftUI conventions already used in the codebase.

## Coding Style
- Favor clarity and small, composable functions.
- Keep SwiftUI views declarative; extract helpers when they grow large.
- Add documentation comments for complex logic and public APIs.
- Use meaningful names for metrics and keys (e.g., `BP_SYSTOLIC`).

## Testing
- Add focused tests when possible (e.g., value scaling boundaries, risk bucket transitions).
- For UI changes, include screenshots or notes to aid review.

## Commit Messages
- Use imperative tone: "Add", "Fix", "Refactor".
- Reference issues when applicable: `Fixes #123` or `Refs #456`.

## Pull Requests
- Keep PRs small and focused.
- Describe the change, rationale, and any side effects.
- Include screenshots for UI changes.

## Code of Conduct
Please be respectful and inclusive. Harassment or discrimination of any kind is not tolerated.
