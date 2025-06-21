import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để định dạng số tiền

import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'add_transaction_page.dart'; // Trang thêm giao dịch
import '../data_access_objects/giao_dich_dao.dart'; // DAO cho GiaoDich
import '../models/user.dart'; // Để lấy thông tin user

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GiaoDichDao _giaoDichDao = GiaoDichDao();
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  String _userName = ''; // Tên người dùng hiển thị
  bool _isLoading = true; // Biến trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải dữ liệu
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null && currentUser.id != null) {
      _userName = currentUser.fullName ?? currentUser.username ?? 'Bạn'; // Lấy tên hiển thị
      _totalIncome = await _giaoDichDao.getTotalIncomeByUserId(currentUser.id!);
      _totalExpense = await _giaoDichDao.getTotalExpenseByUserId(currentUser.id!);
    } else {
      // Xử lý trường hợp không có user hoặc user ID
      _userName = 'Khách';
      _totalIncome = 0.0;
      _totalExpense = 0.0;
    }

    setState(() {
      _isLoading = false; // Kết thúc tải dữ liệu
    });
  }

  // Định dạng tiền tệ
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    return formatter.format(amount) + ' VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    double effectiveBalance = _totalIncome - _totalExpense;
    Color balanceColor = effectiveBalance >= 0 ? Colors.blueAccent : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Tài Chính'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSummaryData, // Tải lại dữ liệu khi nhấn nút refresh
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading spinner
          : RefreshIndicator( // Cho phép kéo xuống để làm mới
        onRefresh: _loadSummaryData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn để RefreshIndicator hoạt động
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phần chào bạn
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.blueAccent.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào bạn: $_userName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Dưới đây là tổng quan tài chính của bạn:',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tổng thu
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng thu:',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(_totalIncome),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Màu xanh cho tổng thu
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tổng chi
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng chi:',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(_totalExpense),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red, // Màu đỏ cho tổng chi
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hiệu quả
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: effectiveBalance >= 0 ? Colors.green.shade50 : Colors.red.shade50, // Nền màu dựa vào hiệu quả
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hiệu quả:',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${effectiveBalance >= 0 ? '+' : ''}${_formatCurrency(effectiveBalance)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: balanceColor, // Màu chữ dựa vào hiệu quả
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Nút Thêm Giao Dịch Mới (giữ nguyên)
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddTransactionPage()),
                      );
                      _loadSummaryData(); // Tải lại dữ liệu sau khi thêm giao dịch
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    label: const Text(
                      'Thêm Giao Dịch Mới',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                // Bạn có thể thêm các widget khác như biểu đồ, danh sách giao dịch gần đây tại đây
              ],
            ),
          ),
        ),
      ),
    );
  }
}