# История на версиите
## 0.0.1 — 2026-11-26 (фаза 01)
- Първоначален native Flutter проект за Android/iOS и постоянни идентификатори.
- Фиксирани версии на Flutter и Android инструменти; Codespaces devcontainer.
- Строги проверки за формат, анализ и smoke test; CI debug APK и unsigned IPA с верификация.
- Отстранен остарелият import на material.dart; временният екран използва WidgetsApp.
- Поправен редът на аргументите на lipo при проверката на ARM64.
- Премахната неизползвана зависимост material_ui от шаблона; повторни локални тестове.
- Добавена техническа документация. Финалният пълен CI е успешен; добавени задължителни правила за ефективност и селективен CI.

## 0.1.0+2 — 2026-11-26 (фаза 02)
Архитектурно ядро, диагностичен модул, локална база, селективен CI и динамични версии. Два успешни пълни CI, архитектурното приемане предстои.

## 0.2.0+3 — testing prerelease
Permanent Android signing preparation, local notification scheduling, snapshot and schema verification, checksum-verified update transport, system installer/share flow and controlled release workflow. Full main CI and signed Android prerelease verified; Android initial install confirmed. iOS installation and physical update tests pending.

## 0.2.1+4 — testing update candidate
Version-only increment for physical update and local data retention verification. No application identity, schema, dependency or business logic changes. Release and physical verification pending.

## 0.3.0+5 — phase 04 local candidate (unverified)
Draft native cockpit design system, presentation routes, local fixtures and ignition; black launch screens. Monogram production adaptation, actual visual and Flutter validation, golden review, PR CI and release remain pending.


## V5 local candidate
Phase 04 V5 local candidate: DESIGN-003 asset integration. Not published or accepted.


## 0.3.0+5 — BUBA (локален кандидат, непубликуван)
V5 Final Polish е приет визуално под старото име; новият видим бранд BUBA (Буба), системни етикети, диагностика, известия, About и два wordmark слоя са в локална проверка. Няма промяна на application/bundle ID, съществуващите данни, подпис, версия, release файлове или update договор. Публикувана тестова версия остава 0.2.1+4 под старото име. Фаза 03 accepted_with_followups, фаза 04 не е приключена. Това са кандидат release notes; GitHub workflow title остава технически BUBKA до отделно разрешение.

## BUBKA-005 — current status (supersedes historical status)
0.4.0+6 candidate — local garage CRUD, active vehicle, catalog and additive schema migration. No release yet.

## BUBKA-005A
0.4.1+7 candidate — searchable catalog, explicit model fallback, registration format, year and fuel validation, unchanged legacy values preserved.

## 0.5.0+8 — candidate
Local fuel and odometer history per vehicle; estimated consumption; shared odometer reader; additive schema v3. Pending CI and physical tests.
