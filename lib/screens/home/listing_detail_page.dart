import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../database/database_helper.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/image_carousel.dart';

class ListingDetailPage extends StatefulWidget {
  final int listingId;
  final String? listingType;

  const ListingDetailPage({Key? key, required this.listingId, this.listingType})
    : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

// Diagnostic flag: set to true to render a simplified, non-interactive
// detail view (no carousel, no map). Use for isolating mouse/interaction errors.
const bool _kSimpleDetailMode =
    true; // ENABLED for diagnostics — set to false after testing

class _ListingDetailPageState extends State<ListingDetailPage> {
  late DatabaseHelper _dbHelper;
  late Future<Listing?> _listingFuture;
  final BookingService _bookingService = BookingService();

  Future<Map<String, int>> _loadTypeCounts() async {
    final hunian = await _dbHelper.getListingsByType('hunian');
    final kegiatan = await _dbHelper.getListingsByType('kegiatan');
    final marketplace = await _dbHelper.getListingsByType('marketplace');
    return {
      'hunian': hunian.length,
      'kegiatan': kegiatan.length,
      'marketplace': marketplace.length,
    };
  }

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    // Debug: log which listingId we are requesting
    print('ListingDetailPage: requesting listing id=${widget.listingId}');
    if (widget.listingType != null && widget.listingType!.isNotEmpty) {
      _listingFuture = _dbHelper.getListingByIdAndType(
        widget.listingId,
        widget.listingType!,
      );
    } else {
      _listingFuture = _dbHelper.getListingById(widget.listingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Listing?>(
      future: _listingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Listing')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // Show detailed error so we can debug why the page is blank
          final err = snapshot.error;
          print(
            'ListingDetailPage: error loading listing id=${widget.listingId} -> $err',
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Listing')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading listing:'),
                    const SizedBox(height: 8),
                    Text(err.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final listing = snapshot.data;
        if (listing == null) {
          print('ListingDetailPage: listing id=${widget.listingId} not found');
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Listing')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Listing tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Requested id: ${widget.listingId}'),
                    const SizedBox(height: 12),
                    Text('Connection state: ${snapshot.connectionState}'),
                    const SizedBox(height: 8),
                    Text(
                      'hasData: ${snapshot.hasData}  hasError: ${snapshot.hasError}',
                    ),
                    const SizedBox(height: 8),
                    if (snapshot.hasError) Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, int>>(
                      future: _loadTypeCounts(),
                      builder: (context, countsSnap) {
                        if (countsSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final counts = countsSnap.data ?? {};
                        return Column(
                          children: [
                            Text('Listings in DB:'),
                            Text('Hunian: ${counts['hunian'] ?? 0}'),
                            Text('Kegiatan: ${counts['kegiatan'] ?? 0}'),
                            Text('Marketplace: ${counts['marketplace'] ?? 0}'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                // Try reloading the listing once (in case of timing issues)
                                setState(() {
                                  _listingFuture = _dbHelper.getListingById(
                                    widget.listingId,
                                  );
                                });
                              },
                              child: const Text('Reload'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_kSimpleDetailMode) {
          // Simplified detail view showing: image, title, address, price, type, and description
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detail Listing'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: ListView(
              children: [
                // Image section
                Container(
                  height: 250,
                  color: Colors.grey[200],
                  child:
                      listing.image != null && listing.image!.isNotEmpty
                          ? Image.network(
                            listing.image!,
                            fit: BoxFit.cover,
                            loadingBuilder: (c, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (c, e, st) {
                              print(
                                'ListingDetailPage: Error loading image ${listing.image}: $e',
                              );
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gambar tidak dapat dimuat',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ada gambar',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                ),

                // Info section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              listing.location ?? 'Lokasi tidak tersedia',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price and Type in a row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${listing.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              listing.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category and Sub-category
                      Text(
                        'Kategori: ${listing.category} • ${listing.subCategory}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // Description title
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        listing.description,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // Additional info
                      if (listing.eventDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Event',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(listing.eventDate.toString().split(' ')[0]),
                            const SizedBox(height: 12),
                          ],
                        ),

                      if (listing.quota != null && listing.quota!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kuota',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(listing.quota!),
                            const SizedBox(height: 12),
                          ],
                        ),

                      // Rating and reviews
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${listing.reviewCount} review',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Listing'),
            backgroundColor: AppTheme.primaryColor,
          ),
          body: ListView(
            children: [
              // Header dengan image carousel
              FutureBuilder<List<String>>(
                future: _dbHelper.getListingImages(widget.listingId),
                builder: (context, imageSnapshot) {
                  List<String> images = [];

                  // Add primary image if exists
                  if (listing.image != null) {
                    images.add(listing.image!);
                  }

                  // Add additional images if exist
                  if (imageSnapshot.hasData && imageSnapshot.data!.isNotEmpty) {
                    images.addAll(imageSnapshot.data!);
                  }

                  return ImageCarousel(images: images, height: 300);
                },
              ),

              // Info listing
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul dan harga
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Provider / owner name (may be null) - load from DB and show fallback
                    FutureBuilder<User?>(
                      future: _dbHelper.getUserById(listing.providerId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }

                        final provider = userSnapshot.data;
                        final providerName =
                            provider?.name ?? 'Penyedia tidak tersedia';
                        return Text(
                          providerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${listing.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${listing.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tipe dan kategori
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${listing.type} • ${listing.subCategory}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.description,
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Lokasi
                    if (listing.latitude != null &&
                        listing.longitude != null) ...[
                      Text(
                        'Lokasi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (listing.location != null &&
                          listing.location!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  listing.location!,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Map
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                listing.latitude!,
                                listing.longitude!,
                              ),
                              initialZoom: 15,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.assessment2_ppbl',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      listing.latitude!,
                                      listing.longitude!,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Info tambahan
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${listing.views} views',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.rate_review,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${listing.reviewCount} reviews',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _handlePrimaryAction(listing);
                        },
                        child: Text(_primaryActionLabel(listing.type)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _primaryActionLabel(String type) {
    switch (type.toLowerCase()) {
      case 'hunian':
        return 'Booking Sekarang';
      case 'kegiatan':
        return 'Daftar';
      case 'marketplace':
        return 'Beli';
      default:
        return 'Booking';
    }
  }

  Future<void> _handlePrimaryAction(Listing listing) async {
    final auth = AuthService();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final studentId = auth.userId;
    final providerId = listing.providerId;
    final bookingType = _bookingTypeForListing(listing.type);

    // For simplicity, quantity = 1 and status depends on type
    final quantity = 1;
    final totalPrice = listing.price * quantity;
    final status = bookingType == 'pembelian' ? 'completed' : 'pending';

    final booking = Booking(
      id: 0,
      listingId: listing.id,
      studentId: studentId,
      providerId: providerId,
      bookingType: bookingType,
      status: status,
      quantity: quantity,
      totalPrice: totalPrice,
      bookingDate: DateTime.now(),
    );

    try {
      final id = await _bookingService.createBooking(booking);
      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_primaryActionLabel(listing.type)} berhasil'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_primaryActionLabel(listing.type)} gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _bookingTypeForListing(String type) {
    switch (type.toLowerCase()) {
      case 'hunian':
        return 'booking';
      case 'kegiatan':
        return 'registrasi';
      case 'marketplace':
        return 'pembelian';
      default:
        return 'booking';
    }
  }
}
