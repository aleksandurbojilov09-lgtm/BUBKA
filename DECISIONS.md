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
