# MBC — Membership Benefit Card

NFC-based membership card system for village cooperatives (koperasi desa).

## Requirements
- iOS 14.0+
- iPhone with NFC capability
- Xcode 16+
- XcodeGen

## Setup
```bash
brew install xcodegen
make generate
open MBC.xcodeproj
```

## Architecture
Clean Architecture (SwiftUI + MVVM)
- **Data**: Services (NFC, Crypto, Keychain), Serializer, Repository
- **Domain**: Models, UseCases, Utilities
- **Presentation**: ViewModels, Views (per feature)

## Design System
Local SPM package `MBCDesignSystem` — Signal Design System tokens (Telkomsel).
