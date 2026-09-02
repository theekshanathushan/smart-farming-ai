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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanResultsTable scanResults = $ScanResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [scanResults];
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanResultsTableTableManager get scanResults =>
      $$ScanResultsTableTableManager(_db, _db.scanResults);
}
