# AGENTS.md

## Cursor Cloud specific instructions

### Platform: this is a macOS/Xcode-only iOS app

BugBazaar is a native **iOS SwiftUI** app defined solely by an Xcode project
(`BugBazaar.xcodeproj`, sources under `BugBazaar/`). There is **no** Swift Package
Manager manifest (`Package.swift`), no CocoaPods/Carthage, no unit tests, and no
lint/format/CI config in the repo.

The Cursor Cloud VM runs **Linux**, so **the app cannot be built, run, or
type-checked here.** `xcodebuild`, the iOS SDK, the iOS Simulator, and the
SwiftUI/UIKit frameworks are macOS-only Apple tooling. `swiftc -typecheck`/build on
Linux fails with `no such module 'SwiftUI'`. This is a hard platform limitation, not
a missing-dependency problem — no install script can make it buildable on Linux.

### How it is actually built/run (needs macOS)

- Standard build command lives in `README.md` and `.revyl/config.yaml`
  (`xcodebuild -project BugBazaar.xcodeproj -scheme BugBazaar ... -sdk iphonesimulator`).
  Run it on macOS + Xcode 16+, or open `BugBazaar.xcodeproj` in Xcode.
- `xcodegen generate` is only needed if `project.yml` changes (the `.xcodeproj` is
  committed).
- Cloud alternative: `revyl build remote --platform ios` runs the same `xcodebuild`
  on a **Revyl cloud macOS runner** — requires the Revyl CLI + Revyl account
  credentials (not installed/configured in this VM).

### Only local check possible on Linux (optional, best-effort)

A syntax-only parse of the Swift sources is the sole validation runnable on Linux.
Install the open-source Swift toolchain, then parse-only (does not load SwiftUI):

```bash
# one-time: download + extract the Linux toolchain (~840MB), then:
export PATH=/opt/swift/usr/bin:$PATH
for f in $(find BugBazaar -name '*.swift'); do swiftc -parse "$f"; done
```

This checks syntax only; it does **not** type-check or verify SwiftUI/iOS API usage.
The toolchain is intentionally **not** in the startup update script (it is heavy and
is not the app's real toolchain), so it must be reinstalled if needed.

### Deep-link auth-bypass note

The auth-bypass handler (`Stores/AuthBypassStore.swift`) reads
`REVYL_AUTH_BYPASS_ENABLED` / `REVYL_AUTH_BYPASS_TOKEN` from the environment and
falls back to the demo token `revyl-demo-token` when unset, so the app runs without
any launch vars.
