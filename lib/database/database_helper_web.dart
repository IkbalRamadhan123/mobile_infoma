import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/listing.dart';
import '../models/category.dart';
import '../models/booking.dart';
import '../models/bookmark.dart';
import '../models/history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // In-memory simple stores for web fallback (non-persistent)
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _categories = [];
  // Separate storage for each listing type to emulate separate tables
  final List<Map<String, dynamic>> _listingsHunian = [];
  final List<Map<String, dynamic>> _listingsKegiatan = [];
  final List<Map<String, dynamic>> _listingsMarketplace = [];
  // Bookings storage (in-memory)
  final List<Map<String, dynamic>> _bookings = [];
  // Bookmarks and history (in-memory)
  final List<Map<String, dynamic>> _bookmarks = [];
  final List<Map<String, dynamic>> _histories = [];
  bool _initialized = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Ensure data is loaded from SharedPreferences on first access
  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      void _loadList(String key, List<Map<String, dynamic>> target) {
        final raw = prefs.getString(key);
        if (raw == null || raw.isEmpty) return;
        try {
          final decoded = jsonDecode(raw) as List<dynamic>;
          target.clear();
          for (final e in decoded) {
            target.add(Map<String, dynamic>.from(e as Map));
          }
        } catch (_) {}
      }

      _loadList('web_users', _users);
      _loadList('web_categories', _categories);
      _loadList('web_listings_hunian', _listingsHunian);
      _loadList('web_listings_kegiatan', _listingsKegiatan);
      _loadList('web_listings_marketplace', _listingsMarketplace);
      _loadList('web_bookings', _bookings);
      _loadList('web_bookmarks', _bookmarks);
      _loadList('web_histories', _histories);
    } catch (e) {
      // ignore
    }
    _initialized = true;
  }

  Future<void> _saveAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('web_users', jsonEncode(_users));
      prefs.setString('web_categories', jsonEncode(_categories));
      prefs.setString('web_listings_hunian', jsonEncode(_listingsHunian));
      prefs.setString('web_listings_kegiatan', jsonEncode(_listingsKegiatan));
      prefs.setString(
        'web_listings_marketplace',
        jsonEncode(_listingsMarketplace),
      );
      prefs.setString('web_bookings', jsonEncode(_bookings));
      prefs.setString('web_bookmarks', jsonEncode(_bookmarks));
      prefs.setString('web_histories', jsonEncode(_histories));
    } catch (_) {}
  }

  // On web we don't have a real database; provide simple async-compatible methods
  Future<void> get database async {
    await _ensureInit();
    return;
  }

  Future<int> insertUser(User user) async {
    await _ensureInit();
    final id = (_users.isEmpty ? 1 : (_users.last['id'] as int) + 1);
    final map = user.toMap(includeId: false);
    map['id'] = id;
    _users.add(map);
    await _saveAll();
    return id;
  }

  Future<User?> getUserById(int id) async {
    await _ensureInit();
    final map = _users.firstWhere(
      (m) => (m['id'] as int) == id,
      orElse: () => {},
    );
    if (map.isNotEmpty) return User.fromMap(map);
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    await _ensureInit();
    final map = _users.firstWhere(
      (m) => (m['email'] as String).toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    if (map.isNotEmpty) return User.fromMap(map);
    return null;
  }

  Future<List<User>> getAllUsers() async {
    await _ensureInit();
    return _users.map((m) => User.fromMap(m)).toList();
  }

  Future<int> insertCategory(Category category) async {
    await _ensureInit();
    final id = (_categories.isEmpty ? 1 : (_categories.last['id'] as int) + 1);
    final map = category.toMap();
    map['id'] = id;
    _categories.add(map);
    await _saveAll();
    return id;
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    await _ensureInit();
    final matches =
        _categories.where((m) => (m['type'] as String) == type).toList();
    return matches.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> insertListing(Listing listing) async {
    await _ensureInit();
    final table = _listForType(listing.type);
    final list =
        table == 'hunian'
            ? _listingsHunian
            : table == 'kegiatan'
            ? _listingsKegiatan
            : _listingsMarketplace;
    final id = (list.isEmpty ? 1 : (list.last['id'] as int) + 1);
    final map = listing.toMap();
    map['id'] = id;
    list.add(map);
    await _saveAll();
    return id;
  }

  Future<List<Listing>> getListingsByType(String type) async {
    await _ensureInit();
    final table = _listForType(type);
    final list =
        table == 'hunian'
            ? _listingsHunian
            : table == 'kegiatan'
            ? _listingsKegiatan
            : _listingsMarketplace;
    final matches = list.where((m) => (m['type'] as String) == type).toList();
    return matches.map((m) => Listing.fromMap(m)).toList();
  }

  Future<Listing?> getListingById(int id) async {
    await _ensureInit();
    final lists = [_listingsHunian, _listingsKegiatan, _listingsMarketplace];
    for (final l in lists) {
      final map = l.firstWhere((m) => (m['id'] as int) == id, orElse: () => {});
      if (map.isNotEmpty) return Listing.fromMap(map);
    }
    return null;
  }

  Future<Listing?> getListingByIdAndType(int id, String type) async {
    await _ensureInit();
    final list =
        type.toLowerCase() == 'hunian'
            ? _listingsHunian
            : type.toLowerCase() == 'kegiatan'
            ? _listingsKegiatan
            : _listingsMarketplace;
    final map = list.firstWhere(
      (m) => (m['id'] as int) == id,
      orElse: () => {},
    );
    if (map.isNotEmpty) return Listing.fromMap(map);
    return null;
  }

  // Fallback no-op implementations for other methods used by the app
  Future<List<Listing>> getListingsByProvider(int providerId) async {
    await _ensureInit();
    final results = <Listing>[];
    for (final l in [
      _listingsHunian,
      _listingsKegiatan,
      _listingsMarketplace,
    ]) {
      final matches =
          l.where((m) => (m['providerId'] as int) == providerId).toList();
      results.addAll(matches.map((m) => Listing.fromMap(m)));
    }
    return results;
  }

  Future<List<Listing>> getListingsByCategory(
    String type,
    String category,
  ) async {
    await _ensureInit();
    final table = _listForType(type);
    final list =
        table == 'hunian'
            ? _listingsHunian
            : table == 'kegiatan'
            ? _listingsKegiatan
            : _listingsMarketplace;
    final matches =
        list
            .where(
              (m) =>
                  (m['type'] as String) == type &&
                  (m['category'] as String) == category,
            )
            .toList();
    return matches.map((m) => Listing.fromMap(m)).toList();
  }

  Future<List<Listing>> searchListings(String searchTerm) async {
    await _ensureInit();
    final results = <Listing>[];
    for (final l in [
      _listingsHunian,
      _listingsKegiatan,
      _listingsMarketplace,
    ]) {
      final matches =
          l
              .where(
                (m) => (m['title'] as String).toLowerCase().contains(
                  searchTerm.toLowerCase(),
                ),
              )
              .toList();
      results.addAll(matches.map((m) => Listing.fromMap(m)));
    }
    return results;
  }

  Future<int> updateListing(Listing listing) async {
    await _ensureInit();
    final table = _listForType(listing.type);
    final list =
        table == 'hunian'
            ? _listingsHunian
            : table == 'kegiatan'
            ? _listingsKegiatan
            : _listingsMarketplace;
    final index = list.indexWhere((m) => (m['id'] as int) == listing.id);
    if (index >= 0) {
      list[index] = listing.toMap();
      await _saveAll();
      return 1;
    }
    return 0;
  }

  // ==================== BOOKING OPERATIONS (web in-memory) ====================

  Future<int> insertBooking(Booking booking) async {
    await _ensureInit();
    final id = (_bookings.isEmpty ? 1 : (_bookings.last['id'] as int) + 1);
    final map = booking.toMap();
    map['id'] = id;
    _bookings.add(map);
    await _saveAll();
    return id;
  }

  Future<Booking?> getBookingById(int id) async {
    await _ensureInit();
    final map = _bookings.firstWhere(
      (m) => (m['id'] as int) == id,
      orElse: () => {},
    );
    if (map.isNotEmpty) return Booking.fromMap(map);
    return null;
  }

  Future<List<Booking>> getBookingsByStudent(int studentId) async {
    await _ensureInit();
    final matches =
        _bookings.where((m) => (m['studentId'] as int) == studentId).toList();
    return matches.map((m) => Booking.fromMap(m)).toList();
  }

  Future<List<Booking>> getBookingsByProvider(int providerId) async {
    await _ensureInit();
    final matches =
        _bookings.where((m) => (m['providerId'] as int) == providerId).toList();
    return matches.map((m) => Booking.fromMap(m)).toList();
  }

  Future<List<Booking>> getPendingBookings(int providerId) async {
    await _ensureInit();
    final matches =
        _bookings
            .where(
              (m) =>
                  (m['providerId'] as int) == providerId &&
                  (m['status'] as String) == 'pending',
            )
            .toList();
    return matches.map((m) => Booking.fromMap(m)).toList();
  }

  Future<int> updateBooking(Booking booking) async {
    await _ensureInit();
    final index = _bookings.indexWhere((m) => (m['id'] as int) == booking.id);
    if (index >= 0) {
      _bookings[index] = booking.toMap();
      await _saveAll();
      return 1;
    }
    return 0;
  }

  Future<int> deleteBooking(int id) async {
    await _ensureInit();
    final before = _bookings.length;
    _bookings.removeWhere((m) => (m['id'] as int) == id);
    await _saveAll();
    return before == _bookings.length ? 0 : 1;
  }

  Future<int> deleteListing(int id) async {
    await _ensureInit();
    for (final l in [
      _listingsHunian,
      _listingsKegiatan,
      _listingsMarketplace,
    ]) {
      final before = l.length;
      l.removeWhere((m) => (m['id'] as int) == id);
      if (l.length != before) {
        await _saveAll();
        return 1;
      }
    }
    return 0;
  }

  // ==================== BOOKMARK OPERATIONS (web in-memory) ====================

  Future<int> insertBookmark(Bookmark bookmark) async {
    await _ensureInit();
    final id = (_bookmarks.isEmpty ? 1 : (_bookmarks.last['id'] as int) + 1);
    final map = bookmark.toMap();
    map['id'] = id;
    _bookmarks.add(map);
    await _saveAll();
    return id;
  }

  Future<List<Bookmark>> getBookmarksByStudent(int studentId) async {
    await _ensureInit();
    final matches =
        _bookmarks.where((m) => (m['studentId'] as int) == studentId).toList();
    return matches.map((m) => Bookmark.fromMap(m)).toList();
  }

  Future<bool> isListingBookmarked(int listingId, int studentId) async {
    await _ensureInit();
    return _bookmarks.any(
      (m) =>
          (m['listingId'] as int) == listingId &&
          (m['studentId'] as int) == studentId,
    );
  }

  Future<int> deleteBookmark(int listingId, int studentId) async {
    await _ensureInit();
    final before = _bookmarks.length;
    _bookmarks.removeWhere(
      (m) =>
          (m['listingId'] as int) == listingId &&
          (m['studentId'] as int) == studentId,
    );
    await _saveAll();
    return before == _bookmarks.length ? 0 : 1;
  }

  // ==================== HISTORY OPERATIONS (web in-memory) ====================

  Future<int> insertHistory(History history) async {
    await _ensureInit();
    final id = (_histories.isEmpty ? 1 : (_histories.last['id'] as int) + 1);
    final map = history.toMap();
    map['id'] = id;
    _histories.add(map);
    await _saveAll();
    return id;
  }

  Future<List<History>> getHistoryByStudent(int studentId) async {
    await _ensureInit();
    final matches =
        _histories.where((m) => (m['studentId'] as int) == studentId).toList();
    return matches.map((m) => History.fromMap(m)).toList();
  }

  // ==================== USER OPERATIONS (updates) ====================

  Future<int> updateUser(User user) async {
    await _ensureInit();
    final index = _users.indexWhere((m) => (m['id'] as int) == user.id);
    if (index >= 0) {
      _users[index] = user.toMap();
      await _saveAll();
      return 1;
    }
    return 0;
  }

  Future<void> updateUserProfileImage(int userId, String imagePath) async {
    await _ensureInit();
    final index = _users.indexWhere((m) => (m['id'] as int) == userId);
    if (index >= 0) {
      _users[index]['profileImage'] = imagePath;
      await _saveAll();
    }
  }

  Future<List<User>> getUsersByType(String userType) async {
    await _ensureInit();
    final matches =
        _users.where((m) => (m['userType'] as String) == userType).toList();
    return matches.map((m) => User.fromMap(m)).toList();
  }

  // ==================== CATEGORY OPERATIONS ====================

  Future<int> deleteCategory(int id) async {
    await _ensureInit();
    final before = _categories.length;
    _categories.removeWhere((m) => (m['id'] as int) == id);
    await _saveAll();
    return before == _categories.length ? 0 : 1;
  }

  // ==================== IMAGE HELPERS ====================

  Future<void> saveListingImages(int listingId, List<String> imagePaths) async {
    await _ensureInit();
    final listing = await getListingById(listingId);
    if (listing != null) {
      final imgJson = imagePaths.join(',');
      // update underlying map
      for (final list in [
        _listingsHunian,
        _listingsKegiatan,
        _listingsMarketplace,
      ]) {
        final idx = list.indexWhere((m) => (m['id'] as int) == listingId);
        if (idx >= 0) {
          list[idx]['additionalImages'] = imgJson;
          await _saveAll();
          break;
        }
      }
    }
  }

  Future<List<String>> getListingImages(int listingId) async {
    await _ensureInit();
    final listing = await getListingById(listingId);
    if (listing?.additionalImages != null &&
        listing!.additionalImages!.isNotEmpty) {
      return listing.additionalImages!
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<void> deleteDatabase() async {
    _users.clear();
    _categories.clear();
    _listingsHunian.clear();
    _listingsKegiatan.clear();
    _listingsMarketplace.clear();
    _bookings.clear();
    _bookmarks.clear();
    _histories.clear();
    await _saveAll();
  }

  Future<void> clearAllTables() async {
    await deleteDatabase();
  }

  String _listForType(String type) {
    switch (type.toLowerCase()) {
      case 'hunian':
        return 'hunian';
      case 'kegiatan':
        return 'kegiatan';
      case 'marketplace':
        return 'marketplace';
      default:
        return 'hunian';
    }
  }
}
