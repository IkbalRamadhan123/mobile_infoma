import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../database/database_helper.dart';
import '../../../models/user.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DatabaseHelper _dbHelper;
  User? _currentUser;
  int _totalBookings = 0;
  int _totalRegistrations = 0;
  int _totalPurchases = 0;
  int _pendingBookings = 0;
  List<Map<String, dynamic>> _recentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final authService = AuthService();
      final userId = authService.userId;

      if (userId == 0) {
        print('Error: userId is 0, user not logged in');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final user = await _dbHelper.getUserById(userId);
      if (user == null) {
        print('Error: user not found in database for id $userId');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final allBookings = await _dbHelper.getBookingsByStudent(userId);
      final history = await _dbHelper.getHistoryByStudent(userId);

      if (mounted) {
        setState(() {
          _currentUser = user;

          // Count bookings by type
          _totalBookings =
              allBookings.where((b) => b.bookingType == 'booking').length;
          _totalRegistrations =
              allBookings.where((b) => b.bookingType == 'registrasi').length;
          _totalPurchases =
              allBookings.where((b) => b.bookingType == 'pembelian').length;
          _pendingBookings =
              allBookings.where((b) => b.status == 'pending').length;
          _recentHistory = (history as List).cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header greeting
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hallo, ${_currentUser?.name.split(' ').first}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berikut aktivitas Anda',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                'Booking',
                _totalBookings.toString(),
                Icons.home,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                context,
                'Registrasi',
                _totalRegistrations.toString(),
                Icons.event,
                AppTheme.secondaryColor,
              ),
              _buildStatCard(
                context,
                'Pembelian',
                _totalPurchases.toString(),
                Icons.shopping_bag,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                context,
                'Menunggu',
                _pendingBookings.toString(),
                Icons.schedule,
                const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent History
          Text(
            'Aktivitas Terbaru',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_recentHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada aktivitas',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children:
                  _recentHistory.take(5).map((item) {
                    final title = item['title'] ?? 'Unknown';
                    final viewedAt = DateTime.parse(item['viewedAt'] as String);
                    final now = DateTime.now();
                    final difference = now.difference(viewedAt);

                    String timeAgo;
                    if (difference.inMinutes < 1) {
                      timeAgo = 'Baru saja';
                    } else if (difference.inMinutes < 60) {
                      timeAgo = '${difference.inMinutes} menit lalu';
                    } else if (difference.inHours < 24) {
                      timeAgo = '${difference.inHours} jam lalu';
                    } else {
                      timeAgo = '${difference.inDays} hari lalu';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.visibility,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
