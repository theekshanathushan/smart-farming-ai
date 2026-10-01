import 'package:drift/drift.dart';

@DataClassName('ChatMessageEntry')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get message => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get cropType => text().nullable()();
  TextColumn get sessionId => text().nullable()();
}
