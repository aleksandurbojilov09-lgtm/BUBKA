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

## 0.2.0+3 — phase 03 candidate (not released)
Permanent Android signing preparation, local notification scheduling, snapshot and schema verification, checksum-verified update transport, system installer/share flow and controlled release workflow. Physical and final CI verification pending.
