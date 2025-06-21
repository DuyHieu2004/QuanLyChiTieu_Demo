import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "personal_finance.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Đảm bảo gọi onUpgrade nếu có
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        """
      CREATE TABLE Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        fullName TEXT,
        gender TEXT,
        illustration TEXT
      )
      """
    );

    await db.execute(
        """
      CREATE TABLE GiaoDich(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        type TEXT, -- thu or chi
        amount REAL,
        totalAmount REAL,
        description TEXT,
        category TEXT,
        illustration TEXT,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES Users(id)
      )
      """
    );

    await db.execute(
        """
      CREATE TABLE DanhMuc(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        parentId INTEGER,
        categoryType TEXT, -- e.g., 'thu' or 'chi'
        FOREIGN KEY (parentId) REFERENCES DanhMuc(id)
      )
      """
    );
    // Gọi hàm chèn dữ liệu mẫu, hàm này sẽ chèn cả Users nếu bạn thêm vào đó
    _insertInitialData(db);
  }

  // Hàm chèn dữ liệu mẫu
  Future<void> _insertInitialData(Database db) async {
    // --- BẮT ĐẦU CHÈN DỮ LIỆU VÀO BẢNG USERS ---
    // Người dùng mẫu 1 (đã có trong code gốc của bạn)
    final int userId1 = await db.insert('Users', {
      'username': 'test',
      'password': '123', // Trong thực tế, hãy hash mật khẩu!
      'fullName': 'Nguyễn Văn Test',
      'gender': 'Nam',
      'illustration': null
    }, conflictAlgorithm: ConflictAlgorithm.ignore); // Dùng ignore để tránh lỗi nếu đã có

    print('User "test" inserted with ID: $userId1');

    // Người dùng mẫu 2
    final int userId2 = await db.insert('Users', {
      'username': 'admin',
      'password': 'admin_pass',
      'fullName': 'Nguyễn Thị Admin',
      'gender': 'Nữ',
      'illustration': null
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    print('User "admin" inserted with ID: $userId2');


    // Người dùng mẫu 3
    final int userId3 = await db.insert('Users', {
      'username': 'user_a',
      'password': 'passwordA',
      'fullName': 'Trần Văn A',
      'gender': 'Nam',
      'illustration': null
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    print('User "user_a" inserted with ID: $userId3');

    // Người dùng mẫu 4
    final int userId4 = await db.insert('Users', {
      'username': 'user_b',
      'password': 'passwordB',
      'fullName': 'Phạm Thị B',
      'gender': 'Nữ',
      'illustration': null // Có thể để null nếu không có ảnh
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    print('User "user_b" inserted with ID: $userId4');

    // --- KẾT THÚC CHÈN DỮ LIỆU VÀO BẢNG USERS ---


    // Chèn dữ liệu vào bảng DanhMuc (không thay đổi)
    await db.insert('DanhMuc', {'name': 'Lương', 'categoryType': 'thu'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Thưởng', 'categoryType': 'thu'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Đầu tư', 'categoryType': 'thu'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Khác (Thu)', 'categoryType': 'thu'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('DanhMuc', {'name': 'Ăn uống', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Đi lại', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Học tập', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Giải trí', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Y tế', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Nhà cửa', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Mua sắm', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('DanhMuc', {'name': 'Khác (Chi)', 'categoryType': 'chi'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Chèn dữ liệu vào bảng GiaoDich (sử dụng userId từ User đã chèn, ví dụ dùng userId1 của 'test')
    final List<Map<String, dynamic>> userMaps = await db.query(
      'Users',
      where: 'username = ?',
      whereArgs: ['test'], // Lấy ID của user 'test'
      limit: 1,
    );
    int? currentUserId;
    if (userMaps.isNotEmpty) {
      currentUserId = userMaps.first['id'] as int;
    }

    if (currentUserId != null) {
      // Một vài giao dịch mẫu cho user 'test'
      await db.insert('GiaoDich', {
        'date': '2023-05-01',
        'type': 'thu',
        'amount': 10000000.0,
        'totalAmount': 10000000.0,
        'description': 'Lương tháng 4',
        'category': 'Lương',
        'illustration': null,
        'userId': currentUserId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('GiaoDich', {
        'date': '2023-05-02',
        'type': 'chi',
        'amount': 50000.0,
        'totalAmount': 9950000.0, // Giả sử tổng tiền đã cập nhật
        'description': 'Ăn sáng tại quán',
        'category': 'Ăn uống',
        'illustration': null,
        'userId': currentUserId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('GiaoDich', {
        'date': '2023-05-03',
        'type': 'chi',
        'amount': 25000.0,
        'totalAmount': 9925000.0,
        'description': 'Tiền xe buýt',
        'category': 'Đi lại',
        'illustration': null,
        'userId': currentUserId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      print("Error: Could not find 'test' user to link GiaoDich data.");
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic here if your schema changes in future versions
    // For example:
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE Users ADD COLUMN email TEXT;");
    // }
  }
  Future<void> closeDb() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}