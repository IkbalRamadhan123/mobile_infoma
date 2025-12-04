import '../database/database_helper.dart';
import '../models/listing.dart';

class ListingService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> createListing(Listing listing) async {
    return await _db.insertListing(listing);
  }

  Future<Listing?> getById(int id) async {
    return await _db.getListingById(id);
  }

  Future<List<Listing>> getByType(String type) async {
    return await _db.getListingsByType(type);
  }

  Future<List<Listing>> getByProvider(int providerId) async {
    return await _db.getListingsByProvider(providerId);
  }

  Future<List<Listing>> search(String term) async {
    return await _db.searchListings(term);
  }

  Future<int> updateListing(Listing listing) async {
    return await _db.updateListing(listing);
  }

  Future<int> deleteListing(int id) async {
    return await _db.deleteListing(id);
  }

  Future<void> incrementViews(int listingId) async {
    await _db.incrementListingViews(listingId);
  }
}
