# MBC (Membership Benefit Card)

Offline NFC-based membership card system for iOS. Supports member registration, balance top-up, check-in/check-out with tariff calculation, and PIN authentication.

## Requirements

- Xcode 16.0+
- iOS 14.0+ (physical device required for NFC)
- Swift 5.9
- Ruby 3.3+ (for Fastlane)

## Setup

### 1. Install tools

```bash
brew install xcodegen swiftformat swiftlint
gem install bundler
bundle install
```

### 2. Firebase configuration

Replace `MBC/Resources/GoogleService-Info.plist` with your own Firebase project's `GoogleService-Info.plist`.

> This file is gitignored with a placeholder. You must provide your own for Firebase Analytics and Remote Config to work.

### 3. Generate Xcode project

```bash
xcodegen generate
```

### 4. Open and run

```bash
open MBC.xcodeproj
```

Select a physical device (NFC is not available on Simulator) and run.

## Architecture

Clean Architecture (SwiftUI + MVVM), structured as:

```
MBC/
├── App/            # Entry point, DI providers
├── Data/           # Services (NFC, Crypto, Keychain, Firebase), Repository
├── Domain/         # Models, UseCases, Utilities
└── Presentation/   # ViewModels, Views (per feature)

MBCDesignSystem/    # Local SPM package (Signal Design System tokens)
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| Firebase iOS SDK | 11.12.0 | Analytics, Remote Config |
| MBCDesignSystem | local SPM | Design tokens, UI components |

## Commands

```bash
# Generate project
xcodegen generate

# Run tests
bundle exec fastlane unit_tests

# Lint
swiftlint lint --strict
swiftformat . --config .swiftformat --lint

# Format
swiftformat . --config .swiftformat
```

## NFC Notes

- Requires physical device with NFC capability (iPhone 7+)
- Add `Near Field Communication Tag Reading` capability in Signing & Capabilities
- `NFCReaderUsageDescription` is set in Info.plist
- Card data is encrypted with AES-256-GCM + HMAC-SHA256 integrity
