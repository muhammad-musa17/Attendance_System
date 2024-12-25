import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteExistingDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'attendance_system.db');
  await deleteDatabase(path);
}
