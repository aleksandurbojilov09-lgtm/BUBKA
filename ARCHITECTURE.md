# Архитектура
## Одобрена цел
Flutter + Dart; modular monolith; feature-first; MVVM; Provider + ChangeNotifier; GoRouter; static module registry; SQLite + Drift; централизирана design system. Само локално съхранение и offline-first. GitHub + Codespaces + Actions + Releases; APK / IPA; SemVer.

## Реализирано във фаза 01
- `lib/main.dart`: входна точка, `runApp`, без бизнес логика.
- `lib/app.dart`: временен `WidgetsApp` екран; не е окончателен дизайн.
- `android/`, `ios/`: стандартни native Flutter проекти.
- `.devcontainer/`, `.github/workflows/ci.yml`, `scripts/`, `test/`: среда, CI, проверки на артефакти и smoke test.
- Няма база, модулен регистър, MVVM инфраструктура, маршрутизация или реални бизнес модули.

## Структура, реализирана във фаза 02
`lib/app/` — композиция и навигация; `lib/core/` — общи договори и инфраструктура; `lib/features/<module>/` — самостоятелни функционални модули; `lib/design_system/` — общи UI компоненти. В рамките на модулите разделяй data/domain/presentation само според необходимостта, без циклични зависимости. Структурата е реализирана за диагностичния модул.

Идентичност Android/iOS: io.github.aleksandurbojilov09.garage. Не се променя при смяна на търговското име.

## Фаза 02 — архитектурно ядро (проверено в CI)
`lib/app/` композира Provider, GoRouter и статичния регистър. `lib/core/database/` управлява една локална база с инжектиран executor. `lib/features/diagnostics/` демонстрира repository, ViewModel и View. `lib/design_system/` съдържа базова тъмна тема. Виж docs/database-policy.md.

Автоматичните тестове проверяват CRUD, persistence, транзакции, FK, регистър, навигация и ViewModel. Миграционният тест е отделна SQL тестова схема, не production upgrade; schema v1 е експортирана. Бъдещият snapshot е политика, не реализирана функция. Статичната проверка на import граници не е пълен анализ на цикли.

## Phase 03 candidate
Local notification plan and snapshots in the backup-excluded private directory. Separate core updates transport, manifest, service, app controller and native platform adapter; no changes to production SQLite schema or application identity. Release signing separate from untrusted PR builds.

## Phase 04 local UI candidate (unverified)
Native presentation components and Canvas scene in design_system; feature-first cockpit presentation; existing GoRouter, Provider, module registry and diagnostics/updater preserved by design. Fixture model is in-memory only, gated by existing testing channel; no vehicle DB. See docs/design/PHASE-04-NOTES.md and route contract. Actual regression evidence pending.

## BUBKA-005 — current status (supersedes historical status)
Phase 04: released v0.3.0+5 on main 6deb3af3c3a9fce0c25dca10a521cd3bc508d574; CI 45905060610 and release 45907834477 successful. Phase 05 candidate: garage domain, local Drift repository and shared ChangeNotifier; cockpit consumes public garage interface. Schema v2 adds two tables only.
