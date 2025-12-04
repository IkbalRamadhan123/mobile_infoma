import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../database/database_helper.dart';
import '../../../models/listing.dart';
import '../../../widgets/listing_card.dart';
import '../../home/listing_detail_page.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _dbHelper = DatabaseHelper();
  final _searchController = TextEditingController();
  late Future<List<Listing>> _listingsFuture;
  String _selectedType = 'hunian';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listingsFuture = _dbHelper.getListingsByType('hunian');

    _tabController.addListener(() {
      final types = ['hunian', 'kegiatan', 'marketplace'];
      setState(() {
        _selectedType = types[_tabController.index];
        _listingsFuture = _dbHelper.getListingsByType(_selectedType);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari listing...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Hunian'),
            Tab(text: 'Kegiatan'),
            Tab(text: 'Marketplace'),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<Listing>>(
            future: _listingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<Listing> listings = snapshot.data ?? [];

              if (_searchController.text.isNotEmpty) {
                listings =
                    listings
                        .where(
                          (listing) => listing.title.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();
              }

              if (listings.isEmpty) {
                return const Center(child: Text('Tidak ada listing'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return ListingCard(
                    title: listing.title,
                    image: listing.image,
                    price: listing.price,
                    rating: listing.rating,
                    reviewCount: listing.reviewCount,
                    category: listing.subCategory,
                    location: listing.location,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => ListingDetailPage(
                                listingId: listing.id,
                                listingType: listing.type,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
