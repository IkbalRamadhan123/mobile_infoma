import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/listing.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';

class AdvancedSearchPage extends StatefulWidget {
  final String? initialType;

  const AdvancedSearchPage({Key? key, this.initialType}) : super(key: key);

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  late DatabaseHelper _dbHelper;
  List<Listing> _searchResults = [];
  bool _isSearching = false;

  // Filters
  String _selectedType = 'hunian';
  double _minPrice = 0;
  double _maxPrice = 100000000;
  String _selectedCategory = '';
  String _selectedCondition = 'semua';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _selectedType = widget.initialType ?? 'hunian';
  }

  Future<void> _performSearch() async {
    try {
      setState(() => _isSearching = true);

      List<Listing> results = [];

      if (_selectedType == 'hunian') {
        results = await _dbHelper.getListingsByType('hunian');
      } else if (_selectedType == 'kegiatan') {
        results = await _dbHelper.getListingsByType('kegiatan');
      } else {
        results = await _dbHelper.getListingsByType('marketplace');
      }

      // Filter by search text
      if (_searchController.text.isNotEmpty) {
        results = results
            .where(
              (l) => l.title.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
      }

      // Filter by price
      results = results
          .where((l) => l.price >= _minPrice && l.price <= _maxPrice)
          .toList();

      // Filter by category
      if (_selectedCategory.isNotEmpty) {
        results = results
            .where((l) => l.subCategory == _selectedCategory)
            .toList();
      }

      // Filter by condition (marketplace)
      if (_selectedType == 'marketplace' && _selectedCondition != 'semua') {
        results = results
            .where((l) => l.condition == _selectedCondition)
            .toList();
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Lanjutan'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari ${_selectedType}...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          setState(() => _searchController.clear()),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Type selector
          Wrap(
            spacing: 8,
            children: ['hunian', 'kegiatan', 'marketplace'].map((t) {
              return FilterChip(
                label: Text(t),
                selected: _selectedType == t,
                onSelected: (s) => setState(() {
                  _selectedType = t;
                  _selectedCategory = '';
                }),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: _selectedType == t ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Price filter
          if (_selectedType != 'kegiatan') ...[
            Text(
              'Harga: Rp ${_minPrice.toStringAsFixed(0)} - Rp ${_maxPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 500000000,
              divisions: 50,
              labels: RangeLabels(
                'Rp ${(_minPrice / 1000000).toStringAsFixed(1)}M',
                'Rp ${(_maxPrice / 1000000).toStringAsFixed(1)}M',
              ),
              onChanged: (v) => setState(() {
                _minPrice = v.start;
                _maxPrice = v.end;
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Category filter
          if (_selectedType == 'hunian') ...[
            const Text(
              'Tipe Hunian',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Kos', 'Apartment', 'Kontrakan', 'Rumah', 'Ruko'].map((
                cat,
              ) {
                return FilterChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (s) =>
                      setState(() => _selectedCategory = s ? cat : ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ] else if (_selectedType == 'kegiatan') ...[
            const Text(
              'Tipe Kegiatan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Seminar', 'Webinar', 'Workshop', 'Bootcamp', 'Lomba']
                  .map((cat) {
                    return FilterChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (s) =>
                          setState(() => _selectedCategory = s ? cat : ''),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 16),
          ] else if (_selectedType == 'marketplace') ...[
            const Text(
              'Kondisi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Semua', 'Baru', 'Bekas'].map((cond) {
                return FilterChip(
                  label: Text(cond),
                  selected: _selectedCondition == cond.toLowerCase(),
                  onSelected: (s) => setState(
                    () => _selectedCondition = s ? cond.toLowerCase() : 'semua',
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Search button
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isSearching ? 'Mencari...' : 'Cari'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),

          // Results
          if (_searchResults.isEmpty && !_isSearching)
            Center(
              child: Column(
                children: const [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada hasil'),
                ],
              ),
            )
          else
            ..._searchResults
                .map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListingCard(
                      title: listing.title,
                      price: listing.price,
                      rating: listing.rating,
                      reviewCount: listing.reviewCount,
                      category: listing.subCategory,
                      image: listing.image,
                      location: listing.location,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/listing-detail',
                          arguments: listing.id,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
