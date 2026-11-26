# BUBKA release policy
- Phase 03 uses 0.2.0+3 and 0.2.1+4 testing prereleases. No phase 04.
- CI builds unsigned universal Android release APK and unsigned iOS IPA in parallel. A manual release from main consumes exact SHA successful full CI artifacts, signs Android in protected android-release environment, checks certificate and APK identity, then publishes new tag and assets. No secret is used by PR jobs. No overwrite of existing release/tag.
- Android system installer requires user confirmation and permission for this source; keep the existing app installed. Debug signature is incompatible with permanent release.
- iOS IPA requires personal signing through SideStore: https://docs.sidestore.io/docs/installation/install.html ; https://docs.sidestore.io/docs/faq . Initial computer setup, Apple Account and periodic 7-day refresh required. Never uninstall to update; verify effective bundle identity and record retention.
- Testing prereleases are only offered by testing channel; stable excludes them. The initial diagnostic build uses testing channel. No vehicle data or token sent to GitHub. Files checked for SHA-256 and size; Android verifies certificate, package, and increasing build before system installation.
- The owner's independent signing-key backup remains unverified. No paid resources are authorized.
- Physical install/update and runtime notification scenarios remain pending.

Phase 03 workflow permits testing releases only; stable publication is intentionally disabled until acceptance and a stable-channel build. The existing CI gate remains required. Release reuses full main CI artifacts without rebuilding.

Android release builds use scripts/build-android-release.sh with normal Flutter plugin regeneration and lockfile verification. Local Android release build and APK validation are required before advancing a correction for this build failure to the PR. Integration tests remain dev dependencies.
