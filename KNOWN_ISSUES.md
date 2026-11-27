# Известни проблеми и ограничения
- Поправени: първоначален deprecated material.dart import; lipo -verify_arch аргументи в iOS пакетиране. Зеленият CI потвърди корекциите.
- APK е debug с временен подпис; подписът на отделни машини може да се различава. Не използвай като постоянна инсталация с ценни данни; фаза 03 осигурява устойчив ключ и стратегия за миграции. IPA без дистрибуционен подпис не се инсталира директно.
- Не са тествани физически телефони. Артефактите изтичат след 7 дни. Не са публикувани GitHub Releases.
- Codespaces първоначалната ръчна инсталация е потвърдена; Full Rebuild и Flutter/Android toolchain са проверени; idle timeout 30 минути за нови среди е потвърден от собственика. При вече отворен терминал може да е нужно source на env.sh. setup.sh автоматично приема Android SDK лицензи при rebuild, предназначено за собственика с вече дадено съгласие; преди използване от друг човек е нужно собствено съгласие.
- Flutter doctor отчита липсващи Chrome и Linux desktop инструменти; те са извън обхвата. Xcode не работи в Linux Codespace.
- AGP 9.3.1 има документиран lint проблем с JDK 17; не се прояви в задължителния CI. Не сменяй версии без основание и тестове.
- Лицензите на локално разрешените hosted пакети са инвентаризирани в docs/dependency-licenses.txt; правен преглед/пълна проверка на лицензи на всички native toolchain компоненти не е извършена.
- Снимките от Billing показват $0 допълнително потребление и блокирано платено потребление; точният остатък от квотата не е установен. Не активирай платени ресурси. Бюджетът е 0 EUR допълнителни разходи, извън съществуващия GitHub Pro.
- Финалният CI след премахване на неизползваната зависимост е успешен. Това описва състоянието в края на фаза 01; виж актуалните резултати по-долу.

## Фаза 02 — незавършени проверки
Двата пълни CI са зелени. Пълният CI на точния source SHA е успешен два пъти (PR 571 s, main 560 s; baseline 447 s). Android и iOS стартират паралелно. Linux Flutter/Pub кешовете са възстановени в Android job, Gradle и macOS кешовете са записани, но повторното им възстановяване не е наблюдавано. Няма измерен изцяло warm run; не е доказано ускорение. Не се стартира излишен пълен build. Постоянният setup е актуализиран, но не е правен нов Full Rebuild. Android debug/unsigned IPA не са окончателно подписани.

Не са проверени ръчен workflow_dispatch, runtime backup exclusions, интеграционен тест на устройство, пълна Drift schema migration verification и реализиран snapshot. Не е извършен повторен Full Rebuild. Точният текущ Billing не е достъпен; не са активирани платени ресурси.

Документационният CI е потвърден: 31 s, общите Flutter проверки и двата build jobs са правилно пропуснати, финалният gate е зелен. https://github.com/aleksandurbojilov09-lgtm/BUBKA/actions/runs/45785774552

## Фаза 03 — начални блокери
- Main няма branch protection/ruleset при началната проверка; административният endpoint отказва достъп на GitHub integration (403). Защитата не е активирана от изпълнителя.
- Постоянен Android ключ, подписан release, iPhone signing, известия, snapshots и физически upgrade тестове предстоят. Текущ Billing не е потвърден. Фаза 04 не е започната.

- Блокерът за branch protection е отстранен: ruleset 28151743 е активен и проверен чрез API. Административните промени продължават да изискват собственика.

## Phase 03 grouped candidate
- Candidate includes update transport, Android installer, iOS share flow, release workflow, and notification scheduling; no final CI or physical installation has validated this batch yet. Independent signing-key backup and current billing remain unverified. iOS initial signing needs a compatible computer; 7-day refresh remains necessary.

- CI 45803519611: common checks and iOS build succeeded, Android release failed at compileReleaseJavaWithJavac because GeneratedPluginRegistrant references the dev-only integration_test plugin. Known Flutter issue https://github.com/flutter/flutter/issues/169336. Candidate workaround: normal release build without --no-pub, retain lockfile enforcement and verify no dev plugin registration. Pending local release validation and required CI.

Architect review RC-02: Codespace Gradle daemon disappeared with 8 GiB heap, 4 GiB metaspace; OOM not confirmed. Candidate 3 GiB heap, 768 MiB metaspace, 2 workers and bounded Kotlin daemon, subject to effective memory diagnostics. RC-01 preflight uses release config-only before build. Grouped repair pending local validation; no new CI until local success. Prior iOS artifact is not eligible for release under exact-main-SHA policy. Cupertino font warning is non-blocking; dependency origin remains to be checked.

- Local retry at e4da637: release config and preflight passed, Gradle 3 GiB daemon stopped during automatic Android SDK Platform 35 installation (25%); cgroup oom_kill delta 0. Owner reports standalone SDK 35 installation succeeded. Add SDK 35 to setup and CI; actual release build still pending. Root cause of daemon shutdown not proven.

## BUBKA-003A follow-ups
Owner reports Android install/update/data retention passed; iOS SideStore setup and physical checks remain blocked until computer available. Phase 03 remains partial. Inexact notification scheduling is retained; opening the app after a due time may reconcile away a still-pending delayed notification (code-level risk, not proven cause of observed delay). Before real vehicle reminders: durable due/pending/delivered states, compensating notification without duplication, tests for delayed delivery, resume, reboot, denial, timezone and iOS cap; no cloud/polling or exact alarm permission by default. Diagnostic test cannot promise exactly two minutes. Independent signing-key backup, local snapshot backup and billing remain unverified. No Phase 04 authorization. Live lite timing and release provenance on real next release remain unverified.

## BUBKA-004 open issues
Local draft has not been compiled in authoring environment (no SDK). Required format/analyze/test, actual Flutter visual comparison, golden baselines, full PR CI and physical/profile tests pending. Monogram B adaptive production layers are blocked on the embedded rounded frame decision; no unauthorized icon change. Detailed animation and form visual acceptance still pending. Phase 03 physical follow-ups and notification reconciliation issue remain unchanged.


## V5 local candidate
V5 requires real visual owner review and native profiling/physical masks/update tests; reconstruction not pixel-perfect. Test font differs from platform fonts.


## Актуално: BUBA rebrand / phase 04
V5 Polish е визуално приет; новият тесен rebrand подлежи на локална проверка и преглед. Реконструкцията не е pixel-perfect. Native FPS, cold start, маски, SideStore effective identity, update retention, физически тестове и окончателни права не са потвърдени. Съществуват други BUBA марки/приложения; ограниченото търсене на архитекта не е правно разрешение. Без public push до изрично приемане на остатъчния риск и diff; при конкретен конфликт STOP. Фаза 03 е приета по owner-reported install/start/update/data retention/notification receipt, но timing/reconciliation, iOS refresh, локални backups и независим signing backup остават. Познатото Drift предупреждение се следи. GitHub release title все още съдържа BUBKA по заключения workflow; промяната му е за отделно разрешение.


## BUBA-004 — актуално състояние към PR preflight
Одобрението на render и остатъчния риск от собственика и архитектурното приемане са получени на 26.11.2026. Старият STOP за изчакване на тези одобрения е отменен; при конкретен нов конфликт STOP. Проверката на права остава preliminary_not_legal_clearance. Фаза 04 не е завършена; live preflight, PR CI и физически Android/iOS тестове предстоят. Фаза 03 accepted_with_followups: notification timing/reconciliation, iOS refresh, local backups, independent signing-key backup. Native masks, FPS/memory, cold start, retention, effective SideStore identity и окончателни права не са потвърдени. Не се разрешава merge/release/05.

## BUBKA-005 — current status (supersedes historical status)
Phase 04 update and retention on Android and iPhone reported successful by owner; startup animation and notification timing remain open. Independent physical profiling, rights clearance, backups and iOS refresh remain open. Phase 05 physical upgrade and actual data retention are pending future release; candidate is not yet accepted.

## BUBKA-005A
BUBKA-005A: only standard BG, BG personalized and basic foreign formats supported. Other special formats require verified rules. Existing values preserved until edited.

## BUBKA-006 candidate
Fuel consumption is an estimate without full-tank information. Device upgrade/retention and production accessibility remain pending physical acceptance. Service reminders and oil interval UI are outside scope.


## BUBKA-007
Phase 07 candidate: notification reconciliation preserves pending overdue requests unless explicitly removed. Device timing and iOS pending capacity remain platform-dependent; physical validation pending.
