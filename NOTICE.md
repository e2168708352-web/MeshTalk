# NOTICE

MeshTalk is an independent fork. It is not affiliated with, endorsed by, or
sponsored by the bitchat project or its maintainers.

## Upstream projects

### bitchat (iOS / macOS)

- Source: <https://github.com/permissionlesstech/bitchat>
- License: Unlicense (public domain)
- Local license text: [`ios/LICENSE`](ios/LICENSE)
- MeshTalk changes: display name, bundle identifier, app group, URL scheme,
  keychain and queue identifiers, BLE service/characteristic UUIDs, Nostr event
  kinds, private-message prefix, relay source pinning, colors, typography,
  app icons, header branding, share text, and a Bluetooth authorization re-sync
  that rebuilds the CoreBluetooth managers when access is granted in Settings
  after the app already started without it.

The iOS source files retain their original copyright/license headers. The
Unlicense dedication continues to apply to the upstream portions; MeshTalk's
original branding assets and modifications are released under the same
Unlicense where possible.

### bitchat-android

- Source: <https://github.com/permissionlesstech/bitchat-android>
- License: GNU General Public License, version 3
- Local license text: [`android/LICENSE.md`](android/LICENSE.md)
- MeshTalk changes: application ID, version, BLE UUIDs, Nostr event kinds,
  private-message prefix, URL scheme, Wi-Fi Direct/Aware identifiers, removal of
  upstream APK download/update paths, relay source pinning, theme, icons,
  user-visible branding, and related tests.

Because the Android application is derived from GPLv3 code, the Android
application and its modifications are distributed under GPLv3. The complete
corresponding source is this repository. If you distribute a built APK, you must
also make the corresponding source available under GPLv3.

## Combined repository licensing

- `android/` and the combined Android APK: **GPL-3.0**
- `ios/`: **Unlicense**, except third-party dependencies which keep their own
  licenses
- Root [`LICENSE`](LICENSE): GPLv3 text, included because the distributed
  Android binary is a GPLv3 work

The two applications are separate programs with separate package/bundle
identifiers. The GPLv3 obligations for the Android application do not change
the Unlicense status of the independent iOS sources.

## Third-party components

The repository contains or depends on third-party software, including:

- Nordic Bluetooth LE libraries
- OkHttp
- Bouncy Castle
- Tink
- Arti / Tor
- swift-secp256k1
- LZ4 and other protocol dependencies

Their respective licenses apply. See the dependency manifests
(`android/app/build.gradle.kts`, `ios/Package.swift`,
`ios/Package.resolved`, and Gradle version catalogs) for the exact versions.

## Trademarks and assets

bitchat, its name, and its original icons are the property of their respective
owners. MeshTalk uses independently created icons, colors, and naming. No
upstream icon or store listing asset is included in the MeshTalk branding.

## Security and privacy

MeshTalk preserves the upstream protocol and cryptography. It has not undergone
an independent security audit. The network-namespace changes reduce accidental
discovery by official clients; they are not a substitute for a formal security
review. See `ios/SECURITY.md` and the Android security notes for upstream
reporting guidance, and do not report MeshTalk-specific issues to upstream
maintainers.

## No warranty

The software is provided "as is", without warranty of any kind. See the
applicable license text for the full disclaimer.
