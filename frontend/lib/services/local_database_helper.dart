import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance_scans.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE pending_scans (
  id $idType,
  qr_code $textType,
  scanned_at $textType
)
''');
  }

  Future<void> insertPendingScan(String qrCode) async {
    final db = await instance.database;
    await db.insert('pending_scans', {
      'qr_code': qrCode,
      'scanned_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingScans() async {
    final db = await instance.database;
    return await db.query('pending_scans', orderBy: 'scanned_at ASC');
  }

  Future<void> clearPendingScans() async {
    final db = await instance.database;
    await db.delete('pending_scans');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
