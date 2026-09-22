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

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, amount, type, category, date, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final int id;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String? description;
  const LedgerEntry(
      {required this.id,
      required this.amount,
      required this.type,
      required this.category,
      required this.date,
      this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
    };
  }

  LedgerEntry copyWith(
          {int? id,
          double? amount,
          String? type,
          String? category,
          DateTime? date,
          Value<String?> description = const Value.absent()}) =>
      LedgerEntry(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        date: date ?? this.date,
        description: description.present ? description.value : this.description,
      );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amount, type, category, date, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.date == this.date &&
          other.description == this.description);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String?> description;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    this.description = const Value.absent(),
  })  : amount = Value(amount),
        type = Value(type),
        category = Value(category),
        date = Value(date);
  static Insertable<LedgerEntry> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? type,
      Value<String>? category,
      Value<DateTime>? date,
      Value<String?>? description}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $HarvestListingsTable extends HarvestListings
    with TableInfo<$HarvestListingsTable, HarvestListing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarvestListingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropNameMeta =
      const VerificationMeta('cropName');
  @override
  late final GeneratedColumn<String> cropName = GeneratedColumn<String>(
      'crop_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('kg'));
  static const VerificationMeta _pricePerUnitMeta =
      const VerificationMeta('pricePerUnit');
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
      'price_per_unit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Grade A'));
  static const VerificationMeta _harvestDateMeta =
      const VerificationMeta('harvestDate');
  @override
  late final GeneratedColumn<DateTime> harvestDate = GeneratedColumn<DateTime>(
      'harvest_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _districtMeta =
      const VerificationMeta('district');
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
      'district', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmerNameMeta =
      const VerificationMeta('farmerName');
  @override
  late final GeneratedColumn<String> farmerName = GeneratedColumn<String>(
      'farmer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmerPhoneMeta =
      const VerificationMeta('farmerPhone');
  @override
  late final GeneratedColumn<String> farmerPhone = GeneratedColumn<String>(
      'farmer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSoldMeta = const VerificationMeta('isSold');
  @override
  late final GeneratedColumn<bool> isSold = GeneratedColumn<bool>(
      'is_sold', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_sold" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cropName,
        category,
        quantity,
        unit,
        pricePerUnit,
        grade,
        harvestDate,
        district,
        farmerName,
        farmerPhone,
        description,
        imagePath,
        isSold,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harvest_listings';
  @override
  VerificationContext validateIntegrity(Insertable<HarvestListing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_name')) {
      context.handle(_cropNameMeta,
          cropName.isAcceptableOrUnknown(data['crop_name']!, _cropNameMeta));
    } else if (isInserting) {
      context.missing(_cropNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
          _pricePerUnitMeta,
          pricePerUnit.isAcceptableOrUnknown(
              data['price_per_unit']!, _pricePerUnitMeta));
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('harvest_date')) {
      context.handle(
          _harvestDateMeta,
          harvestDate.isAcceptableOrUnknown(
              data['harvest_date']!, _harvestDateMeta));
    } else if (isInserting) {
      context.missing(_harvestDateMeta);
    }
    if (data.containsKey('district')) {
      context.handle(_districtMeta,
          district.isAcceptableOrUnknown(data['district']!, _districtMeta));
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('farmer_name')) {
      context.handle(
          _farmerNameMeta,
          farmerName.isAcceptableOrUnknown(
              data['farmer_name']!, _farmerNameMeta));
    } else if (isInserting) {
      context.missing(_farmerNameMeta);
    }
    if (data.containsKey('farmer_phone')) {
      context.handle(
          _farmerPhoneMeta,
          farmerPhone.isAcceptableOrUnknown(
              data['farmer_phone']!, _farmerPhoneMeta));
    } else if (isInserting) {
      context.missing(_farmerPhoneMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('is_sold')) {
      context.handle(_isSoldMeta,
          isSold.isAcceptableOrUnknown(data['is_sold']!, _isSoldMeta));
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
  HarvestListing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HarvestListing(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cropName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      pricePerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_unit'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade'])!,
      harvestDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}harvest_date'])!,
      district: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}district'])!,
      farmerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farmer_name'])!,
      farmerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farmer_phone'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      isSold: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_sold'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HarvestListingsTable createAlias(String alias) {
    return $HarvestListingsTable(attachedDatabase, alias);
  }
}

class HarvestListing extends DataClass implements Insertable<HarvestListing> {
  final String id;
  final String cropName;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String grade;
  final DateTime harvestDate;
  final String district;
  final String farmerName;
  final String farmerPhone;
  final String? description;
  final String? imagePath;
  final bool isSold;
  final DateTime createdAt;
  const HarvestListing(
      {required this.id,
      required this.cropName,
      required this.category,
      required this.quantity,
      required this.unit,
      required this.pricePerUnit,
      required this.grade,
      required this.harvestDate,
      required this.district,
      required this.farmerName,
      required this.farmerPhone,
      this.description,
      this.imagePath,
      required this.isSold,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crop_name'] = Variable<String>(cropName);
    map['category'] = Variable<String>(category);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['price_per_unit'] = Variable<double>(pricePerUnit);
    map['grade'] = Variable<String>(grade);
    map['harvest_date'] = Variable<DateTime>(harvestDate);
    map['district'] = Variable<String>(district);
    map['farmer_name'] = Variable<String>(farmerName);
    map['farmer_phone'] = Variable<String>(farmerPhone);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_sold'] = Variable<bool>(isSold);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HarvestListingsCompanion toCompanion(bool nullToAbsent) {
    return HarvestListingsCompanion(
      id: Value(id),
      cropName: Value(cropName),
      category: Value(category),
      quantity: Value(quantity),
      unit: Value(unit),
      pricePerUnit: Value(pricePerUnit),
      grade: Value(grade),
      harvestDate: Value(harvestDate),
      district: Value(district),
      farmerName: Value(farmerName),
      farmerPhone: Value(farmerPhone),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isSold: Value(isSold),
      createdAt: Value(createdAt),
    );
  }

  factory HarvestListing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HarvestListing(
      id: serializer.fromJson<String>(json['id']),
      cropName: serializer.fromJson<String>(json['cropName']),
      category: serializer.fromJson<String>(json['category']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      pricePerUnit: serializer.fromJson<double>(json['pricePerUnit']),
      grade: serializer.fromJson<String>(json['grade']),
      harvestDate: serializer.fromJson<DateTime>(json['harvestDate']),
      district: serializer.fromJson<String>(json['district']),
      farmerName: serializer.fromJson<String>(json['farmerName']),
      farmerPhone: serializer.fromJson<String>(json['farmerPhone']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isSold: serializer.fromJson<bool>(json['isSold']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropName': serializer.toJson<String>(cropName),
      'category': serializer.toJson<String>(category),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'pricePerUnit': serializer.toJson<double>(pricePerUnit),
      'grade': serializer.toJson<String>(grade),
      'harvestDate': serializer.toJson<DateTime>(harvestDate),
      'district': serializer.toJson<String>(district),
      'farmerName': serializer.toJson<String>(farmerName),
      'farmerPhone': serializer.toJson<String>(farmerPhone),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isSold': serializer.toJson<bool>(isSold),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HarvestListing copyWith(
          {String? id,
          String? cropName,
          String? category,
          double? quantity,
          String? unit,
          double? pricePerUnit,
          String? grade,
          DateTime? harvestDate,
          String? district,
          String? farmerName,
          String? farmerPhone,
          Value<String?> description = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          bool? isSold,
          DateTime? createdAt}) =>
      HarvestListing(
        id: id ?? this.id,
        cropName: cropName ?? this.cropName,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        grade: grade ?? this.grade,
        harvestDate: harvestDate ?? this.harvestDate,
        district: district ?? this.district,
        farmerName: farmerName ?? this.farmerName,
        farmerPhone: farmerPhone ?? this.farmerPhone,
        description: description.present ? description.value : this.description,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        isSold: isSold ?? this.isSold,
        createdAt: createdAt ?? this.createdAt,
      );
  HarvestListing copyWithCompanion(HarvestListingsCompanion data) {
    return HarvestListing(
      id: data.id.present ? data.id.value : this.id,
      cropName: data.cropName.present ? data.cropName.value : this.cropName,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      grade: data.grade.present ? data.grade.value : this.grade,
      harvestDate:
          data.harvestDate.present ? data.harvestDate.value : this.harvestDate,
      district: data.district.present ? data.district.value : this.district,
      farmerName:
          data.farmerName.present ? data.farmerName.value : this.farmerName,
      farmerPhone:
          data.farmerPhone.present ? data.farmerPhone.value : this.farmerPhone,
      description:
          data.description.present ? data.description.value : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isSold: data.isSold.present ? data.isSold.value : this.isSold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HarvestListing(')
          ..write('id: $id, ')
          ..write('cropName: $cropName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('grade: $grade, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('district: $district, ')
          ..write('farmerName: $farmerName, ')
          ..write('farmerPhone: $farmerPhone, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isSold: $isSold, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cropName,
      category,
      quantity,
      unit,
      pricePerUnit,
      grade,
      harvestDate,
      district,
      farmerName,
      farmerPhone,
      description,
      imagePath,
      isSold,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HarvestListing &&
          other.id == this.id &&
          other.cropName == this.cropName &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.pricePerUnit == this.pricePerUnit &&
          other.grade == this.grade &&
          other.harvestDate == this.harvestDate &&
          other.district == this.district &&
          other.farmerName == this.farmerName &&
          other.farmerPhone == this.farmerPhone &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.isSold == this.isSold &&
          other.createdAt == this.createdAt);
}

class HarvestListingsCompanion extends UpdateCompanion<HarvestListing> {
  final Value<String> id;
  final Value<String> cropName;
  final Value<String> category;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> pricePerUnit;
  final Value<String> grade;
  final Value<DateTime> harvestDate;
  final Value<String> district;
  final Value<String> farmerName;
  final Value<String> farmerPhone;
  final Value<String?> description;
  final Value<String?> imagePath;
  final Value<bool> isSold;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HarvestListingsCompanion({
    this.id = const Value.absent(),
    this.cropName = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.grade = const Value.absent(),
    this.harvestDate = const Value.absent(),
    this.district = const Value.absent(),
    this.farmerName = const Value.absent(),
    this.farmerPhone = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isSold = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HarvestListingsCompanion.insert({
    required String id,
    required String cropName,
    required String category,
    required double quantity,
    this.unit = const Value.absent(),
    required double pricePerUnit,
    this.grade = const Value.absent(),
    required DateTime harvestDate,
    required String district,
    required String farmerName,
    required String farmerPhone,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isSold = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cropName = Value(cropName),
        category = Value(category),
        quantity = Value(quantity),
        pricePerUnit = Value(pricePerUnit),
        harvestDate = Value(harvestDate),
        district = Value(district),
        farmerName = Value(farmerName),
        farmerPhone = Value(farmerPhone),
        createdAt = Value(createdAt);
  static Insertable<HarvestListing> custom({
    Expression<String>? id,
    Expression<String>? cropName,
    Expression<String>? category,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? pricePerUnit,
    Expression<String>? grade,
    Expression<DateTime>? harvestDate,
    Expression<String>? district,
    Expression<String>? farmerName,
    Expression<String>? farmerPhone,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<bool>? isSold,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropName != null) 'crop_name': cropName,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (grade != null) 'grade': grade,
      if (harvestDate != null) 'harvest_date': harvestDate,
      if (district != null) 'district': district,
      if (farmerName != null) 'farmer_name': farmerName,
      if (farmerPhone != null) 'farmer_phone': farmerPhone,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (isSold != null) 'is_sold': isSold,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HarvestListingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cropName,
      Value<String>? category,
      Value<double>? quantity,
      Value<String>? unit,
      Value<double>? pricePerUnit,
      Value<String>? grade,
      Value<DateTime>? harvestDate,
      Value<String>? district,
      Value<String>? farmerName,
      Value<String>? farmerPhone,
      Value<String?>? description,
      Value<String?>? imagePath,
      Value<bool>? isSold,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return HarvestListingsCompanion(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      grade: grade ?? this.grade,
      harvestDate: harvestDate ?? this.harvestDate,
      district: district ?? this.district,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isSold: isSold ?? this.isSold,
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
    if (cropName.present) {
      map['crop_name'] = Variable<String>(cropName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (harvestDate.present) {
      map['harvest_date'] = Variable<DateTime>(harvestDate.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (farmerName.present) {
      map['farmer_name'] = Variable<String>(farmerName.value);
    }
    if (farmerPhone.present) {
      map['farmer_phone'] = Variable<String>(farmerPhone.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isSold.present) {
      map['is_sold'] = Variable<bool>(isSold.value);
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
    return (StringBuffer('HarvestListingsCompanion(')
          ..write('id: $id, ')
          ..write('cropName: $cropName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('grade: $grade, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('district: $district, ')
          ..write('farmerName: $farmerName, ')
          ..write('farmerPhone: $farmerPhone, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isSold: $isSold, ')
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
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $HarvestListingsTable harvestListings =
      $HarvestListingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [scanResults, crops, tasks, ledgerEntries, harvestListings];
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
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<int> id,
  required double amount,
  required String type,
  required String category,
  required DateTime date,
  Value<String?> description,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<int> id,
  Value<double> amount,
  Value<String> type,
  Value<String> category,
  Value<DateTime> date,
  Value<String?> description,
});

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> description = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            amount: amount,
            type: type,
            category: category,
            date: date,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String type,
            required String category,
            required DateTime date,
            Value<String?> description = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            amount: amount,
            type: type,
            category: category,
            date: date,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LedgerEntriesTable, LedgerEntry>(table),
                    BaseReferences<_$AppDatabase, $LedgerEntriesTable,
                        LedgerEntry>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()>;
typedef $$HarvestListingsTableCreateCompanionBuilder = HarvestListingsCompanion
    Function({
  required String id,
  required String cropName,
  required String category,
  required double quantity,
  Value<String> unit,
  required double pricePerUnit,
  Value<String> grade,
  required DateTime harvestDate,
  required String district,
  required String farmerName,
  required String farmerPhone,
  Value<String?> description,
  Value<String?> imagePath,
  Value<bool> isSold,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$HarvestListingsTableUpdateCompanionBuilder = HarvestListingsCompanion
    Function({
  Value<String> id,
  Value<String> cropName,
  Value<String> category,
  Value<double> quantity,
  Value<String> unit,
  Value<double> pricePerUnit,
  Value<String> grade,
  Value<DateTime> harvestDate,
  Value<String> district,
  Value<String> farmerName,
  Value<String> farmerPhone,
  Value<String?> description,
  Value<String?> imagePath,
  Value<bool> isSold,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HarvestListingsTableFilterComposer
    extends Composer<_$AppDatabase, $HarvestListingsTable> {
  $$HarvestListingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerName => $composableBuilder(
      column: $table.farmerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerPhone => $composableBuilder(
      column: $table.farmerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSold => $composableBuilder(
      column: $table.isSold, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HarvestListingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HarvestListingsTable> {
  $$HarvestListingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerName => $composableBuilder(
      column: $table.farmerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerPhone => $composableBuilder(
      column: $table.farmerPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSold => $composableBuilder(
      column: $table.isSold, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HarvestListingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarvestListingsTable> {
  $$HarvestListingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropName =>
      $composableBuilder(column: $table.cropName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get harvestDate => $composableBuilder(
      column: $table.harvestDate, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get farmerName => $composableBuilder(
      column: $table.farmerName, builder: (column) => column);

  GeneratedColumn<String> get farmerPhone => $composableBuilder(
      column: $table.farmerPhone, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isSold =>
      $composableBuilder(column: $table.isSold, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HarvestListingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HarvestListingsTable,
    HarvestListing,
    $$HarvestListingsTableFilterComposer,
    $$HarvestListingsTableOrderingComposer,
    $$HarvestListingsTableAnnotationComposer,
    $$HarvestListingsTableCreateCompanionBuilder,
    $$HarvestListingsTableUpdateCompanionBuilder,
    (
      HarvestListing,
      BaseReferences<_$AppDatabase, $HarvestListingsTable, HarvestListing>
    ),
    HarvestListing,
    PrefetchHooks Function()> {
  $$HarvestListingsTableTableManager(
      _$AppDatabase db, $HarvestListingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarvestListingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarvestListingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarvestListingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cropName = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> pricePerUnit = const Value.absent(),
            Value<String> grade = const Value.absent(),
            Value<DateTime> harvestDate = const Value.absent(),
            Value<String> district = const Value.absent(),
            Value<String> farmerName = const Value.absent(),
            Value<String> farmerPhone = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isSold = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HarvestListingsCompanion(
            id: id,
            cropName: cropName,
            category: category,
            quantity: quantity,
            unit: unit,
            pricePerUnit: pricePerUnit,
            grade: grade,
            harvestDate: harvestDate,
            district: district,
            farmerName: farmerName,
            farmerPhone: farmerPhone,
            description: description,
            imagePath: imagePath,
            isSold: isSold,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cropName,
            required String category,
            required double quantity,
            Value<String> unit = const Value.absent(),
            required double pricePerUnit,
            Value<String> grade = const Value.absent(),
            required DateTime harvestDate,
            required String district,
            required String farmerName,
            required String farmerPhone,
            Value<String?> description = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isSold = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              HarvestListingsCompanion.insert(
            id: id,
            cropName: cropName,
            category: category,
            quantity: quantity,
            unit: unit,
            pricePerUnit: pricePerUnit,
            grade: grade,
            harvestDate: harvestDate,
            district: district,
            farmerName: farmerName,
            farmerPhone: farmerPhone,
            description: description,
            imagePath: imagePath,
            isSold: isSold,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HarvestListingsTable, HarvestListing>(table),
                    BaseReferences<_$AppDatabase, $HarvestListingsTable,
                        HarvestListing>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HarvestListingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HarvestListingsTable,
    HarvestListing,
    $$HarvestListingsTableFilterComposer,
    $$HarvestListingsTableOrderingComposer,
    $$HarvestListingsTableAnnotationComposer,
    $$HarvestListingsTableCreateCompanionBuilder,
    $$HarvestListingsTableUpdateCompanionBuilder,
    (
      HarvestListing,
      BaseReferences<_$AppDatabase, $HarvestListingsTable, HarvestListing>
    ),
    HarvestListing,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanResultsTableTableManager get scanResults =>
      $$ScanResultsTableTableManager(_db, _db.scanResults);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db, _db.crops);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$HarvestListingsTableTableManager get harvestListings =>
      $$HarvestListingsTableTableManager(_db, _db.harvestListings);
}
