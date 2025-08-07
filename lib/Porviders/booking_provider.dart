import 'package:flutter/material.dart';

class BookingProvider with ChangeNotifier {
  Map<String, dynamic> selectedBooking = {};

  void setBooking(Map<String, dynamic> booking) {
    selectedBooking = booking;
    notifyListeners();
  }

  void clearBooking() {
    selectedBooking = {};
    notifyListeners();
  }
}
