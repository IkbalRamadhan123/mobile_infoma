# 🚀 Quick Start Guide

## ✨ CARA TERCEPAT - Generate Email Otomatis

### Untuk Menghindari Error Email Duplikat:

1. **Di Register Screen → Klik button "Generate Email Unik"**
2. **Email akan otomatis terisi** dengan format: `test{timestamp}@infoma.com`
3. **Setiap klik = Email berbeda** (timestamp berbeda = unique guarantee) ✅
4. **Isi data lainnya** (nama, phone, password, dll)
5. **Klik "Daftar"** → Seharusnya berhasil!

**Ini adalah cara PALING MUDAH!** 🎉

---

## 🆘 Jika Registration Masih Error "Email sudah terdaftar"

### ✅ Solusi: Clear Database

1. **Klik button "Hapus Data (Dev)"** di register screen
2. **Klik "Hapus"** pada dialog confirmation
3. **Tunggu sampai SnackBar muncul** "Database berhasil dihapus"
4. **Refresh halaman browser** (F5 atau Ctrl+R) - PENTING!
5. **Klik "Generate Email Unik"** lagi
6. **Sekarang coba daftar** → Seharusnya berhasil

---

## 📝 Registrasi Langkah demi Langkah

### Step 1: Buka Register Screen

- Klik "Daftar di sini" di login screen

### Step 2: Auto-Generate Email (RECOMMENDED)

- Klik button **"Generate Email Unik"**
- Email otomatis terisi dengan format unik

### Step 3: Isi Form Lainnya

```
Nama Lengkap: Nama Anda (misal: Ikbal Rizqi)
Email: Sudah otomatis (dari step 2) ✅
Nomor Telepon: 08xxxxxxxxxx (harus mulai dengan 0, minimal 10 digit)
Alamat: Alamat lengkap Anda
Tipe Pengguna: Pilih salah satu (Mahasiswa/Penyedia/Admin)
Password: Minimal 6 karakter (misal: pass123 atau Test@2025)
```

### Step 4: Klik "Daftar"

- Tunggu sampai redirect ke login screen
- Atau ada error message jika ada masalah

### Step 5: Login dengan Email & Password

- Email yang baru didaftar
- Password yang baru dibuat

---

## ⭐ Email Generation Feature

**Auto-Generated Email Format:**

```
test{timestamp}@infoma.com

Contoh:
test1700600000000@infoma.com
test1700600001000@infoma.com
test1700600002000@infoma.com
```

**Keuntungan:**

- ✅ Tidak perlu invent email sendiri
- ✅ Guaranteed UNIQUE (timestamp selalu berbeda)
- ✅ Sekali klik = selesai
- ✅ Tidak perlu manual generate email

✅ **Benar**: Gunakan email yang berbeda setiap kali

```
Percobaan 1: ikbal.test.1@gmail.com ✓
Percobaan 2: ikbal.test.2@gmail.com ✓
Percobaan 3: ikbal.2025@gmail.com ✓
```

---

## 🧹 Cara Clear Database

Ada 2 cara:

### Cara 1: Dari Register Screen (RECOMMENDED)

1. Buka register screen
2. Klik button "Hapus Data (Dev)" di bawah form
3. Klik "Hapus" pada dialog
4. Refresh halaman (F5)
5. Siap registrasi baru!

### Cara 2: Manual (Jika Cara 1 tidak work)

1. Buka DevTools browser (F12)
2. Tab: Application → Local Storage → http://localhost:xxxxx
3. Delete semua entries
4. Reload halaman (F5)

---

## 🎯 Test Scenarios

### Test 1: Registrasi Satu User

```
1. Register: mahasiswa@test.com (type: Mahasiswa)
2. Login: mahasiswa@test.com
3. Explore dashboard
4. Logout
```

### Test 2: Multiple Users (Different Types)

```
1. Clear database
2. Register: mahasiswa@test.com (type: Mahasiswa)
3. Logout
4. Register: penyedia@test.com (type: Penyedia)
5. Logout
6. Register: admin@test.com (type: Admin)
7. Logout
8. Login dengan salah satu akun untuk explore
```

### Test 3: Error Handling

```
1. Try registrasi dengan email yang sama 2x → Error ✓
2. Try registrasi dengan password < 6 char → Error ✓
3. Try registrasi dengan phone tidak valid → Error ✓
4. Try login dengan email salah → Error ✓
```

---

## 📊 Database Info

- **Lokasi**: Local device storage
- **Nama**: `asessment2_ppbl.db`
- **Persistent**: ✅ Yes (data bertahan saat app ditutup)
- **Clear**: Gunakan button "Hapus Data (Dev)" untuk reset

---

## 🆘 Troubleshooting

### Error: "Email sudah terdaftar"

**Solusi**: Clear database dengan button "Hapus Data (Dev)"

### Error: "Nomor telepon tidak valid"

**Solusi**: Gunakan format yang benar

```
✓ 081234567890 (harus mulai dengan 0, minimal 10 digit)
✗ 1234567890 (tidak mulai dengan 0)
✗ 0812 (terlalu pendek)
```

### Error: "Password minimal 6 karakter"

**Solusi**: Gunakan password dengan 6+ karakter

```
✓ pass123
✓ Test@2025
✓ 123456
✗ pass (hanya 4)
✗ 12 (hanya 2)
```

### Browser tidak update setelah click "Hapus Data"

**Solusi**: Refresh halaman secara manual

```
F5 atau Ctrl+R di keyboard
```

---

## ✨ Quick Test Credentials

Setelah clear database, bisa pakai ini untuk test:

```
Name: Test User
Email: test@example.com
Phone: 08123456789
Address: Jakarta
User Type: Mahasiswa
Password: test123
```

---

**Happy Testing! 🎉**

Untuk pertanyaan lebih lanjut, lihat:

- `DATABASE_GUIDE.md` - Database persistence explanation
- `SETUP_GUIDE.md` - Setup & installation
- `DEVELOPMENT.md` - Feature & architecture overview
