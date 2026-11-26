# Архитектура
## Одобрена цел
Flutter + Dart; modular monolith; feature-first; MVVM; Provider + ChangeNotifier; GoRouter; static module registry; SQLite + Drift; централизирана design system. Само локално съхранение и offline-first. GitHub + Codespaces + Actions + Releases; APK / IPA; SemVer.

## Реализирано във фаза 01
- `lib/main.dart`: входна точка, `runApp`, без бизнес логика.
- `lib/app.dart`: временен `WidgetsApp` екран; не е окончателен дизайн.
- `android/`, `ios/`: стандартни native Flutter проекти.
- `.devcontainer/`, `.github/workflows/ci.yml`, `scripts/`, `test/`: среда, CI, проверки на артефакти и smoke test.
- Няма база, модулен регистър, MVVM инфраструктура, маршрутизация или реални бизнес модули.

## Бъдеща структура (предложение за уточняване от архитект във фаза 02)
`lib/app/` — композиция и навигация; `lib/core/` — общи договори и инфраструктура; `lib/features/<module>/` — самостоятелни функционални модули; `lib/design_system/` — общи UI компоненти. В рамките на модулите разделяй data/domain/presentation само според необходимостта, без циклични зависимости. Това е план, не създадени директории.

Идентичност Android/iOS: io.github.aleksandurbojilov09.garage. Не се променя при смяна на търговското име.

## Фаза 02 — архитектурно ядро (кандидат за проверка)
`lib/app/` композира Provider, GoRouter и статичния регистър. `lib/core/database/` управлява една локална база с инжектиран executor. `lib/features/diagnostics/` демонстрира repository, ViewModel и View. `lib/design_system/` съдържа базова тъмна тема. Виж docs/database-policy.md.
