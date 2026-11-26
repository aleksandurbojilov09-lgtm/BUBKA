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
