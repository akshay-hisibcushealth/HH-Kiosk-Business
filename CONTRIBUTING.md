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

## Payload encryption and local API credentials

The November 2026 payload contract is implemented in `PayloadEncryption`,
`PayloadKeyStore`, and `AppURLSessionClient`. Public keys are fetched from the
configured API's `/api/security/payload-keys/`; only the entry matching
`current_kid` is used. The original JSON goes inside a new encrypted envelope for
each request. Success bodies require `X-Payload-Encrypted: 1`; errors remain JSON.
Only a 400 with `error: "Invalid encrypted payload"` refreshes keys and retries
once, with a fresh ephemeral key and nonce.

The current B2B app saves demographics and scan results through
`/custom-facescan/save/`, using `X-Public-Client-Key` and `X-Encrypt-Inner: 1`.
It no longer sends a separate report-email request. Two seconds after a
successful save, the visible results screen shows a save-confirmation toast
for four seconds. Leaving the screen or loading another result cancels it.
Dedicated kiosk save/email routes use a separately
provisioned `X-Kiosk-Key`. Do not substitute one credential for the other. NPS
(`/custom-kiosk-user-response/`) sends ordinary JSON with `X-Kiosk-Key`.

`GET /kiosk-anura-credentials/` sends `X-Kiosk-Key` with no request body.
Its success response uses the separate `kiosk-anura-v1` / `AES-256-GCM`
envelope. `KioskAnuraEncryption` derives a 32-byte AES key using HKDF-SHA256
from the exact UTF-8 kiosk key sent in the header, salt `kiosk-anura-v1`, and
info `HibiscusKioskAnuraV1`. It verifies AAD `kiosk-anura-v1|AES-256-GCM`,
a 12-byte IV, and a 16-byte tag, all using unpadded base64url. The client
decrypts before decoding `licenseKey` and `studyId`; the content service rejects
empty credentials before the SDK receives them. Plaintext success responses
and invalid envelopes are rejected. This GET does not fetch public payload keys
or require the face-scan POST's `X-Payload-Encrypted` response header.
The welcome screen uses bundled images and local strings without fetching
content or preloading remote images. Dashboard and weather API clients have
been removed.
Signed-in routes require a raw JWT from an
injected `credentialProvider`; this kiosk has no user-login flow, and never
uses an API key as a JWT. Payload encryption does not replace HTTPS or login.

Store an environment's credential locally using the hidden prompt:

```bash
bash Scripts/store-payload-credential.sh coremobileapistaging.hibiscushealth.com X-Public-Client-Key
```

The value is kept in macOS Keychain under service
`com.hibiscushealth.kiosk.payload-build`, with account `HOST|HEADER`. It is never
written to Swift, an xcconfig, Info.plist, a shared Xcode scheme, or shell history.
Use the same command with `X-Kiosk-Key` for the supplied kiosk/Anura credential.
`KIOSK_ANURA_API_KEY` is also accepted as a local-only Keychain entry to retain
the backend's original name; the build exports the separately stored
`X-Kiosk-Key` entry. `PUBLIC_CLIENT_KEY` is stored as `X-Public-Client-Key`.
Changing/rotating the credential requires storing its new value and rebuilding.

The Xcode provisioning phase reads the Keychain and generates
`PayloadCredentials.plist` directly in the built app, with owner-only local
permissions. Runtime credentials are imported into the existing device-only
iOS Keychain, scoped by HTTPS origin. The generated resource and build products
are ignored by Git. A new clone/build machine must provision its own Keychain;
missing credentials produce a build warning and a clear runtime error.

The signed app/archive necessarily contains the bootstrap credential. Keychain
storage protects the local source workflow and runtime storage, but does not
make a shared key in a distributed app unextractable. Stronger device identity
would require backend-issued credentials or managed device provisioning.
User-script sandboxing is disabled for the app target so the provisioning phase
can access macOS Keychain. API logging omits bodies, headers and query strings.
No custom TLS pin was invented; URLSession retains system certificate validation.

`AppConfig.baseURL` selects the environment and must currently be a literal HTTPS
URL so the build phase can choose the matching Keychain entry. The user's staging
configuration is preserved; there is no fallback to another environment's key.

Run the offline crypto/network regression suite:

```bash
bash Tests/run-payload-encryption-tests.sh
```

It includes an independent Python/OpenSSL known-answer vector, encrypted round
trips, current-key selection, rotation/retry, authentication routing, plaintext
GET/NPS behaviour, kiosk Anura credential decryption, response tampering, and
credential/origin isolation. It uses
test credentials only and never sends a real scan or email.

## Commit Messages
- Use imperative tone: "Add", "Fix", "Refactor".
- Reference issues when applicable: `Fixes #123` or `Refs #456`.

## Pull Requests
- Keep PRs small and focused.
- Describe the change, rationale, and any side effects.
- Include screenshots for UI changes.

## Code of Conduct
Please be respectful and inclusive. Harassment or discrimination of any kind is not tolerated.
