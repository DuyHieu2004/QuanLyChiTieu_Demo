import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/user.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('Users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> login(String username, String password) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}