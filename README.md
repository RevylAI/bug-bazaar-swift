# Bug Bazaar (Swift)

A native SwiftUI port of [RevylAI/bug-bazaar](https://github.com/RevylAI/bug-bazaar) — the Expo/React Native sample app used for dogfooding Revyl flows against a real product shape: search, product detail pages, cart, checkout, and account state.

Like the original, it is a reference app for Revyl auth-bypass deep links.

**Proof of migration:** [docs/VALIDATION.md](docs/VALIDATION.md) — side-by-side screenshots of the React Native original and this port, captured on a Revyl cloud device session, including verification that both intentional demo bugs behave identically.

## Requirements

- Xcode 16+ (no external dependencies, no package manager)
- The `BugBazaar.xcodeproj` is committed; regenerate with [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`xcodegen generate`) only if you change `project.yml`

## Build

```bash
xcodebuild -project BugBazaar.xcodeproj -scheme BugBazaar \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build
```

The simulator app lands at `build/Build/Products/Debug-iphonesimulator/BugBazaar.app`.

With the Revyl CLI, build on a Revyl cloud runner instead:

```bash
revyl build remote --platform ios
```

## App Structure

```
BugBazaar/
├── BugBazaarApp.swift      # App entry, root navigation, deep link handling, tab bar
├── Router.swift            # Navigation state (tab, path, cart sheet)
├── Theme.swift             # Colors, spacing, fonts
├── Models/Product.swift    # Product catalog
├── Stores/
│   ├── CartStore.swift     # Cart + order state
│   └── AuthBypassStore.swift  # Revyl auth-bypass deep link handler
├── Components/             # Header, hero banner, filter chips, product cards, halftone overlay
└── Screens/                # Shop, Search, Specimens, Account, product/cart/checkout/order screens
```

## Auth Bypass Deep Link Sample

The handler lives in `Stores/AuthBypassStore.swift`, is wired via `onOpenURL` in `BugBazaarApp.swift`, and the Account tab shows idle, accepted, and rejected states — mirroring the original app.

Create the launch vars once:

```bash
revyl global launch-var create REVYL_AUTH_BYPASS_ENABLED=true
revyl global launch-var create REVYL_AUTH_BYPASS_TOKEN=revyl-demo-token
```

After the app is installed on a Revyl device session, send the auth link:

```bash
revyl device navigate \
  --url "bug-bazaar://revyl-auth?token=revyl-demo-token&role=collector&redirect=%2Fcheckout"
```

The deep link signs in as the Revyl test collector and routes to checkout. Allowlisted redirects: `%2Faccount`, `%2Fcart`, `%2Fcheckout`, `%2Fproduct%2F3`, `%2Fshop`.

Invalid tokens, non-allowlisted roles (e.g. `admin`), and non-allowlisted redirects are rejected, and the rejected state is visible on the Account tab.

Because this fixture reads `REVYL_AUTH_BYPASS_ENABLED` / `REVYL_AUTH_BYPASS_TOKEN` from the process environment and falls back to a demo token when absent, it stays runnable without launch vars while still showing where they fit.

## Parity Notes (vs. the React Native original)

- **Product data, copy, flows, and pricing logic** are identical, including cart/checkout math and the intentional demo bugs used for Revyl bug-hunting exercises (see `// BUG:` comments in `CartStore.swift` and `CheckoutView.swift`).
- **Colors** match the original theme exactly — including `stickerGreen`/`mangoOrange` resolving to the CSS named colors `blue`/`green`, as in the original `constants/theme.ts`.
- **Emoji** use the same bundled Twemoji PNGs (CC-BY 4.0).
- **Fonts**: the original uses Fraunces 900 + Courier; this port uses the system serif (New York) at black weight + Courier.
- **Navigation**: Expo Router stack/tabs/modal structure is reproduced with a `NavigationStack` over custom tabs, and the cart as a sheet.
