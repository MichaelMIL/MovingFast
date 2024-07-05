import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsProvider with ChangeNotifier {
  List<String> _rooms = [];

  RoomsProvider() {
    _loadRooms();
  }

  List<String> get rooms => _rooms;

  Future<void> addRoom(String room) async {
    if (!_rooms.contains(room)) {
      _rooms.add(room);
      await _saveRooms();
      notifyListeners();
    }
  }

  Future<void> removeRoom(String room) async {
    _rooms.remove(room);
    await _saveRooms();
    notifyListeners();
  }

  Future<void> _loadRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rooms = prefs.getStringList('rooms') ?? [];
    notifyListeners();
  }

  Future<void> _saveRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rooms', _rooms);
  }
}
