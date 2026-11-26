// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DiagnosticRecordsTable extends DiagnosticRecords
    with TableInfo<$DiagnosticRecordsTable, DiagnosticRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $DiagnosticRecordsTable createAlias(String alias) {
    return $DiagnosticRecordsTable(attachedDatabase, alias);
  }
}

class DiagnosticRecord extends DataClass
    implements Insertable<DiagnosticRecord> {
  final int id;
  final String value;
  const DiagnosticRecord({required this.id, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<String>(value);
    return map;
  }

  DiagnosticRecordsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticRecordsCompanion(id: Value(id), value: Value(value));
  }

  factory DiagnosticRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticRecord(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<String>(value),
    };
  }

  DiagnosticRecord copyWith({int? id, String? value}) =>
      DiagnosticRecord(id: id ?? this.id, value: value ?? this.value);
  DiagnosticRecord copyWithCompanion(DiagnosticRecordsCompanion data) {
    return DiagnosticRecord(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticRecord(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticRecord &&
          other.id == this.id &&
          other.value == this.value);
}

class DiagnosticRecordsCompanion extends UpdateCompanion<DiagnosticRecord> {
  final Value<int> id;
  final Value<String> value;
  const DiagnosticRecordsCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
  });
  DiagnosticRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String value,
  }) : value = Value(value);
  static Insertable<DiagnosticRecord> custom({
    Expression<int>? id,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
    });
  }

  DiagnosticRecordsCompanion copyWith({Value<int>? id, Value<String>? value}) {
    return DiagnosticRecordsCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticRecordsCompanion(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ModulePreferencesTable extends ModulePreferences
    with TableInfo<$ModulePreferencesTable, ModulePreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModulePreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [moduleId, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModulePreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId};
  @override
  ModulePreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModulePreference(
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ModulePreferencesTable createAlias(String alias) {
    return $ModulePreferencesTable(attachedDatabase, alias);
  }
}

class ModulePreference extends DataClass
    implements Insertable<ModulePreference> {
  final String moduleId;
  final bool enabled;
  const ModulePreference({required this.moduleId, required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ModulePreferencesCompanion toCompanion(bool nullToAbsent) {
    return ModulePreferencesCompanion(
      moduleId: Value(moduleId),
      enabled: Value(enabled),
    );
  }

  factory ModulePreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModulePreference(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ModulePreference copyWith({String? moduleId, bool? enabled}) =>
      ModulePreference(
        moduleId: moduleId ?? this.moduleId,
        enabled: enabled ?? this.enabled,
      );
  ModulePreference copyWithCompanion(ModulePreferencesCompanion data) {
    return ModulePreference(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModulePreference(')
          ..write('moduleId: $moduleId, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(moduleId, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModulePreference &&
          other.moduleId == this.moduleId &&
          other.enabled == this.enabled);
}

class ModulePreferencesCompanion extends UpdateCompanion<ModulePreference> {
  final Value<String> moduleId;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ModulePreferencesCompanion({
    this.moduleId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModulePreferencesCompanion.insert({
    required String moduleId,
    required bool enabled,
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId),
       enabled = Value(enabled);
  static Insertable<ModulePreference> custom({
    Expression<String>? moduleId,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModulePreferencesCompanion copyWith({
    Value<String>? moduleId,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ModulePreferencesCompanion(
      moduleId: moduleId ?? this.moduleId,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModulePreferencesCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DiagnosticRecordsTable diagnosticRecords =
      $DiagnosticRecordsTable(this);
  late final $ModulePreferencesTable modulePreferences =
      $ModulePreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    diagnosticRecords,
    modulePreferences,
  ];
}

typedef $$DiagnosticRecordsTableCreateCompanionBuilder =
    DiagnosticRecordsCompanion Function({Value<int> id, required String value});
typedef $$DiagnosticRecordsTableUpdateCompanionBuilder =
    DiagnosticRecordsCompanion Function({Value<int> id, Value<String> value});

class $$DiagnosticRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosticRecordsTable> {
  $$DiagnosticRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosticRecordsTable> {
  $$DiagnosticRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosticRecordsTable> {
  $$DiagnosticRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DiagnosticRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiagnosticRecordsTable,
          DiagnosticRecord,
          $$DiagnosticRecordsTableFilterComposer,
          $$DiagnosticRecordsTableOrderingComposer,
          $$DiagnosticRecordsTableAnnotationComposer,
          $$DiagnosticRecordsTableCreateCompanionBuilder,
          $$DiagnosticRecordsTableUpdateCompanionBuilder,
          (
            DiagnosticRecord,
            BaseReferences<
              _$AppDatabase,
              $DiagnosticRecordsTable,
              DiagnosticRecord
            >,
          ),
          DiagnosticRecord,
          PrefetchHooks Function()
        > {
  $$DiagnosticRecordsTableTableManager(
    _$AppDatabase db,
    $DiagnosticRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> value = const Value.absent(),
          }) => DiagnosticRecordsCompanion(id: id, value: value),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String value,
          }) => DiagnosticRecordsCompanion.insert(id: id, value: value),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiagnosticRecordsTable, DiagnosticRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DiagnosticRecordsTable,
                    DiagnosticRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiagnosticRecordsTable,
      DiagnosticRecord,
      $$DiagnosticRecordsTableFilterComposer,
      $$DiagnosticRecordsTableOrderingComposer,
      $$DiagnosticRecordsTableAnnotationComposer,
      $$DiagnosticRecordsTableCreateCompanionBuilder,
      $$DiagnosticRecordsTableUpdateCompanionBuilder,
      (
        DiagnosticRecord,
        BaseReferences<
          _$AppDatabase,
          $DiagnosticRecordsTable,
          DiagnosticRecord
        >,
      ),
      DiagnosticRecord,
      PrefetchHooks Function()
    >;
typedef $$ModulePreferencesTableCreateCompanionBuilder =
    ModulePreferencesCompanion Function({
      required String moduleId,
      required bool enabled,
      Value<int> rowid,
    });
typedef $$ModulePreferencesTableUpdateCompanionBuilder =
    ModulePreferencesCompanion Function({
      Value<String> moduleId,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$ModulePreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ModulePreferencesTable> {
  $$ModulePreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModulePreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ModulePreferencesTable> {
  $$ModulePreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModulePreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModulePreferencesTable> {
  $$ModulePreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$ModulePreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModulePreferencesTable,
          ModulePreference,
          $$ModulePreferencesTableFilterComposer,
          $$ModulePreferencesTableOrderingComposer,
          $$ModulePreferencesTableAnnotationComposer,
          $$ModulePreferencesTableCreateCompanionBuilder,
          $$ModulePreferencesTableUpdateCompanionBuilder,
          (
            ModulePreference,
            BaseReferences<
              _$AppDatabase,
              $ModulePreferencesTable,
              ModulePreference
            >,
          ),
          ModulePreference,
          PrefetchHooks Function()
        > {
  $$ModulePreferencesTableTableManager(
    _$AppDatabase db,
    $ModulePreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModulePreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModulePreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModulePreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> moduleId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModulePreferencesCompanion(
                moduleId: moduleId,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String moduleId,
                required bool enabled,
                Value<int> rowid = const Value.absent(),
              }) => ModulePreferencesCompanion.insert(
                moduleId: moduleId,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModulePreferencesTable, ModulePreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ModulePreferencesTable,
                    ModulePreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModulePreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModulePreferencesTable,
      ModulePreference,
      $$ModulePreferencesTableFilterComposer,
      $$ModulePreferencesTableOrderingComposer,
      $$ModulePreferencesTableAnnotationComposer,
      $$ModulePreferencesTableCreateCompanionBuilder,
      $$ModulePreferencesTableUpdateCompanionBuilder,
      (
        ModulePreference,
        BaseReferences<
          _$AppDatabase,
          $ModulePreferencesTable,
          ModulePreference
        >,
      ),
      ModulePreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DiagnosticRecordsTableTableManager get diagnosticRecords =>
      $$DiagnosticRecordsTableTableManager(_db, _db.diagnosticRecords);
  $$ModulePreferencesTableTableManager get modulePreferences =>
      $$ModulePreferencesTableTableManager(_db, _db.modulePreferences);
}
