import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/giao_dich.dart';

class GiaoDichDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertGiaoDich(GiaoDich giaoDich) async {
    final db = await _dbHelper.database;
    return await db.insert('GiaoDich', giaoDich.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<GiaoDich>> getGiaoDichByUserId(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'GiaoDich',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return GiaoDich.fromMap(maps[i]);
    });
  }

  // --- THÊM CÁC PHƯƠNG THỨC MỚI VÀO ĐÂY ---

  // Lấy tổng thu nhập của người dùng
  Future<double> getTotalIncomeByUserId(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM GiaoDich WHERE userId = ? AND type = ?',
      [userId, 'thu'],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // Lấy tổng chi tiêu của người dùng
  Future<double> getTotalExpenseByUserId(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM GiaoDich WHERE userId = ? AND type = ?',
      [userId, 'chi'],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // Phương thức để lấy tổng số dư hiện tại của người dùng (nếu bạn lưu totalAmount trong DB)
  // Lưu ý: Nếu totalAmount trong GiaoDich chỉ là tổng sau mỗi giao dịch,
  // thì cần hàm này để tính tổng số dư cuối cùng.
  // Tuy nhiên, việc tính toán total_income - total_expense là cách phổ biến hơn.
  Future<double> getCurrentBalanceByUserId(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT totalAmount FROM GiaoDich WHERE userId = ? ORDER BY id DESC LIMIT 1',
      [userId],
    );
    if (result.isNotEmpty && result.first['totalAmount'] != null) {
      return (result.first['totalAmount'] as num).toDouble();
    }
    // Nếu chưa có giao dịch, có thể trả về 0 hoặc số dư khởi đầu
    return 0.0;
  }

  // Thêm phương thức để xóa giao dịch (hữu ích cho việc quản lý)
  Future<int> deleteGiaoDich(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'GiaoDich',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Thêm phương thức để cập nhật giao dịch (hữu ích cho việc quản lý)
  Future<int> updateGiaoDich(GiaoDich giaoDich) async {
    final db = await _dbHelper.database;
    return await db.update(
      'GiaoDich',
      giaoDich.toMap(),
      where: 'id = ?',
      whereArgs: [giaoDich.id],
    );
  }
}