# Hướng Dẫn Cài Đặt Dự Án Flutter - Tinaem (Ứng Dụng Hẹn Hò Online)

## 1. Yêu Cầu Hệ Thống
Trước khi cài đặt, hãy đảm bảo máy tính của bạn đáp ứng các yêu cầu sau:

- **Flutter SDK** (phiên bản mới nhất)
- **Dart SDK** (tích hợp sẵn trong Flutter)
- **Android Studio** (hoặc Xcode nếu chạy trên iOS)
- **VS Code** (hoặc IDE khác hỗ trợ Flutter)
- **Git** (để quản lý mã nguồn)

## 2. Cài Đặt Môi Trường

### 2.1 Cài Đặt Flutter

Tải và cài đặt Flutter SDK theo hướng dẫn từ [trang chủ Flutter](https://flutter.dev/docs/get-started/install).

Sau khi cài đặt, kiểm tra bằng lệnh:
```sh
flutter doctor
```

Nếu có lỗi, hãy làm theo hướng dẫn để khắc phục.

### 2.2 Cấu Hình Android Studio / Xcode
- **Android:** Cài đặt Android SDK, AVD Emulator.
- **iOS:** Cài đặt Xcode và CocoaPods (`sudo gem install cocoapods`).

### 2.3 Thiết Lập Cloudinary
Ứng dụng sử dụng Cloudinary để lưu trữ và quản lý hình ảnh.
1. Đăng ký tài khoản tại [Cloudinary](https://cloudinary.com/).
2. Lấy **Cloud Name**, **API Key**, **API Secret** từ trang quản lý tài khoản.
3. Mở file `lib/services/cloudinary_service.dart` và thêm thông tin API:
   ```dart
   class CloudinaryService {
     static const String cloudName = "your_cloud_name";
     static const String apiKey = "your_api_key";
     static const String apiSecret = "your_api_secret";
   }
   ```

## 3. Clone & Cấu Hình Dự Án

### 3.1 Clone Dự Án
```sh
git clone https://github.com/your-repo/tinaem.git
cd tinaem
```

### 3.2 Cài Đặt Thư Viện
```sh
flutter pub get
```

### 3.3 Chạy Ứng Dụng
- **Android:**
  ```sh
  flutter run
  ```
- **iOS:**
  ```sh
  cd ios && pod install && cd ..
  flutter run
  ```

