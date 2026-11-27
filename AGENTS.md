# Правила за AI изпълнители
Собственикът взема решенията; главният архитект управлява фазите. Работи само по възложената фаза, следващата изисква одобрение. Отговаряй на български, стъпка по стъпка. Потребителят използва Codespaces в браузър, без програмистки опит: предоставяй готови TXT скриптове и точни команди, без ръчно редактиране на код. Изчаквай критичните резултати; анализирай действителния терминален изход; не повтаряй успешни стъпки.

- Flutter/Dart, native Android/iOS, offline-first, локална SQLite/Drift; без PWA, web, акаунти, cloud, реклама, телеметрия или платени услуги/API.
- Modular monolith, feature-first, MVVM, Provider/ChangeNotifier, GoRouter, static module registry, обща design system. Минимален main.dart; без бизнес логика в него. Малки файлове с една отговорност, без циклични зависимости, дублиране или излишна сложност. Променяй само необходимите файлове.
- Пази application ID, bundle ID, данните при актуализация и съществуващата функционалност. Не пипай KMX или други проекти. Никакви лични данни, пароли и частни ключове в Git/чат. Проверявай зависимости и лицензи; не заобикаляй системни защити.
- Git: main и отделен task branch; merge само след зелени проверки; без force push, разрушителни операции и скрити грешки. SemVer; таг след успешни задължителни проверки. Не публикувай неподписан IPA като инсталационен. Не активирай платено потребление.
- След всяка фаза актуализирай документацията и предай JSON отчет в docs/handoffs/. Отделяй проверените от непроверените резултати. Не започвай следваща фаза самостоятелно.

## Задължителна ефективност и оптимизация на CI (решение на собственика)
- Главният архитект предава тези правила на всеки следващ изпълнител. Селективният workflow е реализиран във фаза 02; продължавай да измерваш реалните резултати.
- Само документи: проверка на JSON, форматиране и съдържание; без компилация, когато доказано няма промяна на build входовете. Dart код: format/analyze/test. Android-only конфигурация: проверки и Android build. iOS-only: проверки и iOS build. Общи зависимости, архитектура, CI/toolchain, неизвестни/смесени промени, край на фаза и release: пълни проверки и двете компилации.
- Използвай надеждна класификация на променените файлове (вкл. всички commits в push/PR); при грешка или неяснота изпълни пълния CI. Запази общ задължителен CI gate, който отчита и проверките по документацията; не оставяй required checks в pending чрез blanket skip/path filters. Осигури ръчен full CI (workflow_dispatch).
- Кеширай Flutter SDK, Dart pub и Gradle с ключове според OS/архитектура, версии и lockfiles; проверявай целостта на SDK и не кеширай ключове/секрети. Android и iOS да се изпълняват паралелно след общите проверки, когато са необходими и двете; запази cancel-in-progress. Измери реалното време преди/след. Не обещавай конкретно ускорение без измерване.
- Никога не пропускай необходим тест, не скривай грешки и не изключвай защити. Не повтаряй вече успешни проверки при непроменени входове. Предпочитай един готов TXT скрипт, минимален брой действия от собственика, автоматизация и проверка директно през GitHub, когато е възможно.
- Без Full Rebuild, преинсталация или нов Codespace при работеща среда, освен при обоснована необходимост. Първо оцени време, риск, полза и по-лек вариант; поискай съгласие за тежки операции. Не повтаряй теста за възстановяване без промяна на инфраструктурата.
- Еднократно във фаза 01: последният документационен commit може да не стартира повторна пълна компилация само след локална валидация и доказан diff, ограничен до документация спрямо напълно зелен source SHA. Не заобикаляй branch protection. Това не заменя бъдещия селективен CI.

## Фаза 02
Селективният CI и централната версия са реализирани; пълните проверки на source SHA са успешни. При липсващо доказателство за конкретна проверка не я маркирай като премината. Не започвай фаза 03 без одобрение. Задължителен gate: BUBKA CI gate; не приемай непроверен commit.

## Фаза 03 — одобрена
Фаза 02 е приета с последващи задачи. BUBKA-003 е разрешена; фаза 04 не е разрешена. Работи в `phase/03-installation-updates` чрез PR. Не използвай debug подпис като release подпис. Постоянен Android ключ само с разрешение на собственика; CI secrets само с отделно изрично съгласие. Не променяй schema v1 без реална необходимост. Физическите инсталации и запазването на данните при update и на двете платформи са задължителни за приключване.

## Grouped implementation rule
Do not push small implementation commits to an open PR one at a time. Prepare a coherent batch on a non-PR staging branch, run formatting, analysis and targeted/full local tests, then advance the PR branch once. Do not repeat full builds solely to measure performance. Release workflow consumes a successful full CI run for the exact protected main SHA; signing secrets restricted to main.

## Задължителна пакетна поправка (архитектурен преглед BUBKA-003)
Един общ пакет, един TXT и една команда; без експериментални push операции към PR. При Android release дефект първо диагностика на RAM/cgroup и предварителна release plugin регистрация, после една локална release компилация и верификация. Push към PR само след успех. При грешка запази конкретния failed task, безопасна диагностика и SHA, без секрети. Не премахвай интеграционните тестове и не изменяй Flutter SDK.

## BUBKA-003A — CI policy supersedes earlier selective CI rules
PR validates synthetic merge result. Docs-only checks docs/scripts/diff; known ordinary Dart changes and proven version-only changes run common checks without platform builds; native-only changes run the relevant platform, shared/unknown/dependency/schema/CI changes require both. Every non-doc main push and explicit main dispatch require full Android+iOS. Preserve strict BUBKA CI gate and no secrets in PR. Release uses exact-main, same-attempt successful CI artifacts and archive/payload SHA-256; no build in release. One task branch, one grouped push, one PR; no version bump for infrastructure. Phase 04 is not authorized.

## BUBKA-004 — current authorization (supersedes historical phase 04 blocks)
Фаза 04 е разрешена само за UI implementation и PR кандидат; без merge/release/05. Йерархия: последно изрично решение на собственика > архитектурен мандат > одобрени оригинални макети > спецификации > реконструирани HTML. Двойна проверка на решенията спрямо код/SDK и официални интернет източници; конфликт или блокер се ескалира с доказателства. Един общ TXT/команда/пакет, една push операция и един PR след локален format/analyze/test и visual review; независимо приемане от архитекта. Никакви платени услуги, облак, фиктивни production данни, промяна на identities/данни/signing/schema/CI/update/notification policy. Не започвай следваща фаза без отделно одобрение. Фаза 03 остава partial; 003A accepted.

## BUBKA-004 visual correction authorization
Only local visual correction authorized by the architect; no push, PR, merge, release or phase 05 until new evidence is accepted. Phase 03 accepted with follow-ups per architect; iOS install/start/update/data retention/notification receipt owner-reported, not independently measured. Timing, iOS refresh and backups pending.

## BUBKA-004 V4
Local visual fidelity and native icon B authorized only. Owner rejected V3. No commit/push/PR/merge/release or phase 05. No new runtime dependency. Preserve exact baseline and V3 source hashes.


## V5 local candidate
V5 authorized local DESIGN-003 integration only. Preserve native icons, no commit/push/PR/CI/native build/merge/release/phase05.


## BUBA-004 — актуален мандат (има предимство пред старите статуси)
Потребителско име BUBA (Буба), старо BUBKA. V5 Final Polish визуално приет от собственик и архитект; одобреният архив е неизменен. Разрешено е само локално преименуване; публичният push е блокиран до изрично приемане на остатъчния риск от собственика и архитектурно приемане на точния diff. Няма commit/PR/CI/merge/release/05. Запази техническите BUBKA договори, package garage, identity, signing, DB/paths/keys, update/release filenames, CI gate. Фаза 03 accepted_with_followups (известия timing/reconciliation, iOS refresh, локални backups, независим signing backup). Историческите записи не са текущи разрешения. Един общ пакет и отчет; без нов дизайн.

## BUBKA-005 — current status (supersedes historical status)
Фаза 05 BUBKA-005 е разрешена за един PR след локален preflight. Без merge, tag, release или фаза 06 до отделно решение. Запази старите записи и identity; не пипай известията, signing или update договора.

## BUBKA-005A
BUBKA-005A authorized end to end testing only: strict garage input, preserve old data, schema v2 unchanged, one PR, verified full CI before merge and release; no phase 06.
