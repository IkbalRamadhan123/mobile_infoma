# 🚀 Setup & Running Instructions

## Prerequisites

Pastikan Anda sudah install:

- Flutter SDK (v3.8.1 atau lebih baru)
- Dart SDK (terintegrasi dengan Flutter)
- Android Studio atau VS Code
- Emulator atau Physical Device

Verifikasi instalasi:

```bash
flutter --version
dart --version
```

## Step-by-Step Setup

### 1. **Clone/Navigate ke Project**

```bash
cd d:\asessment2_ppbl
```

### 2. **Install Dependencies**

```bash
flutter pub get
```

Jika ada error, coba:

```bash
flutter clean
flutter pub get
```

### 3. **Setup Android (Jika belum)**

```bash
cd android
./gradlew build
cd ..
```

### 4. **Run Aplikasi**

```bash
flutter run
```

Atau dengan device/emulator tertentu:

```bash
flutter run -d <device-id>
```

---

## 📱 Testing the App

### Test Credentials

**Mahasiswa Account:**

- Email: `mahasiswa@test.com`
- Password: `password123`

**Penyedia Account:**

- Email: `penyedia@test.com`
- Password: `password123`

**Admin Account:**

- Email: `admin@test.com`
- Password: `password123`

### Atau buat akun baru

Gunakan Register screen untuk membuat akun baru dengan memilih jenis user.

---

## 🔧 Project Structure

```
asessment2_ppbl/
├── lib/
│   ├── main.dart                      # Entry point
│   ├── models/                        # Data classes
│   │   ├── user.dart
│   │   ├── listing.dart
│   │   ├── booking.dart
│   │   ├── review.dart
│   │   ├── bookmark.dart
│   │   ├── category.dart
│   │   └── history.dart
│   ├── database/
│   │   └── database_helper.dart       # SQLite operations
│   ├── services/
│   │   └── auth_service.dart          # Authentication
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── mahasiswa/
│   │   │   ├── mahasiswa_home.dart
│   │   │   ├── mahasiswa_home_new.dart
│   │   │   └── pages/
│   │   │       ├── dashboard_page.dart    # ✅ Implemented
│   │   │       ├── browse_page.dart       # ✅ Implemented
│   │   │       ├── bookmarks_page.dart
│   │   │       ├── bookings_page.dart
│   │   │       └── profile_page.dart
│   │   ├── penyedia/
│   │   │   └── penyedia_home.dart
│   │   └── admin/
│   │       └── admin_home.dart
│   ├── widgets/
│   │   ├── listing_card.dart
│   │   ├── history_card.dart
│   │   └── bookmark_card.dart
│   └── utils/
│       └── app_theme.dart
├── pubspec.yaml                       # Dependencies
├── DEVELOPMENT.md                     # Development guide
└── PROJECT_PROGRESS.md                # Progress report
```

---

## 🎯 File Status

### ✅ Complete & Ready to Use

- `main.dart` - Entry point
- `pubspec.yaml` - Dependencies
- All model files
- `database_helper.dart`
- `auth_service.dart`
- `app_theme.dart`
- `login_screen.dart`
- `register_screen.dart`
- `home_screen.dart`
- `dashboard_page.dart`
- `browse_page.dart`
- `listing_card.dart`
- `history_card.dart`
- `bookmark_card.dart`

### 🔄 In Progress / Placeholder

- `mahasiswa_home.dart` - Update ke `mahasiswa_home_new.dart`
- `penyedia_home.dart` - Belum diimplementasi
- `admin_home.dart` - Belum diimplementasi
- `bookmarks_page.dart` - Placeholder
- `bookings_page.dart` - Placeholder
- `profile_page.dart` - Placeholder

---

## 🐛 Troubleshooting

### Error: "Target of URI doesn't exist"

**Solusi**: Run `flutter pub get` untuk install dependencies

### Error: "Undefined class 'Database'"

**Solusi**: Pastikan `sqflite` sudah di-install dengan `flutter pub get`

### Build Error

```bash
flutter clean
flutter pub get
flutter run
```

### Emulator Issues

```bash
flutter clean
flutter pub cache repair
flutter pub get
```

---

## 📝 Implementation Checklist

### Mahasiswa Module

- [x] Navigation & routing
- [x] Dashboard with stats
- [x] Browse with search & filter
- [ ] Browse detail page
- [ ] Booking flow
- [ ] Registrasi flow
- [ ] Purchase flow
- [ ] Bookmarks management
- [ ] Bookings list & history
- [ ] Profile management

### Penyedia Module

- [ ] Navigation setup
- [ ] Listing creation
- [ ] Image upload
- [ ] Booking approval
- [ ] Analytics dashboard
- [ ] Profile management

### Admin Module

- [ ] Navigation setup
- [ ] Category management
- [ ] User management
- [ ] Statistics dashboard

---

## 💻 Development Tips

### Hot Reload

```bash
# Ganti kode dan save, kemudian:
r    # Hot reload
R    # Hot restart
q    # Quit
```

### Debug Mode

```bash
flutter run --debug
```

### Release Build (untuk testing)

```bash
flutter run --release
```

### View Logs

```bash
flutter logs
```

---

## 📚 Dependencies Reference

### Database

```yaml
sqflite: ^2.3.0 # SQLite
path: ^1.8.3 # Path operations
```

### State Management

```yaml
provider: ^6.0.0 # State management (ready to use)
```

### Maps & Location

```yaml
flutter_map: ^6.0.0 # Mapping
geolocator: ^9.0.0 # GPS
latlong2: ^0.9.1 # Coordinates
```

### UI

```yaml
fl_chart: ^0.63.0 # Charts
image_picker: ^1.0.0 # Image selection
```

### Utils

```yaml
shared_preferences: ^2.2.0 # Local storage
intl: ^0.19.0 # DateTime & i18n
http: ^1.1.0 # API calls
```

---

## 🎨 Theme Customization

Edit `lib/utils/app_theme.dart`:

```dart
// Change colors
static const Color primaryColor = Color(0xFF6366F1); // Indigo
static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
static const Color accentColor = Color(0xFF06B6D4); // Cyan
```

---

## 🚀 Next Features to Implement

### Priority 1 (High)

1. Login/Register screen bug fix
2. Listing detail page
3. Booking flow for student
4. Profile management

### Priority 2 (Medium)

1. Maps integration
2. Penyedia upload listing
3. Booking approval system
4. Admin dashboard

### Priority 3 (Low)

1. Advanced filtering
2. Payment gateway
3. Notifications
4. Messaging system

---

## 🔐 Security Notes

### Current Status

- ⚠️ Passwords stored plain text (upgrade needed)
- ⚠️ No rate limiting on login
- ⚠️ Session doesn't have timeout

### Recommendations for Production

```dart
// Use bcrypt for password hashing
// Add session timeout (30 menit)
// Add login attempt rate limiting
// Implement HTTPS for API
// Add JWT tokens for API auth
```

---

## 📞 Common Tasks

### Add New Screen

1. Create folder in `lib/screens/[module]/`
2. Create `[name]_screen.dart` or `[name]_page.dart`
3. Extend `StatefulWidget` atau `StatelessWidget`
4. Add route in navigation

### Add New Model

1. Create file in `lib/models/[name].dart`
2. Add `toMap()` and `fromMap()` methods
3. Add CRUD methods di `DatabaseHelper`

### Add Database Table

1. Add SQL in `_createTables()` method
2. Add CRUD methods
3. Update related models

### Add New Widget

1. Create file in `lib/widgets/[name].dart`
2. Make it configurable with parameters
3. Test with different data

---

## 📊 Project Statistics

- **Total Files**: 35+
- **Total Lines**: 3000+
- **Models**: 7
- **Database Tables**: 7
- **Database Methods**: 50+
- **Screens**: 9
- **Widgets**: 3

---

## ✨ Recent Updates

### November 21, 2025

- ✅ Complete project structure
- ✅ All models created
- ✅ Database with 50+ methods
- ✅ Authentication system
- ✅ Theme & styling
- ✅ Dashboard page implementation
- ✅ Browse page with search & tabs
- ✅ Reusable widgets
- ✅ Comprehensive documentation

---

## 🤝 Contributing

Ketika menambah fitur:

1. Follow existing code style
2. Add comments untuk complex logic
3. Use consistent naming conventions
4. Test thoroughly
5. Update documentation

---

## 📄 License

Proyek ini dibuat untuk keperluan akademis. Gunakan dengan bijak.

---

**Last Updated**: November 21, 2025  
**Status**: Ready for Feature Implementation ✅

Untuk pertanyaan atau issues, silakan refer ke DEVELOPMENT.md dan PROJECT_PROGRESS.md
