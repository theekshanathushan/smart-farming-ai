// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScanResultsTable extends ScanResults
    with TableInfo<$ScanResultsTable, ScanResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _predictedLabelMeta =
      const VerificationMeta('predictedLabel');
  @override
  late final GeneratedColumn<String> predictedLabel = GeneratedColumn<String>(
      'predicted_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, imagePath, predictedLabel, confidence, timestamp, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_results';
  @override
  VerificationContext validateIntegrity(Insertable<ScanResult> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('predicted_label')) {
      context.handle(
          _predictedLabelMeta,
          predictedLabel.isAcceptableOrUnknown(
              data['predicted_label']!, _predictedLabelMeta));
    } else if (isInserting) {
      context.missing(_predictedLabelMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanResult(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      predictedLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}predicted_label'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $ScanResultsTable createAlias(String alias) {
    return $ScanResultsTable(attachedDatabase, alias);
  }
}

class ScanResult extends DataClass implements Insertable<ScanResult> {
  final int id;
  final String imagePath;
  final String predictedLabel;
  final double confidence;
  final DateTime timestamp;
  final String? notes;
  const ScanResult(
      {required this.id,
      required this.imagePath,
      required this.predictedLabel,
      required this.confidence,
      required this.timestamp,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    map['predicted_label'] = Variable<String>(predictedLabel);
    map['confidence'] = Variable<double>(confidence);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ScanResultsCompanion toCompanion(bool nullToAbsent) {
    return ScanResultsCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      predictedLabel: Value(predictedLabel),
      confidence: Value(confidence),
      timestamp: Value(timestamp),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory ScanResult.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanResult(
      id: serializer.fromJson<int>(json['id']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      predictedLabel: serializer.fromJson<String>(json['predictedLabel']),
      confidence: serializer.fromJson<double>(json['confidence']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imagePath': serializer.toJson<String>(imagePath),
      'predictedLabel': serializer.toJson<String>(predictedLabel),
      'confidence': serializer.toJson<double>(confidence),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ScanResult copyWith(
          {int? id,
          String? imagePath,
          String? predictedLabel,
          double? confidence,
          DateTime? timestamp,
          Value<String?> notes = const Value.absent()}) =>
      ScanResult(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        predictedLabel: predictedLabel ?? this.predictedLabel,
        confidence: confidence ?? this.confidence,
        timestamp: timestamp ?? this.timestamp,
        notes: notes.present ? notes.value : this.notes,
      );
  ScanResult copyWithCompanion(ScanResultsCompanion data) {
    return ScanResult(
      id: data.id.present ? data.id.value : this.id,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      predictedLabel: data.predictedLabel.present
          ? data.predictedLabel.value
          : this.predictedLabel,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanResult(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('predictedLabel: $predictedLabel, ')
          ..write('confidence: $confidence, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, imagePath, predictedLabel, confidence, timestamp, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanResult &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.predictedLabel == this.predictedLabel &&
          other.confidence == this.confidence &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes);
}

class ScanResultsCompanion extends UpdateCompanion<ScanResult> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<String> predictedLabel;
  final Value<double> confidence;
  final Value<DateTime> timestamp;
  final Value<String?> notes;
  const ScanResultsCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.predictedLabel = const Value.absent(),
    this.confidence = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ScanResultsCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    required String predictedLabel,
    required double confidence,
    required DateTime timestamp,
    this.notes = const Value.absent(),
  })  : imagePath = Value(imagePath),
        predictedLabel = Value(predictedLabel),
        confidence = Value(confidence),
        timestamp = Value(timestamp);
  static Insertable<ScanResult> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<String>? predictedLabel,
    Expression<double>? confidence,
    Expression<DateTime>? timestamp,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (predictedLabel != null) 'predicted_label': predictedLabel,
      if (confidence != null) 'confidence': confidence,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
    });
  }

  ScanResultsCompanion copyWith(
      {Value<int>? id,
      Value<String>? imagePath,
      Value<String>? predictedLabel,
      Value<double>? confidence,
      Value<DateTime>? timestamp,
      Value<String?>? notes}) {
    return ScanResultsCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      predictedLabel: predictedLabel ?? this.predictedLabel,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (predictedLabel.present) {
      map['predicted_label'] = Variable<String>(predictedLabel.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanResultsCompanion(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('predictedLabel: $predictedLabel, ')
          ..write('confidence: $confidence, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CropsTable extends Crops with TableInfo<$CropsTable, Crop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varietyMeta =
      const VerificationMeta('variety');
  @override
  late final GeneratedColumn<String> variety = GeneratedColumn<String>(
      'variety', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _plantDateMeta =
      const VerificationMeta('plantDate');
  @override
  late final GeneratedColumn<DateTime> plantDate = GeneratedColumn<DateTime>(
      'plant_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expectedHarvestDateMeta =
      const VerificationMeta('expectedHarvestDate');
  @override
  late final GeneratedColumn<DateTime> expectedHarvestDate =
      GeneratedColumn<DateTime>('expected_harvest_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<double> area = GeneratedColumn<double>(
      'area', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _areaUnitMeta =
      const VerificationMeta('areaUnit');
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
      'area_unit', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('acres'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        variety,
        plantDate,
        expectedHarvestDate,
        area,
        areaUnit,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crops';
  @override
  VerificationContext validateIntegrity(Insertable<Crop> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('variety')) {
      context.handle(_varietyMeta,
          variety.isAcceptableOrUnknown(data['variety']!, _varietyMeta));
    }
    if (data.containsKey('plant_date')) {
      context.handle(_plantDateMeta,
          plantDate.isAcceptableOrUnknown(data['plant_date']!, _plantDateMeta));
    } else if (isInserting) {
      context.missing(_plantDateMeta);
    }
    if (data.containsKey('expected_harvest_date')) {
      context.handle(
          _expectedHarvestDateMeta,
          expectedHarvestDate.isAcceptableOrUnknown(
              data['expected_harvest_date']!, _expectedHarvestDateMeta));
    }
    if (data.containsKey('area')) {
      context.handle(
          _areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    }
    if (data.containsKey('area_unit')) {
      context.handle(_areaUnitMeta,
          areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Crop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Crop(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      variety: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variety']),
      plantDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}plant_date'])!,
      expectedHarvestDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}expected_harvest_date']),
      area: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area']),
      areaUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_unit']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CropsTable createAlias(String alias) {
    return $CropsTable(attachedDatabase, alias);
  }
}

class Crop extends DataClass implements Insertable<Crop> {
  final String id;
  final String name;
  final String? variety;
  final DateTime plantDate;
  final DateTime? expectedHarvestDate;
  final double? area;
  final String? areaUnit;
  final DateTime createdAt;
  const Crop(
      {required this.id,
      required this.name,
      this.variety,
      required this.plantDate,
      this.expectedHarvestDate,
      this.area,
      this.areaUnit,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || variety != null) {
      map['variety'] = Variable<String>(variety);
    }
    map['plant_date'] = Variable<DateTime>(plantDate);
    if (!nullToAbsent || expectedHarvestDate != null) {
      map['expected_harvest_date'] = Variable<DateTime>(expectedHarvestDate);
    }
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<double>(area);
    }
    if (!nullToAbsent || areaUnit != null) {
      map['area_unit'] = Variable<String>(areaUnit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CropsCompanion toCompanion(bool nullToAbsent) {
    return CropsCompanion(
      id: Value(id),
      name: Value(name),
      variety: variety == null && nullToAbsent
          ? const Value.absent()
          : Value(variety),
      plantDate: Value(plantDate),
      expectedHarvestDate: expectedHarvestDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedHarvestDate),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      areaUnit: areaUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(areaUnit),
      createdAt: Value(createdAt),
    );
  }

  factory Crop.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Crop(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      variety: serializer.fromJson<String?>(json['variety']),
      plantDate: serializer.fromJson<DateTime>(json['plantDate']),
      expectedHarvestDate:
          serializer.fromJson<DateTime?>(json['expectedHarvestDate']),
      area: serializer.fromJson<double?>(json['area']),
      areaUnit: serializer.fromJson<String?>(json['areaUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'variety': serializer.toJson<String?>(variety),
      'plantDate': serializer.toJson<DateTime>(plantDate),
      'expectedHarvestDate': serializer.toJson<DateTime?>(expectedHarvestDate),
      'area': serializer.toJson<double?>(area),
      'areaUnit': serializer.toJson<String?>(areaUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Crop copyWith(
          {String? id,
          String? name,
          Value<String?> variety = const Value.absent(),
          DateTime? plantDate,
          Value<DateTime?> expectedHarvestDate = const Value.absent(),
          Value<double?> area = const Value.absent(),
          Value<String?> areaUnit = const Value.absent(),
          DateTime? createdAt}) =>
      Crop(
        id: id ?? this.id,
        name: name ?? this.name,
        variety: variety.present ? variety.value : this.variety,
        plantDate: plantDate ?? this.plantDate,
        expectedHarvestDate: expectedHarvestDate.present
            ? expectedHarvestDate.value
            : this.expectedHarvestDate,
        area: area.present ? area.value : this.area,
        areaUnit: areaUnit.present ? areaUnit.value : this.areaUnit,
        createdAt: createdAt ?? this.createdAt,
      );
  Crop copyWithCompanion(CropsCompanion data) {
    return Crop(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      variety: data.variety.present ? data.variety.value : this.variety,
      plantDate: data.plantDate.present ? data.plantDate.value : this.plantDate,
      expectedHarvestDate: data.expectedHarvestDate.present
          ? data.expectedHarvestDate.value
          : this.expectedHarvestDate,
      area: data.area.present ? data.area.value : this.area,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Crop(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('variety: $variety, ')
          ..write('plantDate: $plantDate, ')
          ..write('expectedHarvestDate: $expectedHarvestDate, ')
          ..write('area: $area, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, variety, plantDate,
      expectedHarvestDate, area, areaUnit, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crop &&
          other.id == this.id &&
          other.name == this.name &&
          other.variety == this.variety &&
          other.plantDate == this.plantDate &&
          other.expectedHarvestDate == this.expectedHarvestDate &&
          other.area == this.area &&
          other.areaUnit == this.areaUnit &&
          other.createdAt == this.createdAt);
}

class CropsCompanion extends UpdateCompanion<Crop> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> variety;
  final Value<DateTime> plantDate;
  final Value<DateTime?> expectedHarvestDate;
  final Value<double?> area;
  final Value<String?> areaUnit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CropsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.variety = const Value.absent(),
    this.plantDate = const Value.absent(),
    this.expectedHarvestDate = const Value.absent(),
    this.area = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropsCompanion.insert({
    required String id,
    required String name,
    this.variety = const Value.absent(),
    required DateTime plantDate,
    this.expectedHarvestDate = const Value.absent(),
    this.area = const Value.absent(),
    this.areaUnit = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        plantDate = Value(plantDate),
        createdAt = Value(createdAt);
  static Insertable<Crop> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? variety,
    Expression<DateTime>? plantDate,
    Expression<DateTime>? expectedHarvestDate,
    Expression<double>? area,
    Expression<String>? areaUnit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (variety != null) 'variety': variety,
      if (plantDate != null) 'plant_date': plantDate,
      if (expectedHarvestDate != null)
        'expected_harvest_date': expectedHarvestDate,
      if (area != null) 'area': area,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? variety,
      Value<DateTime>? plantDate,
      Value<DateTime?>? expectedHarvestDate,
      Value<double?>? area,
      Value<String?>? areaUnit,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CropsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      plantDate: plantDate ?? this.plantDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (variety.present) {
      map['variety'] = Variable<String>(variety.value);
    }
    if (plantDate.present) {
      map['plant_date'] = Variable<DateTime>(plantDate.value);
    }
    if (expectedHarvestDate.present) {
      map['expected_harvest_date'] =
          Variable<DateTime>(expectedHarvestDate.value);
    }
    if (area.present) {
      map['area'] = Variable<double>(area.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('variety: $variety, ')
          ..write('plantDate: $plantDate, ')
          ..write('expectedHarvestDate: $expectedHarvestDate, ')
          ..write('area: $area, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
      'crop_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES crops (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cropId, title, description, dueDate, isCompleted, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(_cropIdMeta,
          cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta));
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cropId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String cropId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  const Task(
      {required this.id,
      required this.cropId,
      required this.title,
      this.description,
      required this.dueDate,
      required this.isCompleted,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crop_id'] = Variable<String>(cropId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      cropId: Value(cropId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: Value(dueDate),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      cropId: serializer.fromJson<String>(json['cropId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropId': serializer.toJson<String>(cropId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith(
          {String? id,
          String? cropId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? dueDate,
          bool? isCompleted,
          DateTime? createdAt}) =>
      Task(
        id: id ?? this.id,
        cropId: cropId ?? this.cropId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, cropId, title, description, dueDate, isCompleted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.cropId == this.cropId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> cropId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> dueDate;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.cropId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String cropId,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueDate,
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cropId = Value(cropId),
        title = Value(title),
        dueDate = Value(dueDate),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? cropId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropId != null) 'crop_id': cropId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? cropId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? dueDate,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanResultsTable scanResults = $ScanResultsTable(this);
  late final $CropsTable crops = $CropsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [scanResults, crops, tasks];
}

typedef $$ScanResultsTableCreateCompanionBuilder = ScanResultsCompanion
    Function({
  Value<int> id,
  required String imagePath,
  required String predictedLabel,
  required double confidence,
  required DateTime timestamp,
  Value<String?> notes,
});
typedef $$ScanResultsTableUpdateCompanionBuilder = ScanResultsCompanion
    Function({
  Value<int> id,
  Value<String> imagePath,
  Value<String> predictedLabel,
  Value<double> confidence,
  Value<DateTime> timestamp,
  Value<String?> notes,
});

class $$ScanResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanResultsTable> {
  $$ScanResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get predictedLabel => $composableBuilder(
      column: $table.predictedLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ScanResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanResultsTable> {
  $$ScanResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get predictedLabel => $composableBuilder(
      column: $table.predictedLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ScanResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanResultsTable> {
  $$ScanResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get predictedLabel => $composableBuilder(
      column: $table.predictedLabel, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ScanResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanResultsTable,
    ScanResult,
    $$ScanResultsTableFilterComposer,
    $$ScanResultsTableOrderingComposer,
    $$ScanResultsTableAnnotationComposer,
    $$ScanResultsTableCreateCompanionBuilder,
    $$ScanResultsTableUpdateCompanionBuilder,
    (ScanResult, BaseReferences<_$AppDatabase, $ScanResultsTable, ScanResult>),
    ScanResult,
    PrefetchHooks Function()> {
  $$ScanResultsTableTableManager(_$AppDatabase db, $ScanResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<String> predictedLabel = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              ScanResultsCompanion(
            id: id,
            imagePath: imagePath,
            predictedLabel: predictedLabel,
            confidence: confidence,
            timestamp: timestamp,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String imagePath,
            required String predictedLabel,
            required double confidence,
            required DateTime timestamp,
            Value<String?> notes = const Value.absent(),
          }) =>
              ScanResultsCompanion.insert(
            id: id,
            imagePath: imagePath,
            predictedLabel: predictedLabel,
            confidence: confidence,
            timestamp: timestamp,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ScanResultsTable, ScanResult>(table),
                    BaseReferences<_$AppDatabase, $ScanResultsTable,
                        ScanResult>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanResultsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanResultsTable,
    ScanResult,
    $$ScanResultsTableFilterComposer,
    $$ScanResultsTableOrderingComposer,
    $$ScanResultsTableAnnotationComposer,
    $$ScanResultsTableCreateCompanionBuilder,
    $$ScanResultsTableUpdateCompanionBuilder,
    (ScanResult, BaseReferences<_$AppDatabase, $ScanResultsTable, ScanResult>),
    ScanResult,
    PrefetchHooks Function()>;
typedef $$CropsTableCreateCompanionBuilder = CropsCompanion Function({
  required String id,
  required String name,
  Value<String?> variety,
  required DateTime plantDate,
  Value<DateTime?> expectedHarvestDate,
  Value<double?> area,
  Value<String?> areaUnit,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CropsTableUpdateCompanionBuilder = CropsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> variety,
  Value<DateTime> plantDate,
  Value<DateTime?> expectedHarvestDate,
  Value<double?> area,
  Value<String?> areaUnit,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CropsTableReferences
    extends BaseReferences<_$AppDatabase, $CropsTable, Crop> {
  $$CropsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: 'crops__id__tasks__crop_id');

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.cropId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CropsTableFilterComposer extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plantDate => $composableBuilder(
      column: $table.plantDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaUnit => $composableBuilder(
      column: $table.areaUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.cropId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CropsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plantDate => $composableBuilder(
      column: $table.plantDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaUnit => $composableBuilder(
      column: $table.areaUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get variety =>
      $composableBuilder(column: $table.variety, builder: (column) => column);

  GeneratedColumn<DateTime> get plantDate =>
      $composableBuilder(column: $table.plantDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedHarvestDate => $composableBuilder(
      column: $table.expectedHarvestDate, builder: (column) => column);

  GeneratedColumn<double> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.cropId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CropsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CropsTable,
    Crop,
    $$CropsTableFilterComposer,
    $$CropsTableOrderingComposer,
    $$CropsTableAnnotationComposer,
    $$CropsTableCreateCompanionBuilder,
    $$CropsTableUpdateCompanionBuilder,
    (Crop, $$CropsTableReferences),
    Crop,
    PrefetchHooks Function({bool tasksRefs})> {
  $$CropsTableTableManager(_$AppDatabase db, $CropsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> variety = const Value.absent(),
            Value<DateTime> plantDate = const Value.absent(),
            Value<DateTime?> expectedHarvestDate = const Value.absent(),
            Value<double?> area = const Value.absent(),
            Value<String?> areaUnit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropsCompanion(
            id: id,
            name: name,
            variety: variety,
            plantDate: plantDate,
            expectedHarvestDate: expectedHarvestDate,
            area: area,
            areaUnit: areaUnit,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> variety = const Value.absent(),
            required DateTime plantDate,
            Value<DateTime?> expectedHarvestDate = const Value.absent(),
            Value<double?> area = const Value.absent(),
            Value<String?> areaUnit = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CropsCompanion.insert(
            id: id,
            name: name,
            variety: variety,
            plantDate: plantDate,
            expectedHarvestDate: expectedHarvestDate,
            area: area,
            areaUnit: areaUnit,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CropsTable, Crop>(table),
                    $$CropsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Crop, $CropsTable, Task>(
                        currentTable: table,
                        referencedTable:
                            $$CropsTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CropsTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cropId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CropsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CropsTable,
    Crop,
    $$CropsTableFilterComposer,
    $$CropsTableOrderingComposer,
    $$CropsTableAnnotationComposer,
    $$CropsTableCreateCompanionBuilder,
    $$CropsTableUpdateCompanionBuilder,
    (Crop, $$CropsTableReferences),
    Crop,
    PrefetchHooks Function({bool tasksRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String cropId,
  required String title,
  Value<String?> description,
  required DateTime dueDate,
  Value<bool> isCompleted,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> cropId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> dueDate,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CropsTable _cropIdTable(_$AppDatabase db) =>
      db.crops.createAlias('tasks__crop_id__crops__id');

  $$CropsTableProcessedTableManager get cropId {
    final $_column = $_itemColumn<String>('crop_id')!;

    final manager = $$CropsTableTableManager($_db, $_db.crops)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cropIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CropsTableFilterComposer get cropId {
    final $$CropsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cropId,
        referencedTable: $db.crops,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CropsTableFilterComposer(
              $db: $db,
              $table: $db.crops,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CropsTableOrderingComposer get cropId {
    final $$CropsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cropId,
        referencedTable: $db.crops,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CropsTableOrderingComposer(
              $db: $db,
              $table: $db.crops,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CropsTableAnnotationComposer get cropId {
    final $$CropsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cropId,
        referencedTable: $db.crops,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CropsTableAnnotationComposer(
              $db: $db,
              $table: $db.crops,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool cropId})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cropId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            cropId: cropId,
            title: title,
            description: description,
            dueDate: dueDate,
            isCompleted: isCompleted,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cropId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime dueDate,
            Value<bool> isCompleted = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            cropId: cropId,
            title: title,
            description: description,
            dueDate: dueDate,
            isCompleted: isCompleted,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TasksTable, Task>(table),
                    $$TasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cropId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (cropId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cropId,
                    referencedTable: $$TasksTableReferences._cropIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._cropIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool cropId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanResultsTableTableManager get scanResults =>
      $$ScanResultsTableTableManager(_db, _db.scanResults);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db, _db.crops);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
