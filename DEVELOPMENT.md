# AssessMent 2 PPBL - Platform Terpadu Hunian, Kegiatan & Marketplace

Aplikasi Flutter yang komprehensif untuk menghubungkan mahasiswa dengan penyedia hunian (kos, apartment, kontrakan), kegiatan kampus (seminar, webinar, workshop), dan marketplace jual-beli barang.

## Fitur Utama

### 1. **Sistem Autentikasi**

- Registrasi dan Login untuk 3 jenis user: Mahasiswa, Penyedia, Admin
- Session management dengan SharedPreferences
- Password encryption dan validation

### 2. **Modul Mahasiswa**

- Browse hunian, kegiatan, dan marketplace
- Booking hunian
- Registrasi kegiatan
- Pembelian marketplace
- Bookmark listing favorit
- Beri rating, review, dan komentar
- Lihat history browsing
- Dashboard statistik (booking, registrasi, pembelian pending)
- Manage profile pribadi

### 3. **Modul Penyedia**

- Upload dan manage listing (hunian, kegiatan, marketplace)
- Approve/Reject booking dengan alasan penolakan (untuk hunian & marketplace)
- Lihat list booking yang masuk
- Dashboard statistik listing
- Grafik pendapatan
- Manage profile bisnis
- View rating dari mahasiswa

### 4. **Modul Admin**

- Manage kategori hunian (Kos, Apartment, Kontrakan)
- Manage kategori kegiatan (Seminar, Webinar, Workshop, Bootcamp, Lomba) dengan sub-kategori
- Manage kategori marketplace (Barang Baru/Bekas) dengan sub-kategori
- Dashboard dengan statistik: Total penyedia, Total mahasiswa, Total listing
- Manage semua user profiles

### 5. **Database**

- SQLite dengan 7 tabel utama:
  - `users` - Data pengguna
  - `listings` - Listing hunian, kegiatan, marketplace
  - `bookings` - Booking/registrasi/pembelian
  - `reviews` - Rating dan review
  - `bookmarks` - Bookmark favorit
  - `categories` - Kategori dan sub-kategori
  - `history` - History browsing mahasiswa

### 6. **UI/UX Features**

- Material Design 3
- Gradient colors (Indigo, Purple, Cyan)
- Bottom Navigation Bar untuk easy navigation
- Card-based design untuk listing dan history
- List view untuk informasi lengkap
- Responsive layout

## Struktur Folder

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── user.dart
│   ├── listing.dart
│   ├── booking.dart
│   ├── review.dart
│   ├── bookmark.dart
│   ├── category.dart
│   └── history.dart
├── database/
│   └── database_helper.dart  # SQLite operations
├── services/
│   └── auth_service.dart     # Authentication logic
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart  # Router ke tiga modul
│   ├── mahasiswa/
│   │   └── mahasiswa_home.dart
│   ├── penyedia/
│   │   └── penyedia_home.dart
│   └── admin/
│       └── admin_home.dart
├── widgets/                  # Reusable widgets
├── utils/
│   └── app_theme.dart        # Theme dan styling
└── services/
    └── auth_service.dart
```

## Dependencies

```yaml
flutter:
  sdk: flutter

# UI & Navigation
provider: ^6.0.0

# Database
sqflite: ^2.3.0
path: ^1.8.3

# Storage
shared_preferences: ^2.2.0

# Maps & Location
flutter_map: ^6.0.0
geolocator: ^9.0.0
latlong2: ^0.9.1

# Charts
fl_chart: ^0.63.0

# Image & Picker
image_picker: ^1.0.0

# DateTime
intl: ^0.19.0

# HTTP
http: ^1.1.0
```

## Instalasi & Setup

1. **Clone dan Navigate ke folder**

```bash
cd d:\asessment2_ppbl
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run aplikasi**

```bash
flutter run
```

## File-File yang Sudah Dibuat

### ✅ Models (7 files)

- `user.dart` - User model dengan toMap/fromMap
- `listing.dart` - Listing untuk hunian, kegiatan, marketplace
- `booking.dart` - Booking/registrasi/pembelian
- `review.dart` - Rating dan review
- `bookmark.dart` - Bookmark listing
- `category.dart` - Kategori dan sub-kategori
- `history.dart` - History browsing

### ✅ Database

- `database_helper.dart` - Komprehensif dengan 50+ methods untuk CRUD semua operasi

### ✅ Authentication

- `auth_service.dart` - Login, Register, Logout, Session management

### ✅ Screens

- `login_screen.dart` - Login dengan validation dan error handling
- `register_screen.dart` - Registrasi dengan dropdown user type
- `home_screen.dart` - Router ke setiap modul
- `mahasiswa_home.dart` - Placeholder dengan bottom navigation
- `penyedia_home.dart` - Placeholder dengan bottom navigation
- `admin_home.dart` - Placeholder dengan bottom navigation

### ✅ Theme

- `app_theme.dart` - Warna, typography, komponen theme yang konsisten

## Fitur Implementasi Selanjutnya

### 📋 Mahasiswa Module

- [ ] Home page dengan featured listings
- [ ] Browse hunian dengan filtering
- [ ] Browse kegiatan dengan mapping
- [ ] Browse marketplace dengan filtering
- [ ] Detail page untuk setiap listing
- [ ] Booking flow untuk hunian
- [ ] Registrasi flow untuk kegiatan
- [ ] Purchase flow untuk marketplace
- [ ] Bookmark management
- [ ] Review/rating system
- [ ] History page
- [ ] Dashboard dengan statistik

### 🏪 Penyedia Module

- [ ] Create/Edit listing form
- [ ] Multi-image upload
- [ ] Booking management list
- [ ] Approve/Reject dengan reason
- [ ] Analytics dashboard
- [ ] Income chart
- [ ] Profile management

### ⚙️ Admin Module

- [ ] Category CRUD dengan nested sub-categories
- [ ] User management
- [ ] Dashboard dengan grafik statistik
- [ ] Monitoring semua listing

### 🔍 Advanced Features

- [ ] Maps integration untuk hunian & kegiatan
- [ ] Geolocation services
- [ ] Advanced filtering
- [ ] Search dengan autocomplete
- [ ] Notification system
- [ ] Payment integration (future)

## Nota Penting

### Keamanan

- Password disimpan secara plain text (untuk production, gunakan bcrypt)
- Implement proper session timeout
- Add rate limiting untuk login attempts

### Performance

- Implement pagination untuk listing dengan banyak data
- Add caching untuk frequently accessed data
- Optimize image loading dengan caching

### Validation

- Email validation (regex)
- Phone number validation
- Address validation
- Input sanitization

## Developer Notes

1. **Database Initialization**: Otomatis terjadi saat pertama kali run aplikasi
2. **Session Management**: User info disimpan di SharedPreferences
3. **Navigation**: Menggunakan Navigator dengan MaterialPageRoute
4. **State Management**: Bisa upgrade ke Provider untuk better state management
5. **Error Handling**: Basic try-catch, perlu di-improve untuk production

## Testing Dengan Data Dummy

Untuk testing, Anda bisa:

1. Register 3 user dengan tipe berbeda:

   - mahasiswa@test.com (Mahasiswa)
   - penyedia@test.com (Penyedia)
   - admin@test.com (Admin)

2. Setiap user akan diarahkan ke modul masing-masing

## Next Steps

1. Implement detailed Mahasiswa screens dengan listing browsing
2. Implement detailed Penyedia screens dengan upload & approval
3. Implement detailed Admin screens dengan category management
4. Add maps integration
5. Add advanced filtering & search
6. Implement payment system (opsional)
7. Deploy ke App Store & Play Store

---

**Status**: Struktur dasar selesai ✅ | Implementasi detail: In Progress 🔄
