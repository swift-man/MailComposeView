# Changelog

## [1.0.0] - 2026-06-25

### Added

- Added `MailComposeView`, a SwiftUI wrapper for `MFMailComposeViewController`.
- Added `MailDraft`, `MailAttachment`, and `MailComposeResult` public API models.
- Added `.unavailable` completion handling for devices or platforms where mail composition cannot be presented.
- Added Swift Package Manager support for iOS 13+ and macOS 10.15+ builds.
- Added XCTest coverage for draft storage, attachment storage, unavailable state handling, and fallback availability.
- Added DocC documentation generation and deployment to `swift-man/docs`.
- Added README badges, usage examples, ReviewBot exclusions, and GitHub Actions CI.
