import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/listing.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/bookmark.dart';
import '../models/category.dart';
import '../models/history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> _resetInstance() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
    print('DatabaseHelper: Instance reset, database closed');
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'asessment2_ppbl.db');
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT NOT NULL,
        userType TEXT NOT NULL,
        profileImage TEXT,
        bio TEXT,
        address TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parentCategory TEXT,
        isSubCategory INTEGER NOT NULL DEFAULT 0,
        icon TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Listings Tables (separated by type)
    Future<void> createListingTable(String tableName) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          providerId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          subCategory TEXT NOT NULL,
          price REAL NOT NULL,
          image TEXT,
          additionalImages TEXT,
          latitude REAL,
          longitude REAL,
          location TEXT,
          views INTEGER NOT NULL DEFAULT 0,
          rating REAL NOT NULL DEFAULT 0,
          reviewCount INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          eventDate TEXT,
          quota TEXT,
          condition TEXT DEFAULT 'baru',
          isActive INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (providerId) REFERENCES users(id)
        )
      ''');
    }

    await createListingTable('listings_hunian');
    await createListingTable('listings_kegiatan');
    await createListingTable('listings_marketplace');

    // Bookings Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listingId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        providerId INTEGER NOT NULL,
        bookingType TEXT NOT NULL,
        status TEXT NOT NULL,
        rejectionReason TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        totalPrice REAL NOT NULL,
        bookingDate TEXT NOT NULL,
        completionDate TEXT,
        notes TEXT,
        FOREIGN KEY (studentId) REFERENCES users(id),
        FOREIGN KEY (providerId) REFERENCES users(id)
      )
    ''');

    // Reviews Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listingId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        rating REAL NOT NULL,
        title TEXT NOT NULL,
        comment TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isVerified INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (studentId) REFERENCES users(id)
      )
    ''');

    // Bookmarks Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listingId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        bookmarkedAt TEXT NOT NULL,
        UNIQUE(listingId, studentId),
        FOREIGN KEY (studentId) REFERENCES users(id)
      )
    ''');

    // History Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        listingId INTEGER NOT NULL,
        type TEXT NOT NULL,
        viewedAt TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES users(id)
      )
    ''');
  }

  // ==================== USER OPERATIONS ====================

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(includeId: false));
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      print('DatabaseHelper: Querying user with email: $email');

      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      print('DatabaseHelper: Query result - Found ${maps.length} user(s)');

      if (maps.isNotEmpty) {
        print('DatabaseHelper: User found with email: $email');
        return User.fromMap(maps.first);
      }

      print('DatabaseHelper: No user found with email: $email');
      return null;
    } catch (e) {
      print('DatabaseHelper: Error querying user by email: $e');
      return null;
    }
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<List<User>> getUsersByType(String userType) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'userType = ?',
      whereArgs: [userType],
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // ==================== CATEGORY OPERATIONS ====================

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ? AND isSubCategory = 0',
      whereArgs: [type],
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getSubCategories(
    String parentCategory,
    String type,
  ) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ? AND parentCategory = ? AND isSubCategory = 1',
      whereArgs: [type, parentCategory],
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== LISTING OPERATIONS ====================

  Future<int> insertListing(Listing listing) async {
    final db = await database;
    final table = _tableForType(listing.type);
    return await db.insert(table, listing.toMap());
  }

  Future<Listing?> getListingById(int id) async {
    final db = await database;
    final tables = [
      'listings_hunian',
      'listings_kegiatan',
      'listings_marketplace',
    ];
    for (final table in tables) {
      final maps = await db.query(table, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) return Listing.fromMap(maps.first);
    }
    return null;
  }

  Future<Listing?> getListingByIdAndType(int id, String type) async {
    final db = await database;
    final table = _tableForType(type);
    final maps = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Listing.fromMap(maps.first);
    return null;
  }

  Future<List<Listing>> getListingsByType(String type) async {
    final db = await database;
    final table = _tableForType(type);
    final maps = await db.query(
      table,
      where: 'type = ? AND isActive = 1',
      whereArgs: [type],
    );
    return maps.map((map) => Listing.fromMap(map)).toList();
  }

  Future<List<Listing>> getListingsByProvider(int providerId) async {
    final db = await database;
    final tables = [
      'listings_hunian',
      'listings_kegiatan',
      'listings_marketplace',
    ];
    final results = <Listing>[];
    for (final table in tables) {
      final maps = await db.query(
        table,
        where: 'providerId = ?',
        whereArgs: [providerId],
      );
      results.addAll(maps.map((m) => Listing.fromMap(m)));
    }
    return results;
  }

  Future<List<Listing>> getListingsByCategory(
    String type,
    String category,
  ) async {
    final db = await database;
    final table = _tableForType(type);
    final maps = await db.query(
      table,
      where: 'type = ? AND category = ? AND isActive = 1',
      whereArgs: [type, category],
    );
    return maps.map((map) => Listing.fromMap(map)).toList();
  }

  Future<List<Listing>> searchListings(String searchTerm) async {
    final db = await database;
    final tables = [
      'listings_hunian',
      'listings_kegiatan',
      'listings_marketplace',
    ];
    final results = <Listing>[];
    for (final table in tables) {
      final maps = await db.query(
        table,
        where: 'title LIKE ? AND isActive = 1',
        whereArgs: ['%$searchTerm%'],
      );
      results.addAll(maps.map((m) => Listing.fromMap(m)));
    }
    return results;
  }

  Future<int> updateListing(Listing listing) async {
    final db = await database;
    final table = _tableForType(listing.type);
    return await db.update(
      table,
      listing.toMap(),
      where: 'id = ?',
      whereArgs: [listing.id],
    );
  }

  Future<int> deleteListing(int id) async {
    final db = await database;
    final tables = [
      'listings_hunian',
      'listings_kegiatan',
      'listings_marketplace',
    ];
    for (final table in tables) {
      final deleted = await db.delete(table, where: 'id = ?', whereArgs: [id]);
      if (deleted > 0) return deleted;
    }
    return 0;
  }

  Future<void> incrementListingViews(int listingId) async {
    final listing = await getListingById(listingId);
    if (listing != null) {
      final updated = listing.copyWith(views: listing.views + 1);
      final table = _tableForType(listing.type);
      final db = await database;
      await db.update(
        table,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [listingId],
      );
    }
  }

  // ==================== BOOKING OPERATIONS ====================

  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await database;
    final maps = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Booking.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Booking>> getBookingsByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookingsByProvider(int providerId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'providerId = ?',
      whereArgs: [providerId],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getPendingBookings(int providerId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'providerId = ? AND status = ?',
      whereArgs: [providerId, 'pending'],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await database;
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== REVIEW OPERATIONS ====================

  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert('reviews', review.toMap());
  }

  Future<List<Review>> getReviewsByListing(int listingId) async {
    final db = await database;
    final maps = await db.query(
      'reviews',
      where: 'listingId = ?',
      whereArgs: [listingId],
    );
    return maps.map((map) => Review.fromMap(map)).toList();
  }

  Future<List<Review>> getReviewsByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'reviews',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => Review.fromMap(map)).toList();
  }

  Future<int> updateReview(Review review) async {
    final db = await database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await database;
    return await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== BOOKMARK OPERATIONS ====================

  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    return await db.insert('bookmarks', bookmark.toMap());
  }

  Future<List<Bookmark>> getBookmarksByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<bool> isListingBookmarked(int listingId, int studentId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'listingId = ? AND studentId = ?',
      whereArgs: [listingId, studentId],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteBookmark(int listingId, int studentId) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'listingId = ? AND studentId = ?',
      whereArgs: [listingId, studentId],
    );
  }

  // ==================== HISTORY OPERATIONS ====================

  Future<int> insertHistory(History history) async {
    final db = await database;
    return await db.insert('history', history.toMap());
  }

  Future<List<History>> getHistoryByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'viewedAt DESC',
    );
    return maps.map((map) => History.fromMap(map)).toList();
  }

  Future<void> clearHistory(int studentId) async {
    final db = await database;
    await db.delete('history', where: 'studentId = ?', whereArgs: [studentId]);
  }

  // ==================== UTILITY OPERATIONS ====================

  Future<void> deleteDatabase() async {
    try {
      print('DatabaseHelper: Starting database reset...');

      // Close the database connection if open
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        print('DatabaseHelper: Database connection closed');
      }

      // Reset the in-memory reference so a fresh DB will be created on next access
      _database = null;

      final path = join(await getDatabasesPath(), 'asessment2_ppbl.db');
      // On web we cannot delete the underlying IndexedDB file easily; just reset state
      print('DatabaseHelper: Database reset for fresh start. Path: $path');
    } catch (e) {
      print('DatabaseHelper: Error during reset: $e');
    }
  }

  // ==================== IMAGE OPERATIONS ====================

  /// Save listing images as JSON string
  Future<void> saveListingImages(int listingId, List<String> imagePaths) async {
    if (imagePaths.isEmpty) return;

    try {
      final db = await database;
      final imageJson = imagePaths.join(','); // Simple comma-separated format
      // Need to find which table contains this listing
      final listing = await getListingById(listingId);
      if (listing != null) {
        final table = _tableForType(listing.type);
        await db.update(
          table,
          {'additionalImages': imageJson},
          where: 'id = ?',
          whereArgs: [listingId],
        );
      }
    } catch (e) {
      print('Error saving listing images: $e');
    }
  }

  /// Get listing images
  Future<List<String>> getListingImages(int listingId) async {
    try {
      final listing = await getListingById(listingId);
      if (listing?.additionalImages != null &&
          listing!.additionalImages!.isNotEmpty) {
        return listing.additionalImages!
            .split(',')
            .where((img) => img.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting listing images: $e');
      return [];
    }
  }

  String _tableForType(String type) {
    switch (type.toLowerCase()) {
      case 'hunian':
        return 'listings_hunian';
      case 'kegiatan':
        return 'listings_kegiatan';
      case 'marketplace':
        return 'listings_marketplace';
      default:
        return 'listings_hunian';
    }
  }

  /// Update user profile image
  Future<void> updateUserProfileImage(int userId, String imagePath) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {'profileImage': imagePath},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error updating user profile image: $e');
    }
  }

  Future<void> clearAllTables() async {
    try {
      print('DatabaseHelper: Clearing all tables...');

      // First close and reset the database instance
      await _resetInstance();

      // Re-open database
      final db = await database;

      // Delete in reverse order of creation to avoid foreign key issues
      await db.delete('history');
      print('DatabaseHelper: history table cleared');

      await db.delete('bookmarks');
      print('DatabaseHelper: bookmarks table cleared');

      await db.delete('reviews');
      print('DatabaseHelper: reviews table cleared');

      await db.delete('bookings');
      print('DatabaseHelper: bookings table cleared');

      await db.delete('listings_hunian');
      print('DatabaseHelper: listings_hunian table cleared');

      await db.delete('listings_kegiatan');
      print('DatabaseHelper: listings_kegiatan table cleared');

      await db.delete('listings_marketplace');
      print('DatabaseHelper: listings_marketplace table cleared');

      await db.delete('categories');
      print('DatabaseHelper: categories table cleared');

      await db.delete('users');
      print('DatabaseHelper: users table cleared');

      print('DatabaseHelper: All tables cleared successfully');

      // Simple verification without using Sqflite helper
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final userCount = (result.isNotEmpty ? result.first['count'] as int : 0);
      print('DatabaseHelper: Verification - Users remaining: $userCount');
    } catch (e) {
      print('DatabaseHelper: Error clearing tables: $e');
      rethrow;
    }
  }
}
