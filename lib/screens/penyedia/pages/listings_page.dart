import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/listing.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/location_picker_dialog.dart';
import '../../../widgets/image_gallery_dialog.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({Key? key}) : super(key: key);

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  late DatabaseHelper _dbHelper;
  List<Listing> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      final userId = AuthService().userId;
      final listings = await _dbHelper.getListingsByProvider(userId);

      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading listings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteListing(int listingId) async {
    try {
      await _dbHelper.deleteListing(listingId);
      setState(() {
        _listings.removeWhere((l) => l.id == listingId);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Listing dihapus')));
      }
    } catch (e) {
      print('Error deleting listing: $e');
    }
  }

  void _showCreateListingDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateListingDialog(
        dbHelper: _dbHelper,
        onCreated: () {
          _loadListings();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Listing Anda',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_listings.length} listing aktif',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateListingDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Listings
        Expanded(
          child: _listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada listing',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadListings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      final listing = _listings[index];
                      return _buildListingCard(listing);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        title: Text(
          listing.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Rp ${listing.price.toStringAsFixed(0)} • ${listing.type}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Hapus'),
              onTap: () => _showDeleteConfirmation(listing.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int listingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Listing?'),
        content: const Text('Apakah Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteListing(listingId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _CreateListingDialog extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final VoidCallback onCreated;

  const _CreateListingDialog({required this.dbHelper, required this.onCreated});

  @override
  State<_CreateListingDialog> createState() => _CreateListingDialogState();
}

class _CreateListingDialogState extends State<_CreateListingDialog> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String _type = 'hunian';
  String _subcat = 'Kos';
  double? _latitude;
  double? _longitude;
  String _locationName = '';
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createListing() async {
    try {
      final listing = Listing(
        id: 0,
        providerId: AuthService().userId,
        title: _titleController.text,
        description: _descController.text,
        type: _type,
        category: _type,
        subCategory: _subcat,
        price: double.parse(_priceController.text),
        createdAt: DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
        location: _locationName,
        // Use first image as the main image if available
        image: _images.isNotEmpty ? _images.first : null,
      );

      final listingId = await widget.dbHelper.insertListing(listing);

      // Save additional images (starting from second image) if there are any
      if (_images.length > 1) {
        await widget.dbHelper.saveListingImages(listingId, _images.sublist(1));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing berhasil dibuat')),
        );
        widget.onCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Listing'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: ['hunian', 'kegiatan', 'marketplace'].map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (_type == 'hunian' || _type == 'kegiatan')
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto Listing',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_images.length} foto',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (c) => ImageGalleryDialog(
                              initialImages: _images,
                              onImagesChanged: (images) {
                                setState(() {
                                  _images = images;
                                });
                              },
                            ),
                          ),
                          icon: const Icon(Icons.image, size: 16),
                          label: const Text(
                            'Kelola',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _locationName.isEmpty
                                  ? 'Belum dipilih'
                                  : _locationName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (c) => LocationPickerDialog(
                              onLocationSelected: (lat, lon, loc) {
                                setState(() {
                                  _latitude = lat;
                                  _longitude = lon;
                                  _locationName = loc;
                                });
                                Navigator.pop(c);
                              },
                            ),
                          ),
                          icon: const Icon(Icons.location_on, size: 16),
                          label: const Text(
                            'Pilih',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _createListing,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Buat'),
        ),
      ],
    );
  }
}
