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

class $GarageVehiclesTable extends GarageVehicles
    with TableInfo<$GarageVehiclesTable, GarageVehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarageVehiclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationKeyMeta = const VerificationMeta(
    'registrationKey',
  );
  @override
  late final GeneratedColumn<String> registrationKey = GeneratedColumn<String>(
    'registration_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelMeta = const VerificationMeta('fuel');
  @override
  late final GeneratedColumn<String> fuel = GeneratedColumn<String>(
    'fuel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    brand,
    model,
    registration,
    registrationKey,
    year,
    fuel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garage_vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarageVehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationMeta);
    }
    if (data.containsKey('registration_key')) {
      context.handle(
        _registrationKeyMeta,
        registrationKey.isAcceptableOrUnknown(
          data['registration_key']!,
          _registrationKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationKeyMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('fuel')) {
      context.handle(
        _fuelMeta,
        fuel.isAcceptableOrUnknown(data['fuel']!, _fuelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GarageVehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarageVehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      )!,
      registrationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_key'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      fuel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel'],
      ),
    );
  }

  @override
  $GarageVehiclesTable createAlias(String alias) {
    return $GarageVehiclesTable(attachedDatabase, alias);
  }
}

class GarageVehicle extends DataClass implements Insertable<GarageVehicle> {
  final int id;
  final String brand;
  final String model;
  final String registration;
  final String registrationKey;
  final int? year;
  final String? fuel;
  const GarageVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.registration,
    required this.registrationKey,
    this.year,
    this.fuel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    map['registration'] = Variable<String>(registration);
    map['registration_key'] = Variable<String>(registrationKey);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || fuel != null) {
      map['fuel'] = Variable<String>(fuel);
    }
    return map;
  }

  GarageVehiclesCompanion toCompanion(bool nullToAbsent) {
    return GarageVehiclesCompanion(
      id: Value(id),
      brand: Value(brand),
      model: Value(model),
      registration: Value(registration),
      registrationKey: Value(registrationKey),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      fuel: fuel == null && nullToAbsent ? const Value.absent() : Value(fuel),
    );
  }

  factory GarageVehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarageVehicle(
      id: serializer.fromJson<int>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      registration: serializer.fromJson<String>(json['registration']),
      registrationKey: serializer.fromJson<String>(json['registrationKey']),
      year: serializer.fromJson<int?>(json['year']),
      fuel: serializer.fromJson<String?>(json['fuel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'registration': serializer.toJson<String>(registration),
      'registrationKey': serializer.toJson<String>(registrationKey),
      'year': serializer.toJson<int?>(year),
      'fuel': serializer.toJson<String?>(fuel),
    };
  }

  GarageVehicle copyWith({
    int? id,
    String? brand,
    String? model,
    String? registration,
    String? registrationKey,
    Value<int?> year = const Value.absent(),
    Value<String?> fuel = const Value.absent(),
  }) => GarageVehicle(
    id: id ?? this.id,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    registration: registration ?? this.registration,
    registrationKey: registrationKey ?? this.registrationKey,
    year: year.present ? year.value : this.year,
    fuel: fuel.present ? fuel.value : this.fuel,
  );
  GarageVehicle copyWithCompanion(GarageVehiclesCompanion data) {
    return GarageVehicle(
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      registrationKey: data.registrationKey.present
          ? data.registrationKey.value
          : this.registrationKey,
      year: data.year.present ? data.year.value : this.year,
      fuel: data.fuel.present ? data.fuel.value : this.fuel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarageVehicle(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('registration: $registration, ')
          ..write('registrationKey: $registrationKey, ')
          ..write('year: $year, ')
          ..write('fuel: $fuel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, brand, model, registration, registrationKey, year, fuel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarageVehicle &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.registration == this.registration &&
          other.registrationKey == this.registrationKey &&
          other.year == this.year &&
          other.fuel == this.fuel);
}

class GarageVehiclesCompanion extends UpdateCompanion<GarageVehicle> {
  final Value<int> id;
  final Value<String> brand;
  final Value<String> model;
  final Value<String> registration;
  final Value<String> registrationKey;
  final Value<int?> year;
  final Value<String?> fuel;
  const GarageVehiclesCompanion({
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.registration = const Value.absent(),
    this.registrationKey = const Value.absent(),
    this.year = const Value.absent(),
    this.fuel = const Value.absent(),
  });
  GarageVehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String brand,
    required String model,
    required String registration,
    required String registrationKey,
    this.year = const Value.absent(),
    this.fuel = const Value.absent(),
  }) : brand = Value(brand),
       model = Value(model),
       registration = Value(registration),
       registrationKey = Value(registrationKey);
  static Insertable<GarageVehicle> custom({
    Expression<int>? id,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? registration,
    Expression<String>? registrationKey,
    Expression<int>? year,
    Expression<String>? fuel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (registration != null) 'registration': registration,
      if (registrationKey != null) 'registration_key': registrationKey,
      if (year != null) 'year': year,
      if (fuel != null) 'fuel': fuel,
    });
  }

  GarageVehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? brand,
    Value<String>? model,
    Value<String>? registration,
    Value<String>? registrationKey,
    Value<int?>? year,
    Value<String?>? fuel,
  }) {
    return GarageVehiclesCompanion(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      registration: registration ?? this.registration,
      registrationKey: registrationKey ?? this.registrationKey,
      year: year ?? this.year,
      fuel: fuel ?? this.fuel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (registrationKey.present) {
      map['registration_key'] = Variable<String>(registrationKey.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (fuel.present) {
      map['fuel'] = Variable<String>(fuel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarageVehiclesCompanion(')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('registration: $registration, ')
          ..write('registrationKey: $registrationKey, ')
          ..write('year: $year, ')
          ..write('fuel: $fuel')
          ..write(')'))
        .toString();
  }
}

class $ActiveGarageVehiclesTable extends ActiveGarageVehicles
    with TableInfo<$ActiveGarageVehiclesTable, ActiveGarageVehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveGarageVehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    check: () => slot.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garage_vehicles (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [slot, vehicleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_garage_vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveGarageVehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  ActiveGarageVehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveGarageVehicle(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
    );
  }

  @override
  $ActiveGarageVehiclesTable createAlias(String alias) {
    return $ActiveGarageVehiclesTable(attachedDatabase, alias);
  }
}

class ActiveGarageVehicle extends DataClass
    implements Insertable<ActiveGarageVehicle> {
  final int slot;
  final int vehicleId;
  const ActiveGarageVehicle({required this.slot, required this.vehicleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['vehicle_id'] = Variable<int>(vehicleId);
    return map;
  }

  ActiveGarageVehiclesCompanion toCompanion(bool nullToAbsent) {
    return ActiveGarageVehiclesCompanion(
      slot: Value(slot),
      vehicleId: Value(vehicleId),
    );
  }

  factory ActiveGarageVehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveGarageVehicle(
      slot: serializer.fromJson<int>(json['slot']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'vehicleId': serializer.toJson<int>(vehicleId),
    };
  }

  ActiveGarageVehicle copyWith({int? slot, int? vehicleId}) =>
      ActiveGarageVehicle(
        slot: slot ?? this.slot,
        vehicleId: vehicleId ?? this.vehicleId,
      );
  ActiveGarageVehicle copyWithCompanion(ActiveGarageVehiclesCompanion data) {
    return ActiveGarageVehicle(
      slot: data.slot.present ? data.slot.value : this.slot,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveGarageVehicle(')
          ..write('slot: $slot, ')
          ..write('vehicleId: $vehicleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, vehicleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveGarageVehicle &&
          other.slot == this.slot &&
          other.vehicleId == this.vehicleId);
}

class ActiveGarageVehiclesCompanion
    extends UpdateCompanion<ActiveGarageVehicle> {
  final Value<int> slot;
  final Value<int> vehicleId;
  const ActiveGarageVehiclesCompanion({
    this.slot = const Value.absent(),
    this.vehicleId = const Value.absent(),
  });
  ActiveGarageVehiclesCompanion.insert({
    this.slot = const Value.absent(),
    required int vehicleId,
  }) : vehicleId = Value(vehicleId);
  static Insertable<ActiveGarageVehicle> custom({
    Expression<int>? slot,
    Expression<int>? vehicleId,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (vehicleId != null) 'vehicle_id': vehicleId,
    });
  }

  ActiveGarageVehiclesCompanion copyWith({
    Value<int>? slot,
    Value<int>? vehicleId,
  }) {
    return ActiveGarageVehiclesCompanion(
      slot: slot ?? this.slot,
      vehicleId: vehicleId ?? this.vehicleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveGarageVehiclesCompanion(')
          ..write('slot: $slot, ')
          ..write('vehicleId: $vehicleId')
          ..write(')'))
        .toString();
  }
}

class $FuelEntriesTable extends FuelEntries
    with TableInfo<$FuelEntriesTable, FuelEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garage_vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<int> odometerKm = GeneratedColumn<int>(
    'odometer_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelMlMeta = const VerificationMeta('fuelMl');
  @override
  late final GeneratedColumn<int> fuelMl = GeneratedColumn<int>(
    'fuel_ml',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    entryDate,
    odometerKm,
    fuelMl,
    priceCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerKmMeta);
    }
    if (data.containsKey('fuel_ml')) {
      context.handle(
        _fuelMlMeta,
        fuelMl.isAcceptableOrUnknown(data['fuel_ml']!, _fuelMlMeta),
      );
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_km'],
      )!,
      fuelMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_ml'],
      ),
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      ),
    );
  }

  @override
  $FuelEntriesTable createAlias(String alias) {
    return $FuelEntriesTable(attachedDatabase, alias);
  }
}

class FuelEntryRow extends DataClass implements Insertable<FuelEntryRow> {
  final int id;
  final int vehicleId;
  final String entryDate;
  final int odometerKm;
  final int? fuelMl;
  final int? priceCents;
  const FuelEntryRow({
    required this.id,
    required this.vehicleId,
    required this.entryDate,
    required this.odometerKm,
    this.fuelMl,
    this.priceCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['entry_date'] = Variable<String>(entryDate);
    map['odometer_km'] = Variable<int>(odometerKm);
    if (!nullToAbsent || fuelMl != null) {
      map['fuel_ml'] = Variable<int>(fuelMl);
    }
    if (!nullToAbsent || priceCents != null) {
      map['price_cents'] = Variable<int>(priceCents);
    }
    return map;
  }

  FuelEntriesCompanion toCompanion(bool nullToAbsent) {
    return FuelEntriesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      entryDate: Value(entryDate),
      odometerKm: Value(odometerKm),
      fuelMl: fuelMl == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelMl),
      priceCents: priceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(priceCents),
    );
  }

  factory FuelEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelEntryRow(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      odometerKm: serializer.fromJson<int>(json['odometerKm']),
      fuelMl: serializer.fromJson<int?>(json['fuelMl']),
      priceCents: serializer.fromJson<int?>(json['priceCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'entryDate': serializer.toJson<String>(entryDate),
      'odometerKm': serializer.toJson<int>(odometerKm),
      'fuelMl': serializer.toJson<int?>(fuelMl),
      'priceCents': serializer.toJson<int?>(priceCents),
    };
  }

  FuelEntryRow copyWith({
    int? id,
    int? vehicleId,
    String? entryDate,
    int? odometerKm,
    Value<int?> fuelMl = const Value.absent(),
    Value<int?> priceCents = const Value.absent(),
  }) => FuelEntryRow(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    entryDate: entryDate ?? this.entryDate,
    odometerKm: odometerKm ?? this.odometerKm,
    fuelMl: fuelMl.present ? fuelMl.value : this.fuelMl,
    priceCents: priceCents.present ? priceCents.value : this.priceCents,
  );
  FuelEntryRow copyWithCompanion(FuelEntriesCompanion data) {
    return FuelEntryRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      fuelMl: data.fuelMl.present ? data.fuelMl.value : this.fuelMl,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntryRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('entryDate: $entryDate, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('fuelMl: $fuelMl, ')
          ..write('priceCents: $priceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleId, entryDate, odometerKm, fuelMl, priceCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelEntryRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.entryDate == this.entryDate &&
          other.odometerKm == this.odometerKm &&
          other.fuelMl == this.fuelMl &&
          other.priceCents == this.priceCents);
}

class FuelEntriesCompanion extends UpdateCompanion<FuelEntryRow> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> entryDate;
  final Value<int> odometerKm;
  final Value<int?> fuelMl;
  final Value<int?> priceCents;
  const FuelEntriesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.fuelMl = const Value.absent(),
    this.priceCents = const Value.absent(),
  });
  FuelEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required String entryDate,
    required int odometerKm,
    this.fuelMl = const Value.absent(),
    this.priceCents = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       entryDate = Value(entryDate),
       odometerKm = Value(odometerKm);
  static Insertable<FuelEntryRow> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? entryDate,
    Expression<int>? odometerKm,
    Expression<int>? fuelMl,
    Expression<int>? priceCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (entryDate != null) 'entry_date': entryDate,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (fuelMl != null) 'fuel_ml': fuelMl,
      if (priceCents != null) 'price_cents': priceCents,
    });
  }

  FuelEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<String>? entryDate,
    Value<int>? odometerKm,
    Value<int?>? fuelMl,
    Value<int?>? priceCents,
  }) {
    return FuelEntriesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      entryDate: entryDate ?? this.entryDate,
      odometerKm: odometerKm ?? this.odometerKm,
      fuelMl: fuelMl ?? this.fuelMl,
      priceCents: priceCents ?? this.priceCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<int>(odometerKm.value);
    }
    if (fuelMl.present) {
      map['fuel_ml'] = Variable<int>(fuelMl.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntriesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('entryDate: $entryDate, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('fuelMl: $fuelMl, ')
          ..write('priceCents: $priceCents')
          ..write(')'))
        .toString();
  }
}

class $VehicleDocumentsTable extends VehicleDocuments
    with TableInfo<$VehicleDocumentsTable, VehicleDocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garage_vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    kind,
    startDate,
    endDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleDocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleDocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleDocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $VehicleDocumentsTable createAlias(String alias) {
    return $VehicleDocumentsTable(attachedDatabase, alias);
  }
}

class VehicleDocumentRow extends DataClass
    implements Insertable<VehicleDocumentRow> {
  final int id;
  final int vehicleId;
  final String kind;
  final String? startDate;
  final String? endDate;
  final bool active;
  const VehicleDocumentRow({
    required this.id,
    required this.vehicleId,
    required this.kind,
    this.startDate,
    this.endDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  VehicleDocumentsCompanion toCompanion(bool nullToAbsent) {
    return VehicleDocumentsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      kind: Value(kind),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      active: Value(active),
    );
  }

  factory VehicleDocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleDocumentRow(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      kind: serializer.fromJson<String>(json['kind']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'kind': serializer.toJson<String>(kind),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  VehicleDocumentRow copyWith({
    int? id,
    int? vehicleId,
    String? kind,
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    bool? active,
  }) => VehicleDocumentRow(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    kind: kind ?? this.kind,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    active: active ?? this.active,
  );
  VehicleDocumentRow copyWithCompanion(VehicleDocumentsCompanion data) {
    return VehicleDocumentRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleDocumentRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleId, kind, startDate, endDate, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleDocumentRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.kind == this.kind &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.active == this.active);
}

class VehicleDocumentsCompanion extends UpdateCompanion<VehicleDocumentRow> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> kind;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<bool> active;
  const VehicleDocumentsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  VehicleDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required String kind,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       kind = Value(kind);
  static Insertable<VehicleDocumentRow> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? kind,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (kind != null) 'kind': kind,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (active != null) 'active': active,
    });
  }

  VehicleDocumentsCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<String>? kind,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<bool>? active,
  }) {
    return VehicleDocumentsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      kind: kind ?? this.kind,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $DocumentPaymentsTable extends DocumentPayments
    with TableInfo<$DocumentPaymentsTable, DocumentPaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentPaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<bool> paid = GeneratedColumn<bool>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    dueDate,
    amountCents,
    paid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentPaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentPaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentPaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid'],
      )!,
    );
  }

  @override
  $DocumentPaymentsTable createAlias(String alias) {
    return $DocumentPaymentsTable(attachedDatabase, alias);
  }
}

class DocumentPaymentRow extends DataClass
    implements Insertable<DocumentPaymentRow> {
  final int id;
  final int documentId;
  final String dueDate;
  final int amountCents;
  final bool paid;
  const DocumentPaymentRow({
    required this.id,
    required this.documentId,
    required this.dueDate,
    required this.amountCents,
    required this.paid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['due_date'] = Variable<String>(dueDate);
    map['amount_cents'] = Variable<int>(amountCents);
    map['paid'] = Variable<bool>(paid);
    return map;
  }

  DocumentPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentPaymentsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      dueDate: Value(dueDate),
      amountCents: Value(amountCents),
      paid: Value(paid),
    );
  }

  factory DocumentPaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentPaymentRow(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      paid: serializer.fromJson<bool>(json['paid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'dueDate': serializer.toJson<String>(dueDate),
      'amountCents': serializer.toJson<int>(amountCents),
      'paid': serializer.toJson<bool>(paid),
    };
  }

  DocumentPaymentRow copyWith({
    int? id,
    int? documentId,
    String? dueDate,
    int? amountCents,
    bool? paid,
  }) => DocumentPaymentRow(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    dueDate: dueDate ?? this.dueDate,
    amountCents: amountCents ?? this.amountCents,
    paid: paid ?? this.paid,
  );
  DocumentPaymentRow copyWithCompanion(DocumentPaymentsCompanion data) {
    return DocumentPaymentRow(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      paid: data.paid.present ? data.paid.value : this.paid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentPaymentRow(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amountCents: $amountCents, ')
          ..write('paid: $paid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, documentId, dueDate, amountCents, paid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentPaymentRow &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.dueDate == this.dueDate &&
          other.amountCents == this.amountCents &&
          other.paid == this.paid);
}

class DocumentPaymentsCompanion extends UpdateCompanion<DocumentPaymentRow> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<String> dueDate;
  final Value<int> amountCents;
  final Value<bool> paid;
  const DocumentPaymentsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.paid = const Value.absent(),
  });
  DocumentPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required String dueDate,
    required int amountCents,
    this.paid = const Value.absent(),
  }) : documentId = Value(documentId),
       dueDate = Value(dueDate),
       amountCents = Value(amountCents);
  static Insertable<DocumentPaymentRow> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<String>? dueDate,
    Expression<int>? amountCents,
    Expression<bool>? paid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (dueDate != null) 'due_date': dueDate,
      if (amountCents != null) 'amount_cents': amountCents,
      if (paid != null) 'paid': paid,
    });
  }

  DocumentPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<String>? dueDate,
    Value<int>? amountCents,
    Value<bool>? paid,
  }) {
    return DocumentPaymentsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      dueDate: dueDate ?? this.dueDate,
      amountCents: amountCents ?? this.amountCents,
      paid: paid ?? this.paid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (paid.present) {
      map['paid'] = Variable<bool>(paid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amountCents: $amountCents, ')
          ..write('paid: $paid')
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
  late final $GarageVehiclesTable garageVehicles = $GarageVehiclesTable(this);
  late final $ActiveGarageVehiclesTable activeGarageVehicles =
      $ActiveGarageVehiclesTable(this);
  late final $FuelEntriesTable fuelEntries = $FuelEntriesTable(this);
  late final $VehicleDocumentsTable vehicleDocuments = $VehicleDocumentsTable(
    this,
  );
  late final $DocumentPaymentsTable documentPayments = $DocumentPaymentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    diagnosticRecords,
    modulePreferences,
    garageVehicles,
    activeGarageVehicles,
    fuelEntries,
    vehicleDocuments,
    documentPayments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garage_vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('active_garage_vehicles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garage_vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fuel_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garage_vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vehicle_documents', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicle_documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_payments', kind: UpdateKind.delete)],
    ),
  ]);
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
typedef $$GarageVehiclesTableCreateCompanionBuilder =
    GarageVehiclesCompanion Function({
      Value<int> id,
      required String brand,
      required String model,
      required String registration,
      required String registrationKey,
      Value<int?> year,
      Value<String?> fuel,
    });
typedef $$GarageVehiclesTableUpdateCompanionBuilder =
    GarageVehiclesCompanion Function({
      Value<int> id,
      Value<String> brand,
      Value<String> model,
      Value<String> registration,
      Value<String> registrationKey,
      Value<int?> year,
      Value<String?> fuel,
    });

final class $$GarageVehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $GarageVehiclesTable, GarageVehicle> {
  $$GarageVehiclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ActiveGarageVehiclesTable,
    List<ActiveGarageVehicle>
  >
  _activeGarageVehiclesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activeGarageVehicles,
        aliasName: 'garage_vehicles__id__active_garage_vehicles__vehicle_id',
      );

  $$ActiveGarageVehiclesTableProcessedTableManager
  get activeGarageVehiclesRefs {
    final manager = $$ActiveGarageVehiclesTableTableManager(
      $_db,
      $_db.activeGarageVehicles,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activeGarageVehiclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FuelEntriesTable, List<FuelEntryRow>>
  _fuelEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelEntries,
    aliasName: 'garage_vehicles__id__fuel_entries__vehicle_id',
  );

  $$FuelEntriesTableProcessedTableManager get fuelEntriesRefs {
    final manager = $$FuelEntriesTableTableManager(
      $_db,
      $_db.fuelEntries,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VehicleDocumentsTable, List<VehicleDocumentRow>>
  _vehicleDocumentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicleDocuments,
    aliasName: 'garage_vehicles__id__vehicle_documents__vehicle_id',
  );

  $$VehicleDocumentsTableProcessedTableManager get vehicleDocumentsRefs {
    final manager = $$VehicleDocumentsTableTableManager(
      $_db,
      $_db.vehicleDocuments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _vehicleDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GarageVehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $GarageVehiclesTable> {
  $$GarageVehiclesTableFilterComposer({
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

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationKey => $composableBuilder(
    column: $table.registrationKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activeGarageVehiclesRefs(
    Expression<bool> Function($$ActiveGarageVehiclesTableFilterComposer f) f,
  ) {
    final $$ActiveGarageVehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeGarageVehicles,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveGarageVehiclesTableFilterComposer(
            $db: $db,
            $table: $db.activeGarageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fuelEntriesRefs(
    Expression<bool> Function($$FuelEntriesTableFilterComposer f) f,
  ) {
    final $$FuelEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableFilterComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vehicleDocumentsRefs(
    Expression<bool> Function($$VehicleDocumentsTableFilterComposer f) f,
  ) {
    final $$VehicleDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleDocuments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GarageVehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $GarageVehiclesTable> {
  $$GarageVehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationKey => $composableBuilder(
    column: $table.registrationKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GarageVehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarageVehiclesTable> {
  $$GarageVehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registrationKey => $composableBuilder(
    column: $table.registrationKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get fuel =>
      $composableBuilder(column: $table.fuel, builder: (column) => column);

  Expression<T> activeGarageVehiclesRefs<T extends Object>(
    Expression<T> Function($$ActiveGarageVehiclesTableAnnotationComposer a) f,
  ) {
    final $$ActiveGarageVehiclesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activeGarageVehicles,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActiveGarageVehiclesTableAnnotationComposer(
                $db: $db,
                $table: $db.activeGarageVehicles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> fuelEntriesRefs<T extends Object>(
    Expression<T> Function($$FuelEntriesTableAnnotationComposer a) f,
  ) {
    final $$FuelEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vehicleDocumentsRefs<T extends Object>(
    Expression<T> Function($$VehicleDocumentsTableAnnotationComposer a) f,
  ) {
    final $$VehicleDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleDocuments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GarageVehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarageVehiclesTable,
          GarageVehicle,
          $$GarageVehiclesTableFilterComposer,
          $$GarageVehiclesTableOrderingComposer,
          $$GarageVehiclesTableAnnotationComposer,
          $$GarageVehiclesTableCreateCompanionBuilder,
          $$GarageVehiclesTableUpdateCompanionBuilder,
          (GarageVehicle, $$GarageVehiclesTableReferences),
          GarageVehicle,
          PrefetchHooks Function({
            bool activeGarageVehiclesRefs,
            bool fuelEntriesRefs,
            bool vehicleDocumentsRefs,
          })
        > {
  $$GarageVehiclesTableTableManager(
    _$AppDatabase db,
    $GarageVehiclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarageVehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarageVehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarageVehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> registration = const Value.absent(),
                Value<String> registrationKey = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> fuel = const Value.absent(),
              }) => GarageVehiclesCompanion(
                id: id,
                brand: brand,
                model: model,
                registration: registration,
                registrationKey: registrationKey,
                year: year,
                fuel: fuel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String brand,
                required String model,
                required String registration,
                required String registrationKey,
                Value<int?> year = const Value.absent(),
                Value<String?> fuel = const Value.absent(),
              }) => GarageVehiclesCompanion.insert(
                id: id,
                brand: brand,
                model: model,
                registration: registration,
                registrationKey: registrationKey,
                year: year,
                fuel: fuel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GarageVehiclesTable, GarageVehicle>(table),
                  $$GarageVehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activeGarageVehiclesRefs = false,
                fuelEntriesRefs = false,
                vehicleDocumentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activeGarageVehiclesRefs) db.activeGarageVehicles,
                    if (fuelEntriesRefs) db.fuelEntries,
                    if (vehicleDocumentsRefs) db.vehicleDocuments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activeGarageVehiclesRefs)
                        await $_getPrefetchedDataByColumns<
                          GarageVehicle,
                          $GarageVehiclesTable,
                          ActiveGarageVehicle,
                          $ActiveGarageVehiclesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GarageVehiclesTableReferences
                              ._activeGarageVehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarageVehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).activeGarageVehiclesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vehicle_id',
                          typedResults: items,
                        ),
                      if (fuelEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          GarageVehicle,
                          $GarageVehiclesTable,
                          FuelEntryRow,
                          $FuelEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GarageVehiclesTableReferences
                              ._fuelEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarageVehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vehicle_id',
                          typedResults: items,
                        ),
                      if (vehicleDocumentsRefs)
                        await $_getPrefetchedDataByColumns<
                          GarageVehicle,
                          $GarageVehiclesTable,
                          VehicleDocumentRow,
                          $VehicleDocumentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GarageVehiclesTableReferences
                              ._vehicleDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarageVehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).vehicleDocumentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vehicle_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GarageVehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarageVehiclesTable,
      GarageVehicle,
      $$GarageVehiclesTableFilterComposer,
      $$GarageVehiclesTableOrderingComposer,
      $$GarageVehiclesTableAnnotationComposer,
      $$GarageVehiclesTableCreateCompanionBuilder,
      $$GarageVehiclesTableUpdateCompanionBuilder,
      (GarageVehicle, $$GarageVehiclesTableReferences),
      GarageVehicle,
      PrefetchHooks Function({
        bool activeGarageVehiclesRefs,
        bool fuelEntriesRefs,
        bool vehicleDocumentsRefs,
      })
    >;
typedef $$ActiveGarageVehiclesTableCreateCompanionBuilder =
    ActiveGarageVehiclesCompanion Function({
      Value<int> slot,
      required int vehicleId,
    });
typedef $$ActiveGarageVehiclesTableUpdateCompanionBuilder =
    ActiveGarageVehiclesCompanion Function({
      Value<int> slot,
      Value<int> vehicleId,
    });

final class $$ActiveGarageVehiclesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActiveGarageVehiclesTable,
          ActiveGarageVehicle
        > {
  $$ActiveGarageVehiclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GarageVehiclesTable _vehicleIdTable(_$AppDatabase db) => db
      .garageVehicles
      .createAlias('active_garage_vehicles__vehicle_id__garage_vehicles__id');

  $$GarageVehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$GarageVehiclesTableTableManager(
      $_db,
      $_db.garageVehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiveGarageVehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveGarageVehiclesTable> {
  $$ActiveGarageVehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  $$GarageVehiclesTableFilterComposer get vehicleId {
    final $$GarageVehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableFilterComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveGarageVehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveGarageVehiclesTable> {
  $$ActiveGarageVehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  $$GarageVehiclesTableOrderingComposer get vehicleId {
    final $$GarageVehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveGarageVehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveGarageVehiclesTable> {
  $$ActiveGarageVehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  $$GarageVehiclesTableAnnotationComposer get vehicleId {
    final $$GarageVehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveGarageVehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveGarageVehiclesTable,
          ActiveGarageVehicle,
          $$ActiveGarageVehiclesTableFilterComposer,
          $$ActiveGarageVehiclesTableOrderingComposer,
          $$ActiveGarageVehiclesTableAnnotationComposer,
          $$ActiveGarageVehiclesTableCreateCompanionBuilder,
          $$ActiveGarageVehiclesTableUpdateCompanionBuilder,
          (ActiveGarageVehicle, $$ActiveGarageVehiclesTableReferences),
          ActiveGarageVehicle,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$ActiveGarageVehiclesTableTableManager(
    _$AppDatabase db,
    $ActiveGarageVehiclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveGarageVehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveGarageVehiclesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActiveGarageVehiclesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback: ({
            Value<int> slot = const Value.absent(),
            Value<int> vehicleId = const Value.absent(),
          }) => ActiveGarageVehiclesCompanion(slot: slot, vehicleId: vehicleId),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                required int vehicleId,
              }) => ActiveGarageVehiclesCompanion.insert(
                slot: slot,
                vehicleId: vehicleId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActiveGarageVehiclesTable, ActiveGarageVehicle>(
                    table,
                  ),
                  $$ActiveGarageVehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vehicleId,
                        referencedTable: $$ActiveGarageVehiclesTableReferences
                            ._vehicleIdTable(db),
                        referencedColumn: $$ActiveGarageVehiclesTableReferences
                            ._vehicleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActiveGarageVehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveGarageVehiclesTable,
      ActiveGarageVehicle,
      $$ActiveGarageVehiclesTableFilterComposer,
      $$ActiveGarageVehiclesTableOrderingComposer,
      $$ActiveGarageVehiclesTableAnnotationComposer,
      $$ActiveGarageVehiclesTableCreateCompanionBuilder,
      $$ActiveGarageVehiclesTableUpdateCompanionBuilder,
      (ActiveGarageVehicle, $$ActiveGarageVehiclesTableReferences),
      ActiveGarageVehicle,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$FuelEntriesTableCreateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      required int vehicleId,
      required String entryDate,
      required int odometerKm,
      Value<int?> fuelMl,
      Value<int?> priceCents,
    });
typedef $$FuelEntriesTableUpdateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<String> entryDate,
      Value<int> odometerKm,
      Value<int?> fuelMl,
      Value<int?> priceCents,
    });

final class $$FuelEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FuelEntriesTable, FuelEntryRow> {
  $$FuelEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GarageVehiclesTable _vehicleIdTable(_$AppDatabase db) => db
      .garageVehicles
      .createAlias('fuel_entries__vehicle_id__garage_vehicles__id');

  $$GarageVehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$GarageVehiclesTableTableManager(
      $_db,
      $_db.garageVehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableFilterComposer({
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

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fuelMl => $composableBuilder(
    column: $table.fuelMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnFilters(column),
  );

  $$GarageVehiclesTableFilterComposer get vehicleId {
    final $$GarageVehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableFilterComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelMl => $composableBuilder(
    column: $table.fuelMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$GarageVehiclesTableOrderingComposer get vehicleId {
    final $$GarageVehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fuelMl =>
      $composableBuilder(column: $table.fuelMl, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => column,
  );

  $$GarageVehiclesTableAnnotationComposer get vehicleId {
    final $$GarageVehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelEntriesTable,
          FuelEntryRow,
          $$FuelEntriesTableFilterComposer,
          $$FuelEntriesTableOrderingComposer,
          $$FuelEntriesTableAnnotationComposer,
          $$FuelEntriesTableCreateCompanionBuilder,
          $$FuelEntriesTableUpdateCompanionBuilder,
          (FuelEntryRow, $$FuelEntriesTableReferences),
          FuelEntryRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$FuelEntriesTableTableManager(_$AppDatabase db, $FuelEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<int> odometerKm = const Value.absent(),
                Value<int?> fuelMl = const Value.absent(),
                Value<int?> priceCents = const Value.absent(),
              }) => FuelEntriesCompanion(
                id: id,
                vehicleId: vehicleId,
                entryDate: entryDate,
                odometerKm: odometerKm,
                fuelMl: fuelMl,
                priceCents: priceCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required String entryDate,
                required int odometerKm,
                Value<int?> fuelMl = const Value.absent(),
                Value<int?> priceCents = const Value.absent(),
              }) => FuelEntriesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                entryDate: entryDate,
                odometerKm: odometerKm,
                fuelMl: fuelMl,
                priceCents: priceCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FuelEntriesTable, FuelEntryRow>(table),
                  $$FuelEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vehicleId,
                        referencedTable: $$FuelEntriesTableReferences
                            ._vehicleIdTable(db),
                        referencedColumn: $$FuelEntriesTableReferences
                            ._vehicleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FuelEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelEntriesTable,
      FuelEntryRow,
      $$FuelEntriesTableFilterComposer,
      $$FuelEntriesTableOrderingComposer,
      $$FuelEntriesTableAnnotationComposer,
      $$FuelEntriesTableCreateCompanionBuilder,
      $$FuelEntriesTableUpdateCompanionBuilder,
      (FuelEntryRow, $$FuelEntriesTableReferences),
      FuelEntryRow,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$VehicleDocumentsTableCreateCompanionBuilder =
    VehicleDocumentsCompanion Function({
      Value<int> id,
      required int vehicleId,
      required String kind,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<bool> active,
    });
typedef $$VehicleDocumentsTableUpdateCompanionBuilder =
    VehicleDocumentsCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<String> kind,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<bool> active,
    });

final class $$VehicleDocumentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $VehicleDocumentsTable,
          VehicleDocumentRow
        > {
  $$VehicleDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GarageVehiclesTable _vehicleIdTable(_$AppDatabase db) => db
      .garageVehicles
      .createAlias('vehicle_documents__vehicle_id__garage_vehicles__id');

  $$GarageVehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$GarageVehiclesTableTableManager(
      $_db,
      $_db.garageVehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentPaymentsTable, List<DocumentPaymentRow>>
  _documentPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentPayments,
    aliasName: 'vehicle_documents__id__document_payments__document_id',
  );

  $$DocumentPaymentsTableProcessedTableManager get documentPaymentsRefs {
    final manager = $$DocumentPaymentsTableTableManager(
      $_db,
      $_db.documentPayments,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTable> {
  $$VehicleDocumentsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$GarageVehiclesTableFilterComposer get vehicleId {
    final $$GarageVehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableFilterComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentPaymentsRefs(
    Expression<bool> Function($$DocumentPaymentsTableFilterComposer f) f,
  ) {
    final $$DocumentPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPayments,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.documentPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTable> {
  $$VehicleDocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$GarageVehiclesTableOrderingComposer get vehicleId {
    final $$GarageVehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleDocumentsTable> {
  $$VehicleDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$GarageVehiclesTableAnnotationComposer get vehicleId {
    final $$GarageVehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.garageVehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarageVehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.garageVehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> documentPaymentsRefs<T extends Object>(
    Expression<T> Function($$DocumentPaymentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentPayments,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleDocumentsTable,
          VehicleDocumentRow,
          $$VehicleDocumentsTableFilterComposer,
          $$VehicleDocumentsTableOrderingComposer,
          $$VehicleDocumentsTableAnnotationComposer,
          $$VehicleDocumentsTableCreateCompanionBuilder,
          $$VehicleDocumentsTableUpdateCompanionBuilder,
          (VehicleDocumentRow, $$VehicleDocumentsTableReferences),
          VehicleDocumentRow,
          PrefetchHooks Function({bool vehicleId, bool documentPaymentsRefs})
        > {
  $$VehicleDocumentsTableTableManager(
    _$AppDatabase db,
    $VehicleDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => VehicleDocumentsCompanion(
                id: id,
                vehicleId: vehicleId,
                kind: kind,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required String kind,
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => VehicleDocumentsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                kind: kind,
                startDate: startDate,
                endDate: endDate,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehicleDocumentsTable, VehicleDocumentRow>(
                    table,
                  ),
                  $$VehicleDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleId = false, documentPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentPaymentsRefs) db.documentPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleId,
                            referencedTable: $$VehicleDocumentsTableReferences
                                ._vehicleIdTable(db),
                            referencedColumn: $$VehicleDocumentsTableReferences
                                ._vehicleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          VehicleDocumentRow,
                          $VehicleDocumentsTable,
                          DocumentPaymentRow,
                          $DocumentPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VehicleDocumentsTableReferences
                              ._documentPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleDocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentPaymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehicleDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleDocumentsTable,
      VehicleDocumentRow,
      $$VehicleDocumentsTableFilterComposer,
      $$VehicleDocumentsTableOrderingComposer,
      $$VehicleDocumentsTableAnnotationComposer,
      $$VehicleDocumentsTableCreateCompanionBuilder,
      $$VehicleDocumentsTableUpdateCompanionBuilder,
      (VehicleDocumentRow, $$VehicleDocumentsTableReferences),
      VehicleDocumentRow,
      PrefetchHooks Function({bool vehicleId, bool documentPaymentsRefs})
    >;
typedef $$DocumentPaymentsTableCreateCompanionBuilder =
    DocumentPaymentsCompanion Function({
      Value<int> id,
      required int documentId,
      required String dueDate,
      required int amountCents,
      Value<bool> paid,
    });
typedef $$DocumentPaymentsTableUpdateCompanionBuilder =
    DocumentPaymentsCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<String> dueDate,
      Value<int> amountCents,
      Value<bool> paid,
    });

final class $$DocumentPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentPaymentsTable,
          DocumentPaymentRow
        > {
  $$DocumentPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehicleDocumentsTable _documentIdTable(_$AppDatabase db) => db
      .vehicleDocuments
      .createAlias('document_payments__document_id__vehicle_documents__id');

  $$VehicleDocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$VehicleDocumentsTableTableManager(
      $_db,
      $_db.vehicleDocuments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentPaymentsTable> {
  $$DocumentPaymentsTableFilterComposer({
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

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleDocumentsTableFilterComposer get documentId {
    final $$VehicleDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.vehicleDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentPaymentsTable> {
  $$DocumentPaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleDocumentsTableOrderingComposer get documentId {
    final $$VehicleDocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.vehicleDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleDocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentPaymentsTable> {
  $$DocumentPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  $$VehicleDocumentsTableAnnotationComposer get documentId {
    final $$VehicleDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.vehicleDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentPaymentsTable,
          DocumentPaymentRow,
          $$DocumentPaymentsTableFilterComposer,
          $$DocumentPaymentsTableOrderingComposer,
          $$DocumentPaymentsTableAnnotationComposer,
          $$DocumentPaymentsTableCreateCompanionBuilder,
          $$DocumentPaymentsTableUpdateCompanionBuilder,
          (DocumentPaymentRow, $$DocumentPaymentsTableReferences),
          DocumentPaymentRow,
          PrefetchHooks Function({bool documentId})
        > {
  $$DocumentPaymentsTableTableManager(
    _$AppDatabase db,
    $DocumentPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<bool> paid = const Value.absent(),
              }) => DocumentPaymentsCompanion(
                id: id,
                documentId: documentId,
                dueDate: dueDate,
                amountCents: amountCents,
                paid: paid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required String dueDate,
                required int amountCents,
                Value<bool> paid = const Value.absent(),
              }) => DocumentPaymentsCompanion.insert(
                id: id,
                documentId: documentId,
                dueDate: dueDate,
                amountCents: amountCents,
                paid: paid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentPaymentsTable, DocumentPaymentRow>(
                    table,
                  ),
                  $$DocumentPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$DocumentPaymentsTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$DocumentPaymentsTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentPaymentsTable,
      DocumentPaymentRow,
      $$DocumentPaymentsTableFilterComposer,
      $$DocumentPaymentsTableOrderingComposer,
      $$DocumentPaymentsTableAnnotationComposer,
      $$DocumentPaymentsTableCreateCompanionBuilder,
      $$DocumentPaymentsTableUpdateCompanionBuilder,
      (DocumentPaymentRow, $$DocumentPaymentsTableReferences),
      DocumentPaymentRow,
      PrefetchHooks Function({bool documentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DiagnosticRecordsTableTableManager get diagnosticRecords =>
      $$DiagnosticRecordsTableTableManager(_db, _db.diagnosticRecords);
  $$ModulePreferencesTableTableManager get modulePreferences =>
      $$ModulePreferencesTableTableManager(_db, _db.modulePreferences);
  $$GarageVehiclesTableTableManager get garageVehicles =>
      $$GarageVehiclesTableTableManager(_db, _db.garageVehicles);
  $$ActiveGarageVehiclesTableTableManager get activeGarageVehicles =>
      $$ActiveGarageVehiclesTableTableManager(_db, _db.activeGarageVehicles);
  $$FuelEntriesTableTableManager get fuelEntries =>
      $$FuelEntriesTableTableManager(_db, _db.fuelEntries);
  $$VehicleDocumentsTableTableManager get vehicleDocuments =>
      $$VehicleDocumentsTableTableManager(_db, _db.vehicleDocuments);
  $$DocumentPaymentsTableTableManager get documentPayments =>
      $$DocumentPaymentsTableTableManager(_db, _db.documentPayments);
}
