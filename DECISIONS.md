# Технически решения — фаза 01
- Flutter 3.50.1 stable (commit ae9b586f34a8443573f82ef57c3bf914a908cbf7), Dart 3.14.0; SDK архивът се проверява със SHA-256. Dart идва с Flutter. Пакетите са фиксирани чрез pubspec.lock.
- Java 17: Codespace 17.0.21.1 (Ubuntu), CI 17.0.21. Gradle 9.5.0; AGP 9.3.1; Kotlin Gradle plugin 2.4.20 (вграденият Gradle Kotlin е 2.3.20, различен компонент).
- Android platform/compile/target API 36, min API 24, Build Tools 36.0.0, NDK 28.2.13676358; command-line tools 22.0 в Codespace. Ubuntu 24.04 стандартен runner. Тестов APK с CN=Android Debug.
- macos-26 стандартен ARM64 runner, наблюдаван macOS 26.7.2, Xcode 26.6 (17F113), iPhoneOS26.5.sdk (SDK product version 26.5.1). `flutter build ios --release --no-codesign` и ZIP Payload/Runner.app. Няма provisioning profile или дистрибуционен подпис. iOS минимум според Flutter: 15; реална инсталация не е проверена.
- Постоянна идентичност io.github.aleksandurbojilov09.garage; версия 0.0.1+1. Публичното repo е създадено от собственика. CI `contents: read`, checkout без запазване на credentials, actions фиксирани с commit SHA, concurrency и timeout. Артефакти 7 дни.
- CLI analytics са изключени. Няма cloud/app backend. Базовите runner образи и JDK patch версии могат да се обновяват.
- Flutter template material_ui не се използва в WidgetsApp и е премахнат в документационната стъпка; повторната пълна CI проверка е успешна.
- Успешен проверен код преди документационната стъпка: 1734430b421512eaf154fe7c0602b3ad6fdc53b5; CI: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45773199863. APK 142107594 bytes; IPA 5636512 bytes (размери на самите файлове от логовете, не на ZIP артефактите).
- Без допълнителни платени услуги; потребителят има съществуващ GitHub Pro. Billing: $0 допълнително потребление и блокирани платени бюджети за Codespaces/Actions по снимките на собственика; idle timeout 30 минути за нови Codespaces, потвърден от собственика.

## Източници
https://docs.flutter.dev/install/archive
https://docs.flutter.dev/reference/supported-platforms
https://docs.flutter.dev/deployment/android
https://docs.flutter.dev/deployment/ios
https://developer.android.com/build/releases/agp-9-3-0-release-notes
https://docs.github.com/en/actions/reference/runners/github-hosted-runners
https://docs.github.com/en/billing/reference/product-usage-included
https://docs.github.com/en/codespaces/setting-your-user-preferences/setting-your-timeout-period-for-github-codespaces
https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45773199863

## Финални решения
- Последен напълно проверен source SHA: 148b68ac6b67e5d67821bbdc3e1f124e0184e68f; CI: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45774920131. APK 142101073 bytes, IPA 5633546 bytes.
- Full Rebuild изпълнен; Flutter и Android toolchain проверени в новия контейнер. Съществуващ терминал може да изисква source на env.sh. Не повтаряй rebuild без основание.
- Оптимизацията на CI е задължителна задача за следващия одобрен етап; виж AGENTS.md.
- Финалният документационен commit е различен от source SHA; build входовете са идентични. Тагът v0.0.1 обозначава финалния документационен commit след проверка на diff, без нова компилация само за текста.

## Фаза 02 — решения и проверка
Използваме standalone material_ui, GoRouter, Provider и Drift native. Flutter архивът в CI се проверява със SHA-256 при всяко разархивиране, включително cache hit. PR се проверява на точния head SHA; push на main и ръчен full CI са налични. Фазовият PR включва общи архитектурни промени и изисква двете компилации. Версията се извлича от pubspec.yaml.

Пълният CI на точния source SHA е успешен два пъти (PR 571 s, main 560 s; baseline 447 s). Android и iOS стартират паралелно. Linux Flutter/Pub кешовете са възстановени в Android job, Gradle и macOS кешовете са записани, но повторното им възстановяване не е наблюдавано. Няма измерен изцяло warm run; не е доказано ускорение. Не се стартира излишен пълен build.
Проверен source SHA: e09d29f1562ca56d42ceec5328c233042c5ec51d; PR CI: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45782729262; main CI: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45784294996. Версия 0.1.0+2. APK 168598167 bytes, IPA 7796559 bytes. Fast-forward към main без промяна на source SHA. Следващият commit е само документация и не изменя build входовете.

Реалният docs-only CI е успешен за 31 s: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45785774552. Спрямо baseline 447 s това е 93.06% по-кратко време за документация, не за пълен build. Финалният таг е планиран за последния документационен commit след неговия docs-only gate.

## Фаза 03 — начало
- Архитектурно приемане: фаза 02 accepted_with_followups; фаза 03 authorized; фаза 04 not authorized.
- Потвърден main и tag v0.1.0: c5fa13e0b6be87e341249f117e1e96559e200d17. Пълен CI на e09d29f1562ca56d42ceec5328c233042c5ec51d (45784294996); docs-only CI на c5fa13e0b6be87e341249f117e1e96559e200d17 (45786033755). Diff между тях е само документация.
- Работен клон phase/03-installation-updates. Защитата на main липсва при началната проверка; integration получава 403 при административния protection endpoint. Изисква се настройка от собственика, после верификация; без merge преди успешен BUBKA CI gate и потвърдена защита.

- На 26.11.2026 собственикът активира ruleset 28151743. Потвърдено чрез GitHub API: active, default branch, deletion, non_fast_forward, PR с 0 approvals, strict required BUBKA CI gate от GitHub Actions (15368), без bypass actors; main protected=true. Началният docs-only PR CI 45786928579 е успешен.

- Android release certificate SHA-256: `a431369f4e84aebe18c87de7630bd364d248153e537251a8dfd0501de30d85f0`. Owner terminal evidence confirms PKCS12 key creation and two environment secrets in android-release, with custom main branch deployment policy. Owner authorized CI secrets. Independent off-Codespace backup is not verified. Build unsigned release APK, then sign only in protected release job, using apksigner and checking the pinned certificate. Debug CI remains diagnostic until release pipeline is integrated.

- Owner requested grouped work, not a full build after each small change. Prepared one staging branch and local preflight; advance PR once after local validation. CI produces unsigned release APK and IPA; signing and publication reuse full main CI artifacts. Phase 03 publishes only testing prereleases.

## BUBKA-003A — candidate pending CI
Adopt PR-Lite → trusted full main CI → artifact-only explicit release. Retain sequential Common checks before parallel platforms, pinned SDK/actions and build scripts to avoid risk and additional runner work. Exact synthetic merge checkout, conservative classification of all commits, same-attempt artifact provenance, SHA-256 verification. No app version change or new publication for infrastructure. Historical baseline PR 537s, main 588s, release 71s; ordinary PR-Lite projected 160–180s, total 819–839s, not measured. A CI policy change itself requires full PR and full main checks if merged.

## BUBKA-004 local design decisions (not yet accepted)
Use current material_ui, Flutter Canvas/CustomPainter, no new dependencies. Preview gated by current testing channel, no DB writes. Separate real resource from demonstration values; no full-to-full calculation or historical checkbox. Android/iOS black launch; retain current launcher assets pending approval of removal/adaptation of the pre-rounded icon border. Exact visual/performance results pending. See docs/design/PHASE-04-NOTES.md.

## BUBKA-004 V4 — owner/architect decisions
- Android launcher: approved variant B, inner metallic ring, 108dp adaptive layers; original opaque square identity for iOS, no pre-mask. Physical mask verification pending.
- Settings → За приложението: exact credit `Developed by A.Bozhilov`. Not part of Cinematic Ignition.
- V3 visual acceptance rejected. V4 local correction only, no commit/push/PR/merge/release/phase 05.


## V5 local candidate
DESIGN-003 reconstruction owner-approved; V5 uses exact local PNG layers, shared car 137x72, native ring/surfaces, four tiles at 390dp/1.0; system fonts. Final rights clearance pending.


## BUBKA → BUBA (26.11.2026)
Собственикът избра BUBA (Буба) само като потребителски бранд. V5 Final Polish е одобрен преди преименуването. Техническите идентификатори и договори остават BUBKA; wordmark и отражението запазват 540×102 canvas и оригинални буквени пиксели/blur, без външен шрифт. Иконите и останалите 28 PNG не се променят. Окончателна проверка на търговски марки и права не е доказана. Публичен push изисква изрично решение на собственика и архитекта.


## BUBA-004-PR-AUTHORIZATION (26.11.2026) — актуално решение
Собственикът одобри BUBA render и публичния push с остатъчен риск; архитектът прие тесния rebrand diff. Одобрен архив SHA-256: `33a636586c2d049c3943afdf180552f01b86c0ed80b6474de3c0601e3ae9fc96` (119 source files). Rights review: preliminary_not_legal_clearance; не е правно разрешение. Този мандат отменя само предишния STOP за изчакване на одобрението, включително в историческия AGENTS.md. След live preflight PASS: един commit/push/PR и задължителен CI. Без merge, tag, release, version bump или фаза 05. Публикувана 0.2.1+4; кандидат 0.3.0+5. Техническите BUBKA договори остават.

## BUBKA-005 — current status (supersedes historical status)
BUBKA-005: additive v1→v2 migration; vehicle ID auto-increment, unique normalized registration, active selection singleton foreign key. Stable garage order by ID. Original manually curated offline catalog; free text always available. New version 0.4.0+6 candidate only. No signing/notification/update changes.

## BUBKA-005A
BUBKA-005A: no schema or automatic legacy rewrite. Registration validation is format-only; cross-mode duplicate identity uses visual letter equivalents and strips separators.
