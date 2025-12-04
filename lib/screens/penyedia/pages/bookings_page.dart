import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/booking.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';

class PenyediaBookingsPage extends StatefulWidget {
  const PenyediaBookingsPage({Key? key}) : super(key: key);

  @override
  State<PenyediaBookingsPage> createState() => _PenyediaBookingsPageState();
}

class _PenyediaBookingsPageState extends State<PenyediaBookingsPage> {
  late DatabaseHelper _dbHelper;
  List<Booking> _bookings = [];
  Map<int, Listing?> _listingCache = {};
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final userId = AuthService().userId;
      final providerBookings = await _dbHelper.getBookingsByProvider(userId);

      if (mounted) {
        setState(() {
          _bookings = providerBookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Listing?> _getListing(int id) async {
    if (_listingCache.containsKey(id)) return _listingCache[id];
    final l = await _dbHelper.getListingById(id);
    _listingCache[id] = l;
    return l;
  }

  Future<void> _approveBooking(int id) async {
    final booking = _bookings.firstWhere((b) => b.id == id);
    await _dbHelper.updateBooking(booking.copyWith(status: 'approved'));
    _loadBookings();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan disetujui')));
    }
  }

  Future<void> _rejectBooking(int id, String reason) async {
    final booking = _bookings.firstWhere((b) => b.id == id);
    await _dbHelper.updateBooking(
      booking.copyWith(status: 'rejected', rejectionReason: reason),
    );
    _loadBookings();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan ditolak')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final filtered = _filterStatus == 'all'
        ? _bookings
        : _bookings.where((b) => b.status == _filterStatus).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _filterChip('Semua', 'all'),
              const SizedBox(width: 8),
              _filterChip('Menunggu', 'pending'),
              const SizedBox(width: 8),
              _filterChip('Disetujui', 'approved'),
              const SizedBox(width: 8),
              _filterChip('Ditolak', 'rejected'),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada pesanan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (c, i) {
                    final b = filtered[i];
                    return FutureBuilder<Listing?>(
                      future: _getListing(b.listingId),
                      builder: (c, s) => _bookingCard(b, s.data),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (s) => setState(() => _filterStatus = value),
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }

  Widget _bookingCard(Booking b, Listing? l) {
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
                  l?.title ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(b.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel(b.status),
                  style: TextStyle(
                    color: _statusColor(b.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${b.totalPrice.toStringAsFixed(0)} • ${b.bookingType}',
            style: const TextStyle(fontSize: 12),
          ),
          if (b.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveBooking(b.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Setujui',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRejectDialog(b.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (b.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Alasan: ${b.rejectionReason}',
                style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(int bookingId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Alasan'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _rejectBooking(bookingId, controller.text);
              Navigator.pop(c);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => s == 'pending'
      ? const Color(0xFFF59E0B)
      : s == 'approved'
      ? const Color(0xFF10B981)
      : const Color(0xFFEF4444);
  String _statusLabel(String s) => s == 'pending'
      ? 'Menunggu'
      : s == 'approved'
      ? 'Disetujui'
      : 'Ditolak';
}
