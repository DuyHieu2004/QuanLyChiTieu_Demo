import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/danh_muc.dart';

class DanhMucDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertDanhMuc(DanhMuc danhMuc) async {
    final db = await _dbHelper.database;
    return await db.insert('DanhMuc', danhMuc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DanhMuc>> getAllDanhMucs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('DanhMuc');
    return List.generate(maps.length, (i) {
      return DanhMuc.fromMap(maps[i]);
    });
  }

  Future<List<DanhMuc>> getDanhMucsByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DanhMuc',
      where: 'categoryType = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) {
      return DanhMuc.fromMap(maps[i]);
    });
  }
// Add more methods as needed (update, delete, get by parentId, etc.)
}