import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late DatabaseHelper _dbHelper;
  List<Listing> _listings = [];
  int _totalViews = 0;
  double _averageRating = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = AuthService().userId;
      final listings = await _dbHelper.getListingsByProvider(userId);

      int totalViews = 0;
      double totalRating = 0;
      int ratingCount = 0;

      for (final listing in listings) {
        totalViews += listing.views;
        if (listing.reviewCount > 0) {
          totalRating += listing.rating * listing.reviewCount;
          ratingCount += listing.reviewCount;
        }
      }

      if (mounted) {
        setState(() {
          _listings = listings;
          _totalViews = totalViews;
          _averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final totalBookings = _listings.fold<int>(
      0,
      (sum, l) => sum + l.reviewCount,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _statCard(
              'Listing Aktif',
              _listings.length.toString(),
              Icons.list,
              AppTheme.primaryColor,
            ),
            _statCard(
              'Total Views',
              _totalViews.toString(),
              Icons.visibility,
              AppTheme.secondaryColor,
            ),
            _statCard(
              'Rating Rata-rata',
              _averageRating.toStringAsFixed(1),
              Icons.star,
              const Color(0xFF10B981),
            ),
            _statCard(
              'Ulasan',
              totalBookings.toString(),
              Icons.comment,
              const Color(0xFFF59E0B),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Performa Listing',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._listings.take(5).map((l) => _listingPerformance(l)).toList(),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _listingPerformance(Listing l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${l.views} views',
                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${l.rating} (${l.reviewCount} review)',
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(width: 12),
              Icon(Icons.attach_money, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Rp ${l.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
