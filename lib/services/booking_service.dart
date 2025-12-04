import '../database/database_helper.dart';
import '../models/booking.dart';

class BookingService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> createBooking(Booking booking) async {
    return await _db.insertBooking(booking);
  }

  Future<Booking?> getById(int id) async {
    return await _db.getBookingById(id);
  }

  Future<List<Booking>> getByStudent(int studentId) async {
    return await _db.getBookingsByStudent(studentId);
  }

  Future<List<Booking>> getByProvider(int providerId) async {
    return await _db.getBookingsByProvider(providerId);
  }

  Future<int> updateBooking(Booking booking) async {
    return await _db.updateBooking(booking);
  }

  Future<int> deleteBooking(int id) async {
    return await _db.deleteBooking(id);
  }
}
