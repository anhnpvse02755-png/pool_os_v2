# PoolOS_v2 - AI Pool Training Platform

**Version:** 2.0.0  
**Repository:** https://github.com/anhnpvse02755-png/pool_os_v2

---

## Giới thiệu

PoolOS_v2 là nền tảng huấn luyện bi-a thông minh sử dụng AI để phân tích lối chơi và đưa ra khuyến nghị cá nhân hóa cho người chơi.

### Tính năng chính

- 📊 **Theo dõi buổi chơi** - Ghi lại chi tiết từng trận đấu, rack, và cú đánh
- 🤖 **Coach AI** - Phân tích lối chơi và đưa ra khuyến nghị dựa trên dữ liệu thực tế
- 📈 **Thống kê cá nhân** - Đo lường tiến bộ qua thời gian
- 🎯 **Lộ trình học** - Tạo kế hoạch luyện tập phù hợp với trình độ
- 🏆 **Hệ thống xếp hạng** - Beginner → K → I → H → G → F

### Tech Stack

- **Framework:** Flutter 3.44.6
- **State Management:** Riverpod 2.x
- **Navigation:** GoRouter
- **Backend:** Supabase (Auth, Database, Edge Functions)
- **UI:** Material Design 3

## Getting Started

### Yêu cầu

- Flutter SDK 3.12+
- Dart SDK 3.12+
- Android Studio / Xcode (cho native development)

### Cài đặt

```bash
# Clone repository
git clone https://github.com/anhnpvse02755-png/pool_os_v2.git

# Di chuyển vào thư mục
cd pool_os_v2

# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

### Cấu hình Supabase

1. Tạo project Supabase tại https://supabase.com
2. Copy file `lib/core/constants/supabase_config.dart`
3. Thay thế credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## Kiến trúc

Dự án sử dụng **Clean Architecture** với 3 layers:

```
lib/
├── core/                 # Shared utilities, theme, router
│   ├── constants/
│   ├── router/
│   ├── theme/
│   └── utils/
├── data/                 # Data layer (repositories, datasources)
├── domain/               # Domain layer (entities, usecases)
│   └── entities/
└── presentation/          # UI layer (screens, widgets)
    └── screens/
```

## Player Journey

1. **Welcome** - Giới thiệu app
2. **Onboarding** - Đánh giá trình độ ban đầu (6 screens)
3. **Home** - Dashboard với quick actions
4. **Sessions** - Tạo và quản lý buổi chơi
5. **Coach** - Xem khuyến nghị từ AI
6. **Profile** - Quản lý tài khoản

## License

Private - All rights reserved
