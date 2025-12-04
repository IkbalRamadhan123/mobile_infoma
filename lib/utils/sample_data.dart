import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/listing.dart';
import '../models/user.dart';

class SampleData {
  static final _dbHelper = DatabaseHelper();

  // Seed categories into the database
  static Future<void> seedCategories() async {
    try {
      // Check if categories already exist
      final hunianCategories = await _dbHelper.getCategoriesByType('hunian');
      if (hunianCategories.isNotEmpty) {
        print('Categories already seeded, skipping...');
        return;
      }

      final hunianCats = [
        Category(
          id: 1,
          name: 'Apartemen',
          type: 'hunian',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Rumah Sewa',
          type: 'hunian',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 3,
          name: 'Kost',
          type: 'hunian',
          createdAt: DateTime.now(),
        ),
      ];

      final kegiatanCats = [
        Category(
          id: 4,
          name: 'Olahraga',
          type: 'kegiatan',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 5,
          name: 'Seni',
          type: 'kegiatan',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 6,
          name: 'Akademis',
          type: 'kegiatan',
          createdAt: DateTime.now(),
        ),
      ];

      final marketplaceCats = [
        Category(
          id: 7,
          name: 'Elektronik',
          type: 'marketplace',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 8,
          name: 'Fashion',
          type: 'marketplace',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 9,
          name: 'Buku',
          type: 'marketplace',
          createdAt: DateTime.now(),
        ),
      ];

      for (var cat in [...hunianCats, ...kegiatanCats, ...marketplaceCats]) {
        await _dbHelper.insertCategory(cat);
      }

      print('Categories seeded successfully');
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }

  // Seed sample users
  static Future<void> seedUsers() async {
    try {
      final existingUsers = await _dbHelper.getAllUsers();
      if (existingUsers.isNotEmpty) {
        print('Users already seeded, skipping...');
        return;
      }

      final penyedia1 = User(
        id: 1,
        name: 'Budi Santoso',
        email: 'budi@example.com',
        password: 'password123',
        phone: '081234567890',
        address: 'Jl. Merdeka No. 10, Jakarta',
        userType: 'penyedia',
        createdAt: DateTime.now(),
      );

      final penyedia2 = User(
        id: 2,
        name: 'Siti Nurhaliza',
        email: 'siti@example.com',
        password: 'password123',
        phone: '082345678901',
        address: 'Jl. Gatot Subroto No. 20, Bandung',
        userType: 'penyedia',
        createdAt: DateTime.now(),
      );

      final mahasiswa1 = User(
        id: 3,
        name: 'Ahmad Rizki',
        email: 'ahmad@student.com',
        password: 'password123',
        phone: '083456789012',
        address: 'Jl. Sudirman No. 5, Yogyakarta',
        userType: 'mahasiswa',
        createdAt: DateTime.now(),
      );

      final mahasiswa2 = User(
        id: 4,
        name: 'Dewi Lestari',
        email: 'dewi@student.com',
        password: 'password123',
        phone: '084567890123',
        address: 'Jl. Diponegoro No. 15, Surabaya',
        userType: 'mahasiswa',
        createdAt: DateTime.now(),
      );

      final admin = User(
        id: 5,
        name: 'Admin User',
        email: 'admin@example.com',
        password: 'admin123',
        phone: '089999999999',
        address: 'Jl. Admin No. 1, Jakarta',
        userType: 'admin',
        createdAt: DateTime.now(),
      );

      for (var user in [penyedia1, penyedia2, mahasiswa1, mahasiswa2, admin]) {
        await _dbHelper.insertUser(user);
      }

      print('Users seeded successfully');
    } catch (e) {
      print('Error seeding users: $e');
    }
  }

  // Seed sample listings
  static Future<void> seedListings() async {
    try {
      final existingListings = await _dbHelper.getListingsByType('hunian');
      if (existingListings.isNotEmpty) {
        print('Listings already seeded, skipping...');
        return;
      }

      final listings = [
        // Hunian listings from penyedia 1
        Listing(
          id: 1,
          providerId: 1,
          title: 'Apartemen Studio Nyaman',
          description:
              'Studio apartment modern dengan fasilitas lengkap, dekat kampus, aman 24 jam',
          type: 'hunian',
          category: 'Apartemen',
          subCategory: 'Modern',
          price: 2500000,
          image: 'https://via.placeholder.com/400x300?text=Apartemen+1',
          latitude: -6.2088,
          longitude: 106.8456,
          location: 'Jl. Merdeka, Jakarta',
          views: 150,
          rating: 4.5,
          createdAt: DateTime.now(),
        ),
        Listing(
          id: 2,
          providerId: 1,
          title: 'Kost Mahasiswa Terjangkau',
          description:
              'Kamar kost 2x3m, kasur lengkap, akses wifi, area bermain pingpong',
          type: 'hunian',
          category: 'Kost',
          subCategory: 'Standar',
          price: 500000,
          image: 'https://via.placeholder.com/400x300?text=Kost+1',
          latitude: -6.2100,
          longitude: 106.8470,
          location: 'Jl. Merdeka, Jakarta',
          views: 200,
          rating: 4.0,
          createdAt: DateTime.now(),
        ),

        // Hunian listings from penyedia 2
        Listing(
          id: 3,
          providerId: 2,
          title: 'Rumah Sewa 2 Lantai',
          description:
              'Rumah siap huni, 3 kamar tidur, 2 kamar mandi, halaman luas, lokasi strategis',
          type: 'hunian',
          category: 'Rumah Sewa',
          subCategory: 'Mewah',
          price: 5000000,
          image: 'https://via.placeholder.com/400x300?text=Rumah+1',
          latitude: -6.8830,
          longitude: 107.6104,
          location: 'Jl. Gatot Subroto, Bandung',
          views: 320,
          rating: 4.8,
          createdAt: DateTime.now(),
        ),

        // Kegiatan listings from penyedia 1
        Listing(
          id: 4,
          providerId: 1,
          title: 'Workshop Fotografi Dasar',
          description:
              'Belajar fotografi dari awal, lengkap dengan praktek langsung menggunakan DSLR',
          type: 'kegiatan',
          category: 'Workshop',
          subCategory: 'Seni',
          price: 150000,
          image: 'https://via.placeholder.com/400x300?text=Workshop+Fotografi',
          latitude: -6.2088,
          longitude: 106.8456,
          location: 'Jl. Merdeka, Jakarta',
          views: 180,
          rating: 4.6,
          createdAt: DateTime.now(),
          eventDate: DateTime.now().add(Duration(days: 7)),
          quota: '20',
        ),
        Listing(
          id: 5,
          providerId: 1,
          title: 'Kelas Yoga Pagi',
          description:
              'Yoga untuk pemula dan menengah, setiap hari Jumat pukul 06:00',
          type: 'kegiatan',
          category: 'Olahraga',
          subCategory: 'Fitness',
          price: 50000,
          image: 'https://via.placeholder.com/400x300?text=Yoga+Class',
          latitude: -6.2088,
          longitude: 106.8456,
          location: 'Jl. Merdeka, Jakarta',
          views: 240,
          rating: 4.7,
          createdAt: DateTime.now(),
          eventDate: DateTime.now().add(Duration(days: 2)),
          quota: '30',
        ),

        // Kegiatan listings from penyedia 2
        Listing(
          id: 6,
          providerId: 2,
          title: 'Seminar Teknologi AI',
          description:
              'Seminar internasional tentang Artificial Intelligence, pembicara dari universitas ternama',
          type: 'kegiatan',
          category: 'Seminar',
          subCategory: 'Akademis',
          price: 250000,
          image: 'https://via.placeholder.com/400x300?text=Seminar+AI',
          latitude: -6.8830,
          longitude: 107.6104,
          location: 'Jl. Gatot Subroto, Bandung',
          views: 450,
          rating: 4.9,
          createdAt: DateTime.now(),
          eventDate: DateTime.now().add(Duration(days: 14)),
          quota: '100',
        ),

        // Marketplace listings from penyedia 1
        Listing(
          id: 7,
          providerId: 1,
          title: 'Laptop Gaming Bekas - Condition 90%',
          description:
              'Laptop gaming ASUS ROG, spesifikasi tinggi, masih dalam kondisi baik',
          type: 'marketplace',
          category: 'Elektronik',
          subCategory: 'Laptop',
          price: 7000000,
          image: 'https://via.placeholder.com/400x300?text=Laptop+Gaming',
          latitude: -6.2088,
          longitude: 106.8456,
          location: 'Jl. Merdeka, Jakarta',
          views: 320,
          rating: 4.5,
          createdAt: DateTime.now(),
          condition: 'Like New',
        ),

        // Marketplace listings from penyedia 2
        Listing(
          id: 8,
          providerId: 2,
          title: 'Paket Buku Kuliah Teknik Informatika',
          description:
              'Buku-buku teknik informatika semester 1-3, catatan kuliah lengkap, harga bersahabat',
          type: 'marketplace',
          category: 'Buku',
          subCategory: 'Kuliah',
          price: 450000,
          image: 'https://via.placeholder.com/400x300?text=Buku+Kuliah',
          latitude: -6.8830,
          longitude: 107.6104,
          location: 'Jl. Gatot Subroto, Bandung',
          views: 180,
          rating: 4.3,
          createdAt: DateTime.now(),
          condition: 'Good',
        ),
      ];

      for (var listing in listings) {
        await _dbHelper.insertListing(listing);
      }

      print('Listings seeded successfully');
    } catch (e) {
      print('Error seeding listings: $e');
    }
  }

  // Main seed function
  static Future<void> seedAll() async {
    print('Starting to seed sample data...');
    await seedCategories();
    await seedUsers();
    await seedListings();
    print('Sample data seeding completed!');
  }
}
