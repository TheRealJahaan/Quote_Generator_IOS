# Inspire Me · Quote Generator for iOS

[![CI](https://github.com/TheRealJahaan/Quote_Generator_IOS/actions/workflows/ci.yml/badge.svg)](https://github.com/TheRealJahaan/Quote_Generator_IOS/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-informational)

A SwiftUI app that greets you with a quote of the day, serves fresh quotes from a live API (with an offline fallback), and lets you save the ones that stick. Accounts are handled by Firebase Authentication; favorites are stored on device with SwiftData.

## Features

- **Quote of the day**: the same quote for everyone on a given date, chosen deterministically from a curated collection.
- **Fresh quotes on demand** from the [DummyJSON quotes API](https://dummyjson.com/docs/quotes), never repeating the one on screen, with a history you can step back through.
- **Works offline**: if the network fails, the app quietly switches to 38 bundled quotes and says so.
- **Favorites**: save, search, copy, share and swipe-to-delete, scoped to the signed-in account.
- **Accounts**: sign up, sign in, password reset, sign out and in-app account deletion (required by App Store Review Guideline 5.1.1(v)).
- **Guest mode**: use everything without an account; favorites stay on the device.
- **Polish**: light and dark themes, haptics, Dynamic Type friendly layouts, VoiceOver labels, iPad support, keyboard focus flow between fields.

## Architecture

```
Quote_Generator/            App target (SwiftUI, Firebase, SwiftData)
├── App/                    Entry point, root navigation, preview helpers
├── Auth/                   Login, sign-up and reset screens + FirebaseAuthService
├── Quotes/                 Today screen and quote card
├── Favorites/              SwiftData model and favorites list
├── Settings/               Account, data and about
├── DesignSystem/           Gradient background, cards, buttons, form fields
└── PrivacyInfo.xcprivacy   Privacy manifest

Packages/QuoteKit/          Platform-independent core, fully unit tested
├── Quote, QuoteSource
├── RemoteQuoteService      DummyJSON client behind an injectable HTTPClient
├── BundledQuoteService     Offline collection
├── QuoteRepository         Remote first, offline fallback, no immediate repeats
├── DailyQuote              Deterministic quote-of-the-day (SplitMix64 over the date)
├── CredentialValidator     Email and password rules
├── Auth                    AppUser, AuthServicing protocol, AuthFailure, InMemoryAuthService
├── SessionModel            @Observable auth state machine (loading → signedOut ↔ signedIn)
└── QuoteFeedModel          @Observable state for the Today screen
```

The UI depends only on the `AuthServicing` protocol. The app injects `FirebaseAuthService`; tests and SwiftUI previews inject `InMemoryAuthService`, so every screen previews without a network or Firebase project. Firebase error codes are translated into `AuthFailure` values with human-readable messages in one place.

## Getting started

Requirements: Xcode 26 or later, iOS 17+ simulator or device.

```bash
git clone https://github.com/TheRealJahaan/Quote_Generator_IOS.git
cd Quote_Generator_IOS
open Quote_Generator.xcodeproj
```

Xcode resolves the Firebase package on first open. Pick the **Quote_Generator** scheme and press **Run**.

### Using your own Firebase project

The repo ships with the `GoogleService-Info.plist` for the author's Firebase project. To point the app at your own:

1. Create a project in the [Firebase console](https://console.firebase.google.com) and add an iOS app with bundle ID `com.jahaansuthar.quotegenerator` (or your own; change it under *Signing & Capabilities*).
2. Download its `GoogleService-Info.plist` and replace the one at the repository root.
3. In **Authentication → Sign-in method**, enable **Email/Password**.

### Running the tests

```bash
swift test --package-path Packages/QuoteKit
```

The same tests run from Xcode with **⌘U**, and on every push and pull request in GitHub Actions (Linux and macOS), alongside a full iOS Simulator build of the app.

## Shipping to TestFlight

1. In Xcode, select the **Quote_Generator** target → *Signing & Capabilities* and choose your team (the project is set to automatic signing).
2. Create the app record in [App Store Connect](https://appstoreconnect.apple.com) with the same bundle ID.
3. Choose **Any iOS Device**, then **Product → Archive**, and upload from the Organizer.
4. Bump `CURRENT_PROJECT_VERSION` for every upload.

Export compliance is pre-answered (`ITSAppUsesNonExemptEncryption = NO`), the app icon is opaque as App Store Connect requires, and the privacy manifest declares the email, name and user ID collected for account functionality.

## Tech stack

SwiftUI · Observation (`@Observable`) · SwiftData · Swift Concurrency · Firebase Authentication · Swift Package Manager · XCTest · GitHub Actions

## Credits

Quotes are attributed to their authors. Remote quotes are provided by DummyJSON.
