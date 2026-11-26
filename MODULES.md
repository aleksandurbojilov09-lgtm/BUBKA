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
