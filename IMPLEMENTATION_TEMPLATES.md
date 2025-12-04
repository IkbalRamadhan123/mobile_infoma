# 📖 Implementation Templates & Examples

Dokumen ini berisi template dan contoh kode untuk mengimplementasi fitur-fitur yang belum selesai.

---

## 1. Profile Page Template

```dart
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userFuture;
  final _dbHelper = DatabaseHelper();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = AuthService().userId;
    _userFuture = _dbHelper.getUserById(userId).then((user) {
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _bioController.text = user.bio ?? '';
      }
      return user;
    });
  }

  Future<void> _updateProfile(User user) async {
    final updated = user.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      bio: _bioController.text,
    );
    await _dbHelper.updateUser(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture (Placeholder)
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: user.profileImage != null
                            ? Image.network(user.profileImage!, fit: BoxFit.cover)
                            : const Icon(Icons.person, size: 60),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Form fields
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _updateProfile(user),
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

---

## 2. Bookmarks Page Template

```dart
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/bookmark.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/bookmark_card.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _dbHelper = DatabaseHelper();
  late Future<List<(Bookmark, Listing)>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    final userId = AuthService().userId;
    _bookmarksFuture = _getBookmarks(userId);
  }

  Future<List<(Bookmark, Listing)>> _getBookmarks(int userId) async {
    final bookmarks = await _dbHelper.getBookmarksByStudent(userId);
    final result = <(Bookmark, Listing)>[];

    for (final bookmark in bookmarks) {
      final listing = await _dbHelper.getListingById(bookmark.listingId);
      if (listing != null) {
        result.add((bookmark, listing));
      }
    }
    return result;
  }

  Future<void> _removeBookmark(int listingId) async {
    final userId = AuthService().userId;
    await _dbHelper.deleteBookmark(listingId, userId);
    setState(() {
      _bookmarksFuture = _getBookmarks(userId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<(Bookmark, Listing)>>(
      future: _bookmarksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_outline, size: 64),
                const SizedBox(height: 16),
                Text('Belum ada simpanan', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final (_, listing) = bookmarks[index];
            return BookmarkCard(
              title: listing.title,
              image: listing.image,
              price: listing.price,
              category: listing.subCategory,
              onTap: () {
                // Navigate to detail
              },
              onRemove: () => _removeBookmark(listing.id),
            );
          },
        );
      },
    );
  }
}
```

---

## 3. Bookings Page Template

```dart
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/booking.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<List<BookingItem>> _getBookings(String status) async {
    final userId = AuthService().userId;
    final bookings = await _dbHelper.getBookingsByStudent(userId);

    List<Booking> filtered = status == 'all'
        ? bookings
        : bookings.where((b) => b.status == status).toList();

    final result = <BookingItem>[];
    for (final booking in filtered) {
      final listing = await _dbHelper.getListingById(booking.listingId);
      if (listing != null) {
        result.add(BookingItem(booking, listing));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BookingsList(future: _getBookings('all')),
              _BookingsList(future: _getBookings('pending')),
              _BookingsList(future: _getBookings('approved')),
              _BookingsList(future: _getBookings('rejected')),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingsList extends StatelessWidget {
  final Future<List<BookingItem>> future;

  const _BookingsList({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Tidak ada booking'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.listing.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${item.booking.status}'),
                        Text('Rp ${item.booking.totalPrice}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (item.booking.status == 'rejected' && item.booking.rejectionReason != null)
                      Text('Alasan: ${item.booking.rejectionReason}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BookingItem {
  final Booking booking;
  final Listing listing;

  BookingItem(this.booking, this.listing);
}
```

---

## 4. Listing Detail Page Template

```dart
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/listing.dart';
import '../../../models/review.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';

class ListingDetailPage extends StatefulWidget {
  final int listingId;

  const ListingDetailPage({
    Key? key,
    required this.listingId,
  }) : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  final _dbHelper = DatabaseHelper();
  late Future<Listing?> _listingFuture;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _listingFuture = _dbHelper.getListingById(widget.listingId).then((listing) {
      if (listing != null) {
        _dbHelper.incrementListingViews(listing.id);
      }
      return listing;
    });
    _reviewsFuture = _dbHelper.getReviewsByListing(widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: FutureBuilder<Listing?>(
        future: _listingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final listing = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: listing.image != null
                        ? Image.network(listing.image!, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 80),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Rp ${listing.price}', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                        )),
                        const SizedBox(height: 16),
                        Text(listing.description),
                        const SizedBox(height: 16),
                        // Reviews
                        Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                        FutureBuilder<List<Review>>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            final reviews = snapshot.data ?? [];
                            if (reviews.isEmpty) {
                              return const Text('Belum ada review');
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(review.title, style: Theme.of(context).textTheme.titleSmall),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: i < review.rating.toInt()
                                                      ? AppTheme.warningColor
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(review.comment),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open booking dialog
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
```

---

## 5. Penyedia Home Template

```dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'pages/dashboard_page.dart';
import 'pages/listings_page.dart';
import 'pages/bookings_page.dart';
import 'pages/profile_page.dart';

class PenyediaHome extends StatefulWidget {
  const PenyediaHome({Key? key}) : super(key: key);

  @override
  State<PenyediaHome> createState() => _PenyediaHomeState();
}

class _PenyediaHomeState extends State<PenyediaHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ListingsPage(),
    const BookingsPage(),
    const ProfilePage(),
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penyedia'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Listing'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
```

---

## 6. Admin Dashboard Template

```dart
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../utils/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _getStats();
  }

  Future<Map<String, dynamic>> _getStats() async {
    final users = await _dbHelper.getAllUsers();
    final listings = await _dbHelper.getListingsByType('hunian'); // all types

    final mahasiswa = users.where((u) => u.userType == 'mahasiswa').length;
    final penyedia = users.where((u) => u.userType == 'penyedia').length;
    final totalListings = listings.length;

    return {
      'mahasiswa': mahasiswa,
      'penyedia': penyedia,
      'listings': totalListings,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final stats = snapshot.data!;
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatCard(
                  title: 'Total Mahasiswa',
                  value: '${stats['mahasiswa']}',
                  icon: Icons.school,
                  color: AppTheme.primaryColor,
                ),
                _StatCard(
                  title: 'Total Penyedia',
                  value: '${stats['penyedia']}',
                  icon: Icons.storefront,
                  color: AppTheme.secondaryColor,
                ),
                _StatCard(
                  title: 'Total Listing',
                  value: '${stats['listings']}',
                  icon: Icons.inventory_2,
                  color: AppTheme.accentColor,
                ),
                // Add more stats as needed
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

---

## Tips for Implementation

### 1. **Async/Await Best Practices**

```dart
// Good
Future<void> _loadData() async {
  try {
    final data = await _dbHelper.getData();
    setState(() => _data = data);
  } catch (e) {
    print('Error: $e');
  }
}

// Use FutureBuilder for UI
FutureBuilder<Data>(
  future: _dataFuture,
  builder: (context, snapshot) {
    if (snapshot.hasData) return Text(snapshot.data!);
    if (snapshot.hasError) return Text('Error');
    return CircularProgressIndicator();
  },
)
```

### 2. **Navigation Pattern**

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => DestinationPage(param: value)),
);

// With pop and result
final result = await Navigator.of(context).push<String>(
  MaterialPageRoute(builder: (context) => EditPage()),
);
```

### 3. **State Management**

```dart
// Update UI after database operation
setState(() {
  _listFuture = _dbHelper.getData(); // Refetch data
});
```

### 4. **Error Handling**

```dart
try {
  await _dbHelper.insert(item);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Berhasil')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

**Gunakan template ini sebagai starting point untuk implementasi fitur-fitur selanjutnya!**
