import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:provider/provider.dart';
import 'package:s16_doanduyhieu_2001221419/home_page.dart';

import '../data_access_objects/danh_muc_dao.dart';
import '../data_access_objects/giao_dich_dao.dart';
import '../models/danh_muc.dart';
import '../models/giao_dich.dart';
import '../providers/auth_provider.dart'; // Để lấy currentUser

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>(); // Key để validate form
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _transactionType = 'chi'; // Mặc định là 'chi' (expense)
  DateTime _selectedDate = DateTime.now(); // Ngày được chọn, mặc định là hôm nay
  DanhMuc? _selectedCategory; // Danh mục được chọn từ dropdown
  List<DanhMuc> _categories = []; // Danh sách các danh mục để hiển thị trong dropdown
  File? _pickedImage; // File ảnh được chọn

  final DanhMucDao _danhMucDao = DanhMucDao();
  final GiaoDichDao _giaoDichDao = GiaoDichDao();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Tải danh mục dựa trên loại giao dịch (thu/chi)
  Future<void> _loadCategories() async {
    try {
      List<DanhMuc> fetchedCategories = await _danhMucDao.getDanhMucsByType(_transactionType);
      setState(() {
        _categories = fetchedCategories;
        // Đặt danh mục được chọn là null nếu danh mục hiện tại không còn trong danh sách
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
        } else if (_selectedCategory == null && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
      if (_categories.isEmpty) {
        _showSnackBar('Chưa có danh mục nào cho loại "${_transactionType}". Vui lòng thêm danh mục.', isError: true);
        // Tùy chọn: Chèn danh mục mặc định nếu không có
        // await _insertDefaultCategories();
        // await _loadCategories();
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tải danh mục: $e', isError: true);
    }
  }

  // Hàm chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm chọn ảnh
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  // Hàm chụp ảnh
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _pickedImage = File(photo.path);
      });
    }
  }

  // Hàm lưu giao dịch
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedCategory == null) {
        _showSnackBar('Vui lòng chọn một danh mục.', isError: true);
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null || currentUser.id == null) {
        _showSnackBar('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.', isError: true);
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        _showSnackBar('Số tiền không hợp lệ.', isError: true);
        return;
      }

      // Giả định tổng tiền, trong thực tế bạn sẽ tính toán từ database
      // Ví dụ: lấy tổng số dư hiện tại của user, rồi cộng/trừ số tiền này
      // Để đơn giản, ở đây ta đặt một giá trị mẫu hoặc lấy từ đâu đó.
      // Bạn có thể cần một hàm DAO để lấy tổng tiền của user
      double currentTotalAmount = 0.0; // Lấy từ DB hoặc state
      // Ví dụ lấy một giá trị tĩnh cho demo:
      if (_transactionType == 'thu') {
        currentTotalAmount = 10000000 + amount; // Ví dụ cộng vào 10 triệu ban đầu
      } else {
        currentTotalAmount = 10000000 - amount; // Ví dụ trừ đi từ 10 triệu ban đầu
      }


      final newGiaoDich = GiaoDich(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        type: _transactionType,
        amount: amount,
        totalAmount: currentTotalAmount, // Cần tính toán động trong ứng dụng thực tế
        description: _descriptionController.text.trim(),
        category: _selectedCategory!.name,
        illustration: _pickedImage?.path, // Lưu đường dẫn ảnh
        userId: currentUser.id!,
      );

      try {
        final id = await _giaoDichDao.insertGiaoDich(newGiaoDich);
        _showSnackBar('Đã lưu giao dịch thành công! ID: $id');
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
        // Reset form sau khi lưu
        _amountController.clear();
        _descriptionController.clear();
        _noteController.clear();
        setState(() {
          _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
          _pickedImage = null;
          _selectedDate = DateTime.now();
        });
        // Có thể navigate về trang chính hoặc danh sách giao dịch
        // Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Lỗi khi lưu giao dịch: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Chi Tiêu'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toggle Thu/Chi
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'thu';
                            _loadCategories(); // Tải lại danh mục khi đổi loại
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _transactionType == 'thu' ? Colors.blueAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Thu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _transactionType == 'thu' ? Colors.white : Colors.blueGrey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'chi';
                            _loadCategories(); // Tải lại danh mục khi đổi loại
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _transactionType == 'chi' ? Colors.blueAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Chi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _transactionType == 'chi' ? Colors.white : Colors.blueGrey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Title "Thêm thu chi"
              Text(
                _transactionType == 'thu' ? 'Thêm Khoản Thu' : 'Thêm Chi Tiêu',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Date Selector
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blueAccent),
                      const SizedBox(width: 15),
                      Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),


              // Tên thu chi (Description)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _transactionType == 'thu' ? 'Tên khoản thu' : 'Tên khoản chi',
                  hintText: 'Ví dụ: Tiền lương, Ăn trưa, Mua sắm...',
                  prefixIcon: const Icon(Icons.description, color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khoản.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Số tiền
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Danh mục (Dropdown)
              DropdownButtonFormField<DanhMuc>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: const Icon(Icons.category, color: Colors.orange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                items: _categories.map((DanhMuc category) {
                  return DropdownMenuItem<DanhMuc>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (DanhMuc? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn danh mục.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Image Picker
              _pickedImage != null
                  ? Image.file(
                _pickedImage!,
                height: 150,
                fit: BoxFit.cover,
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Chọn ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Chụp ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ghi chú
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Thêm ghi chú chi tiết...',
                  prefixIcon: const Icon(Icons.note_alt, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Nút Lưu
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveTransaction,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'LƯU',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}