import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../utils/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late DatabaseHelper _dbHelper;
  int _totalProviders = 0,
      _totalStudents = 0,
      _totalListings = 0,
      _totalAdmins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final providers = await _dbHelper.getUsersByType('penyedia');
      final students = await _dbHelper.getUsersByType('mahasiswa');
      final admins = await _dbHelper.getUsersByType('admin');
      final hunian = await _dbHelper.getListingsByType('hunian');
      final kegiatan = await _dbHelper.getListingsByType('kegiatan');
      final marketplace = await _dbHelper.getListingsByType('marketplace');

      setState(() {
        _totalProviders = providers.length;
        _totalStudents = students.length;
        _totalAdmins = admins.length;
        _totalListings = hunian.length + kegiatan.length + marketplace.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Dashboard Admin',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatCard(
              context,
              'Penyedia',
              _totalProviders,
              Icons.store,
              AppTheme.accentColor,
            ),
            _buildStatCard(
              context,
              'Mahasiswa',
              _totalStudents,
              Icons.school,
              AppTheme.secondaryColor,
            ),
            _buildStatCard(
              context,
              'Listing',
              _totalListings,
              Icons.list,
              AppTheme.primaryColor,
            ),
            _buildStatCard(
              context,
              'Admin',
              _totalAdmins,
              Icons.admin_panel_settings,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Statistik Listing',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: _loadListingStats(),
          builder: (c, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final stats = snapshot.data as Map<String, int>;
            return Column(
              children: [
                _listingStatRow('Hunian', stats['hunian'] ?? 0),
                _listingStatRow('Kegiatan Kampus', stats['kegiatan'] ?? 0),
                _listingStatRow('Marketplace', stats['marketplace'] ?? 0),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<Map<String, int>> _loadListingStats() async {
    final hunian = await _dbHelper.getListingsByType('hunian');
    final kegiatan = await _dbHelper.getListingsByType('kegiatan');
    final marketplace = await _dbHelper.getListingsByType('marketplace');
    return {
      'hunian': hunian.length,
      'kegiatan': kegiatan.length,
      'marketplace': marketplace.length,
    };
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
