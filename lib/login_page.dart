import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../data_access_objects/user_dao.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false; // Trạng thái của checkbox "Ghi nhớ mật khẩu"
  final UserDao _userDao = UserDao();

  @override
  void initState() {
    super.initState();
    _loadRememberMeCredentials(); // Tải thông tin ghi nhớ khi khởi tạo trang
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Hàm tải thông tin đăng nhập đã ghi nhớ
  Future<void> _loadRememberMeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('remembered_username');
    // CẢNH BÁO: Lưu mật khẩu trực tiếp (plain text) là KHÔNG AN TOÀN.
    // Trong ứng dụng thực tế, chỉ nên lưu username và một token an toàn.
    final savedPassword = prefs.getString('remembered_password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true; // Đặt checkbox là true nếu có thông tin
      });
    }
  }

  // Hàm lưu/xóa thông tin đăng nhập đã ghi nhớ
  Future<void> _saveRememberMeCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_username', username);

      await prefs.setString('remembered_password', password);
    } else {
      await prefs.remove('remembered_username');
      await prefs.remove('remembered_password');
    }
  }

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Tên đăng nhập hoặc mật khẩu không được để trống.');
      return;
    }

    // Kiểm tra sự tồn tại của username trước (như yêu cầu "Không có tên đăng nhập này")
    User? existingUser = await _userDao.getUserByUsername(username);
    if (existingUser == null) {
      if (!mounted) return; // Đảm bảo widget còn tồn tại trước khi cập nhật UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tên đăng nhập không tồn tại.")),
      );
      return; // Dừng lại nếu username không tồn tại
    }

    // Tiến hành đăng nhập với username và password
    User? user = await _userDao.login(username, password);

    if (user != null) {
      // Đăng nhập thành công
      if (!mounted) return; // Đảm bảo widget còn tồn tại trước khi cập nhật UI

      // Lưu/Xóa thông tin ghi nhớ dựa trên trạng thái của checkbox
      await _saveRememberMeCredentials(username, password);

      // Cập nhật AuthProvider và điều hướng
      Provider.of<AuthProvider>(context, listen: false).login(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập thành công!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Đăng nhập thất bại (mật khẩu không đúng)
      if (!mounted) return; // Đảm bảo widget còn tồn tại trước khi cập nhật UI
      _showErrorDialog('Tên đăng nhập hoặc mật khẩu không đúng.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi đăng nhập'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Phần UI của LoginPage không thay đổi so với lần trước
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Đăng Nhập',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Nhập tên đăng nhập',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Nhập mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleObscureText,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Ghi nhớ mật khẩu'),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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