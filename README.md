# BUBKA
Личен дигитален гараж за Android и iOS. Версия 0.1.0+2. Само локални данни; без акаунти, реклама, телеметрия, платени API, облачна база или синхронизация.

## Състояние
Фаза 01 е приета. Фаза 02: архитектурно ядро и диагностичен модул, два успешни пълни CI. Няма реални автомобилни функции. Фаза 03 изисква одобрение.

## Разработка
Отвори GitHub Codespaces (2 cores) на правилния клон. Devcontainer използва Ubuntu 24.04 и `.devcontainer/setup.sh`. При първоначално създаване прегледай Android SDK terms (https://developer.android.com/studio/terms); текущият setup приема SDK лицензите автоматично за вече далия съгласие собственик. Не използвай без съгласие. След инсталиране в нов терминал:

```sh
source "$HOME/.config/bubka/env.sh"
flutter doctor -v
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub --fatal-infos --fatal-warnings
flutter test --no-pub
```

Android локално: `flutter build apk --debug --no-pub`, след това `bash scripts/verify-android-apk.sh build/app/outputs/flutter-apk/app-debug.apk`. iOS: само на macOS с Xcode, `flutter build ios --release --no-codesign --no-pub`, след това `bash scripts/package-ios-ipa.sh`.

## CI и разпространение
`.github/workflows/ci.yml` класифицира промените, изпълнява общи проверки и при необходимост паралелни Android (ubuntu-24.04) и unsigned iOS (macos-26 ARM64) компилации. Артефактите се пазят 7 дни. Използвай GitHub Actions, за да изтеглиш ZIP с APK/IPA и SHA256SUMS.txt. Тестовият Android debug подпис не е окончателен; IPA не е директно инсталационен. Устойчиво подписване, актуализации и реално разпространение — фаза 03.

## Правила
Работи само по BUBKA, не по KMX. Не качвай лични данни, пароли, ключове или build артефакти в Git. Спирай Codespace при неактивност и проверявай остатъчните квоти. Виж AGENTS.md, ARCHITECTURE.md, PROJECT_STATE.json, ROADMAP.md, CHANGELOG.md, MODULES.md, DECISIONS.md, KNOWN_ISSUES.md и docs/handoffs/PHASE-01.json.

Последен пълен CI: https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45784294996. Артефактите са временни, няма публикуван Release.

## Фаза 02 — проверено ядро
Архитектурно ядро 0.1.0+2: локална SQLite/Drift, диагностичен модул, регистър, Provider/MVVM и GoRouter. Пълните CI проверки са зелени; приемането от архитекта предстои. Фаза 03 не е започната.
