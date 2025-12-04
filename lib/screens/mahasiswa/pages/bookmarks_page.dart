import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/bookmark.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late DatabaseHelper _dbHelper;
  List<Bookmark> _bookmarks = [];
  Map<int, Listing?> _listingCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final userId = AuthService().userId;
      final bookmarks = await _dbHelper.getBookmarksByStudent(userId);

      if (mounted) {
        setState(() {
          _bookmarks = bookmarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookmarks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Listing?> _getListing(int listingId) async {
    if (_listingCache.containsKey(listingId)) {
      return _listingCache[listingId];
    }
    final listing = await _dbHelper.getListingById(listingId);
    _listingCache[listingId] = listing;
    return listing;
  }

  Future<void> _removeBookmark(int bookmarkId, int listingId) async {
    try {
      final userId = AuthService().userId;
      await _dbHelper.deleteBookmark(listingId, userId);
      setState(() {
        _bookmarks.removeWhere((b) => b.id == bookmarkId);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmark dihapus')));
      }
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _bookmarks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada bookmark',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadBookmarks,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return FutureBuilder<Listing?>(
                  future: _getListing(bookmark.listingId),
                  builder: (context, snapshot) {
                    final listing = snapshot.data;
                    return _buildBookmarkCard(bookmark, listing);
                  },
                );
              },
            ),
          );
  }

  Widget _buildBookmarkCard(Bookmark bookmark, Listing? listing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.grey[300],
                    child: listing?.image != null
                        ? Image.network(listing!.image!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                // Content
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing?.title ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${listing?.price.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${listing?.rating ?? 0.0}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Remove button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeBookmark(bookmark.id, bookmark.listingId),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
