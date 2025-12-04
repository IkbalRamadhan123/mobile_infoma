# 📚 Database Persistence Guide

## ✅ Database Persistent - Data Tidak Hilang!

Aplikasi ini menggunakan **SQLite database yang persistent**. Artinya:

- ✅ Data tersimpan di device storage
- ✅ Data bertahan meski aplikasi ditutup
- ✅ Data hanya hilang jika aplikasi diuninstall atau database dihapus manual

---

## 🎯 Cara Menggunakan Aplikasi

### **Pertama Kali (Fresh Install)**

1. **Buka aplikasi** → Akan melihat Login Screen
2. **Klik "Daftar di sini"** → Pergi ke Register Screen
3. **Isi form dengan data unik**:

   - **Nama Lengkap**: Nama Anda (bebas)
   - **Email**: Email unik yang **BELUM PERNAH DIGUNAKAN** sebelumnya
   - **Nomor Telepon**: Mulai dengan 0, minimal 10 digit
   - **Alamat**: Alamat lengkap
   - **Tipe Pengguna**: Pilih mahasiswa/penyedia/admin
   - **Password**: Minimal 6 karakter

4. **Klik "Daftar"** → User terdaftar, redirect ke Login
5. **Login dengan email dan password** yang baru didaftar
6. **Masuk ke Dashboard** → Selesai! ✅

---

## 🔄 Setelah Aplikasi Ditutup & Dibuka Lagi

1. **Tutup aplikasi** (close browser tab)
2. **Buka aplikasi lagi** (buka localhost di browser)
3. **Mau login?** → Email dan password masih tersimpan di database ✅
4. **Mau daftar user baru?** → Gunakan **email yang berbeda** dari sebelumnya

---

## ⚠️ Masalah Umum & Solusi

### **Masalah: Error "Email sudah terdaftar"**

**Penyebab**: Anda mencoba daftar dengan email yang **sudah ada di database** dari registrasi sebelumnya.

**Solusi**:

- Gunakan **email yang berbeda** untuk setiap registrasi
- Contoh:
  ```
  Registrasi 1: yansha.test.1@gmail.com
  Registrasi 2: yansha.test.2@gmail.com
  Registrasi 3: yansha.test.3@gmail.com
  ```

---

### **Masalah: Lupa Password**

**Saat ini**: Aplikasi tidak punya fitur "lupa password"

**Solusi Sementara**: Daftar user baru dengan email berbeda

**Rencana**: Fitur password reset akan ditambahkan di fase berikutnya

---

### **Masalah: Ingin Reset Database (Hapus Semua Data)**

Jika Anda **ingin menghapus semua data** dan mulai fresh:

#### **Opsi 1: Hapus Browser Cache**

```
Chrome/Edge/Firefox → Settings → Clear Browsing Data → Local Storage
```

#### **Opsi 2: Uncomment Reset Code**

Buka `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncomment line ini untuk reset database
  // await DatabaseHelper().deleteDatabase();

  final authService = AuthService();
  // ... rest of code
}
```

Uncomment baris `await DatabaseHelper().deleteDatabase();`, lalu:

1. Hot reload (`R` in terminal)
2. Database akan terhapus
3. Comment kembali line tersebut
4. Hot reload lagi
5. Aplikasi siap dengan database kosong

---

## 📊 Test Data - Akun untuk Testing

Setelah registrasi, Anda punya akun sendiri untuk testing.

**Contoh Test Flow**:

```
1. Daftar: yansha.test.1@gmail.com (type: mahasiswa)
2. Login: yansha.test.1@gmail.com
3. Explore dashboard, browse, features
4. Logout
5. Daftar: yansha.penyedia@gmail.com (type: penyedia)
6. Login: yansha.penyedia@gmail.com
7. Explore penyedia features
8. Logout
9. Daftar: admin.test@gmail.com (type: admin)
10. Login: admin.test@gmail.com
11. Explore admin features
```

---

## 🗄️ Database Structure

**File Lokasi**: `{Your Device Storage}/asessment2_ppbl.db`

**Tabel di Database**:

- `users` - Menyimpan user yang terdaftar
- `listings` - Menyimpan listing hunian/kegiatan/marketplace
- `bookings` - Menyimpan booking/registrasi/pembelian
- `reviews` - Menyimpan rating dan review
- `bookmarks` - Menyimpan favorit user
- `categories` - Menyimpan kategori hunian/kegiatan/marketplace
- `history` - Menyimpan history viewing listing

---

## 🔍 Debugging Database

Jika ada masalah, buka **Browser Console** (`F12` → Console tab) untuk melihat detailed error messages:

```
Register error: Email format invalid
Register error: Email already exists
Register error: Insert failed, id=0
Register error: User not found after insert
```

Lihat console logs ini untuk memahami masalah yang sebenarnya terjadi.

---

## ✨ Database Persistence Features

✅ **Automatic Persistence**

- Data otomatis tersimpan ke SQLite
- Tidak perlu save manual

✅ **Session Management**

- Login session disimpan di SharedPreferences
- Auto login jika sudah login sebelumnya

✅ **Data Validation**

- Email UNIQUE constraint (tidak boleh duplikat)
- Phone dan address validation
- Password minimal 6 karakter

✅ **Relational Data**

- Listing terhubung ke provider
- Booking terhubung ke listing, mahasiswa, dan penyedia
- Review terhubung ke listing dan mahasiswa

---

## 📝 Summary

| Aspek                  | Status                 |
| ---------------------- | ---------------------- |
| Data Persistent        | ✅ Ya                  |
| Hilang saat close      | ❌ Tidak               |
| Email Duplikat         | ❌ Tidak diperbolehkan |
| Password Reset         | ⏳ Coming soon         |
| Multiple User Accounts | ✅ Bisa                |
| Auto Login             | ✅ Bisa                |

---

**Happy Testing! 🚀**

Untuk pertanyaan lebih lanjut, lihat:

- `SETUP_GUIDE.md` - Setup & troubleshooting
- `DEVELOPMENT.md` - Fitur & architecture
- `README_ID.md` - Project overview
