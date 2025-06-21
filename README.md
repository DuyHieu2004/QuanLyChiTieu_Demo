# Ứng Dụng Quản Lý Chi Tiêu Cá Nhân

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://www.sqlite.org/index.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📝 Giới Thiệu

Đây là một ứng dụng di động quản lý chi tiêu cá nhân đơn giản, được phát triển bằng Flutter. Ứng dụng giúp người dùng dễ dàng theo dõi các khoản thu chi hàng ngày, quản lý tài chính cá nhân một cách hiệu quả. Dữ liệu được lưu trữ cục bộ bằng cơ sở dữ liệu SQLite, đảm bảo tính riêng tư và truy cập nhanh chóng.

## ✨ Tính Năng Chính

* **Đăng ký/Đăng nhập/Đăng xuất:** Quản lý tài khoản người dùng an toàn.
* **Quản lý giao dịch:** Ghi lại các khoản thu và chi tiết.
* **Phân loại giao dịch:** Phân loại các giao dịch theo danh mục (ví dụ: ăn uống, đi lại, hóa đơn, lương...).
* **Hiển thị tổng quan:** Xem tổng số tiền đã chi tiêu/thu nhập theo ngày, tháng, năm.
* **Cơ sở dữ liệu cục bộ:** Sử dụng SQLite để lưu trữ dữ liệu offline, đảm bảo quyền riêng tư.
* **Giao diện người dùng thân thiện:** Thiết kế đơn giản, dễ sử dụng.

## 🛠️ Công Nghệ Sử Dụng

* **Flutter:** Framework UI được phát triển bởi Google để xây dựng ứng dụng di động, web và desktop từ một codebase duy nhất.
* **Dart:** Ngôn ngữ lập trình chính của Flutter.
* **SQLite:** Cơ sở dữ liệu quan hệ nhẹ, được nhúng trong ứng dụng để lưu trữ dữ liệu cục bộ.
* **Provider:** Để quản lý trạng thái ứng dụng một cách hiệu quả (Dựa trên tên file `auth_provider.dart` trong cấu trúc của bạn).

## 🚀 Cài Đặt & Chạy Ứng Dụng

Để thiết lập và chạy ứng dụng trên máy tính của bạn, làm theo các bước sau:

### 1. Chuẩn Bị Môi Trường

Đảm bảo bạn đã cài đặt và cấu hình Flutter SDK. Nếu chưa, hãy truy cập [Trang cài đặt Flutter](https://flutter.dev/docs/get-started/install).

* **Yêu cầu:**
    * Flutter SDK (Phiên bản ổn định)
    * Dart SDK (đi kèm với Flutter)
    * Môi trường phát triển: Android Studio hoặc Visual Studio Code (khuyến nghị có cài đặt Flutter và Dart plugins)
    * Thiết bị Android/iOS hoặc trình giả lập/máy ảo để chạy ứng dụng.

### 2. Clone Repository

Sử dụng Git để clone mã nguồn về máy tính của bạn:

```bash
git clone [https://github.com/DuyHieu2004/QuanLyNhaHang.git](https://github.com/DuyHieu2004/QuanLyNhaHang.git)
cd QuanLyNhaHang
```

### **3. Cài Đặt Dependencies**

Trong thư mục gốc của project, chạy lệnh sau để tải về tất cả các gói phụ thuộc:

```bash
flutter pub get
```
### 4. Chạy Ứng Dụng
Sau khi các bước trên hoàn tất, bạn có thể chạy ứng dụng trên thiết bị ảo hoặc thiết bị thực:
```bash
flutter run lib/main2.dart
```

## 📂 Cấu Trúc Thư Mục
Dưới đây là tổng quan về cấu trúc thư mục chính của dự án:
```bash
.
├── lib/
│   ├── data_access_objects/  # Lớp truy cập dữ liệu (DAO) để tương tác với SQLite (danh_muc_dao.dart, giao_dich_dao.dart, user_dao.dart)
│   │   ├── danh_muc_dao.dart
│   │   ├── giao_dich_dao.dart
│   │   └── user_dao.dart
│   ├── models/               # Định nghĩa các model dữ liệu (danh_muc.dart, giao_dich.dart, user.dart)
│   │   ├── danh_muc.dart
│   │   ├── giao_dich.dart
│   │   └── user.dart
│   ├── providers/            # Các provider hoặc lớp quản lý trạng thái (ví dụ: AuthProvider, AddTransactionPageProvider)
│   │   ├── auth_provider.dart
│   │   ├── add_transaction_page.dart
│   │   ├── db_helper.dart      # Hỗ trợ tương tác cơ sở dữ liệu
│   │   ├── home_page.dart      # Trang chính của ứng dụng
│   │   ├── login_page.dart     # Trang đăng nhập
│   │   ├── main.dart
│   │   └── main2.dart          # File chạy chính của ứng dụng
│   └── ... (các file hoặc thư mục khác nếu có)
├── android/                  # Project Android
├── ios/                      # Project iOS
├── pubspec.yaml              # Định nghĩa các dependencies và thông tin project
├── .gitignore                # Các file và thư mục bị bỏ qua bởi Git
├── README.md                 # File mô tả dự án này
└── ... (các file hoặc thư mục cấp cao khác)
```

## 🤝 Đóng Góp
Nếu bạn muốn đóng góp vào dự án này, vui lòng fork repository và tạo pull request. Mọi đóng góp đều được hoan nghênh!

## 📄 Giấy Phép (License)
Dự án này được cấp phép theo giấy phép MIT License.
(Lưu ý: Nếu bạn chọn GNU General Public License v3.0 ban đầu, hãy đổi dòng trên thành: "Dự án này được cấp phép theo giấy phép GNU General Public License v3.0.")

## ✉️ Liên Hệ
Duy Hieu - DuyHieu2004
<!-- end list -->


