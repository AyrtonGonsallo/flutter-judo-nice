import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        prenom TEXT,
        email TEXT,
        role TEXT,
        token TEXT
      )
    ''');
      },
    );


    return _db!;
  }

  static Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await getDatabase();
    await db.insert('utilisateur', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query('utilisateur', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> clearUser() async {
    final db = await getDatabase();
    await db.delete('utilisateur');
  }

  static Future<Map<String, dynamic>?> getUtilisateurLocal() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'utilisateur',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

}