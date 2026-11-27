# Регистър на модулите
## Реализирани
Няма бизнес модули. Bootstrap: lib/main.dart и lib/app/bootstrap.dart; обвивка lib/app/app.dart. Техническа инфраструктура: devcontainer, CI, native проекти, smoke test и скриптове за верификация.

## Планирани (не са реализирани)
| Модул | Фаза |
|---|---|
| Архитектурно ядро, локална база и регистър | 02 |
| Инсталиране и актуализации | 03 |
| Централизирана design system | 04 |
| Автомобили / дигитален гараж | 05 |
| Гориво и километраж | 06 |
| Гражданска отговорност, винетки, ГТП, данъци и напомняния | 07 |
| Ремонти, масло, филтри и поддръжка | 08 |
| Опционални официални справки | 09 |
| Статистика и анализи | 10 |
| Архивиране и оптимизация | 11 |
| Финални проверки | 12 |

Таблицата е план; runtime регистърът по-долу е реализиран.

## Runtime registry — фаза 02
`diagnostics`: технически модул, ID diagnostics, маршрут /diagnostics; наличността се съхранява локално, без изтриване на данни. Няма реални автомобилни модули.

## Phase 03 — implementation pending validation
`core/notifications`: local calendar reminders, stable integer IDs, local JSON plan, platform adapter, nearest 60 on iOS; diagnostic controls. `core/updates`: version and manifest validation foundation. No business modules.

`core/updates` includes transport, manifest, daily/manual checks, checksum-verified downloads, Android system installer and iOS share flow. Testing channel is temporary for phase 03; stable channel excludes prereleases. All pending physical verification.

## Phase 04 candidate
`design_system` shared UI; `features/cockpit` presentation-only shell and visual fixtures. No new business modules, SQLite tables or runtime persistence. Existing diagnostics module remains in registry; updater in Settings. All 30 contracts in docs/design/PHASE-04-ROUTE-CONTRACT.json.

## BUBKA-005 — current status (supersedes historical status)
Phase 05 candidate: garage is an always-available business feature on existing /garage route (not a disableable diagnostics module). Stable integer vehicle IDs; local active choice; home observes shared state. No fuel, maintenance or document history tables yet.

## BUBKA-006 candidate
/fuel: always available, uses active garage vehicle. History, odometer and estimated consumption; core OdometerReader for future service. No service screen or reminders in this phase.

## Phase 06 UI correction candidate
Fuel overview limited to three fills; complete vehicle-scoped history remains accessible. Shared OdometerReader and existing standalone records remain intact. No servicing module yet.
