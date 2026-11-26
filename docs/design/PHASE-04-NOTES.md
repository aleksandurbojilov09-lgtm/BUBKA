# Phase 04 local draft — not an accepted PR

Baseline: `7b52f78a5861bd68411f364431d88240b27a7950` (main), full CI 45830140460. Approved design ZIP SHA-256 `c308a4abeeb4a0846fc4fa77339e190c01f185f6b9e8aafd5d6ee782dbeb074e`; 57 files, 44/44 manifest hashes and sizes verified. Source design JSON files are retained as documentation; no preview image or HTML is a runtime asset. The approved SVG body and lamp paths are ported to Canvas; lighting is a controlled approximation. No dependency or font is added to runtime. Original reference assets were AI-generated/assistant-authored; third-party license and trademark clearance is not asserted. Final rights review remains with architect.

## Implementation map
- `lib/design_system/`: theme, cards, buttons, fields, plate, empty state, ring model and Canvas painter, shared car painter.
- `lib/features/cockpit/presentation/`: shell, home, empty garage, fixture-only ChangeNotifier, ignition, visual review. Production has no vehicles or business store. Future routes are placeholders only.
- `lib/app/router/router.dart`: current GoRouter and diagnostics registry remain; real updater and module enable/disable UI move to Settings. Fixture access is gated by existing testing update channel (or explicit local test define), with a visible test banner and no SQLite access.
- Android and iOS launch backgrounds: black; Android 12+ may show the system icon.
- Fuel preview: liters, total odometer, optional total EUR, editable date defaults to today. No full/partial selector or history checkbox. Save disabled. No average consumption calculation.
- `PHASE-04-ROUTE-CONTRACT.json`: all 30 screen contracts; future paths proposed, not activated.

## Unresolved acceptance and design decisions
The source was prepared without Flutter/Dart in the authoring environment. Local format/analyze/test and actual Flutter render review must run before any push. Screenshot export tests are not approved golden baselines; no golden image may be accepted mechanically. Original AppBlocks are incomplete; visual fidelity to the approved PNG, road/lighting geometry and motion must be visually checked. Font used by screenshot export (if installed) is a test-only OS font, not a bundled production font; record SHA and review actual physical platform rendering. Resource ring 950 ms transition, other reference durations and detailed future form/status fixture coverage may need follow-up after the first actual render; no claim of completion. Android/iOS Monogram B production adaptation is withheld: the original includes an embedded rounded metallic frame which is clipped by some masks. Removing/redesigning it requires owner/architect review; original launcher resources are intentionally unchanged in this draft. Contact sheet is a mathematical mask simulation, not physical system screenshots. iOS and Android physical tests, performance profile, size delta, exact candidate CI and final rights review remain pending. No new services, database schema, package identity, signing, updater policy or notification policy changes intended. Verify actual diff and regression tests before asserting preservation.

Accessibility candidate: below 360 dp at large text scaling, navigation uses two rows with all four full labels and the quick action; normal layout remains unchanged. Visual and physical acceptance pending.

## BUBKA-004 visual correction v3 (local, acceptance pending)
- V02/V03: refined local Canvas geometry, lighting, graphite depth, card gradient, dashed garage CTA and quick icons; no external runtime assets. Exact visual fidelity and physical profile pending.
- V04/V06: measured navigation label width, adaptive rows, separate large-text resource labels and calendar singular form. Existing tests retained; additional tests cover calendar/km, fixture isolation, accessibility, landscape and fuel date.
- V05: A/B icon variants are review-only derivatives of the approved original; no native icon change. 108dp layers, 66dp safe zone, mask simulations only. Rights clearance and owner choice pending.
- V01: test-only DejaVu and MaterialIcons loaders retained. Screenshot typography differs from Android/iOS system fonts; physical tests pending. No new runtime dependency.
- Reference crops remove drawn system bars and phone frames; the 390-wide reference is shorter than the actual 390x844 test viewport. Neutral padding is documented, no aspect distortion.
- See https://docs.flutter.dev/ui/accessibility, https://docs.flutter.dev/ui/adaptive-responsive, https://api.flutter.dev/flutter/painting/TextPainter-class.html and https://developer.android.com/develop/ui/compose/system/icon_design_adaptive.

## BUBKA-004 V4
- Native car and beam paths transcribed from source SVG, not screenshot UI; Canvas gradients approximate SVG filter output; asphalt pattern/reflection not yet exact. Full native device/profile and design approval pending.
- Baseline pixel annotations use original 390x724 crop versus actual 390x844 Flutter, no height stretch. DejaVu is test-only.
- Native icon B uses approved V3 layers; iOS uses original opaque square. Provenance: project AI-generated owner-approved asset, rights clearance pending.
- Settings credit exact: Developed by A.Bozhilov.


## V5 local candidate
V5 integrates owner-approved DESIGN-003 reconstruction. Exact PNGs only; spec JSON versioned; DejaVu test-only, native font metrics may differ.


## BUBA rebrand
Only the BUBA wordmark and its reflection are derived from the accepted DESIGN-003 PNGs. Preserve original pixel geometry, canvas and reflection formula; all remaining design and native icons locked. Historical ASSET_MANIFEST and reference specs are unchanged. Current runtime provenance records both old and new SHA-256. No new design concept; native proof pending.
