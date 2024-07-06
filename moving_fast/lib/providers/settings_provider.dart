import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  bool _darkMode = false;
  bool _showDeletedArchived = false;
  bool get darkMode => _darkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _darkMode = _prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  bool get showDeletedArchived => _showDeletedArchived;

  Future<void> setShowDeletedArchived(bool value) async {
    _showDeletedArchived = value;
    notifyListeners();
  }

  // Add more settings as needed

  static SettingsProvider of(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: false);
  }
}
