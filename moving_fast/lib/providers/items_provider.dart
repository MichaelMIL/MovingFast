import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Item {
  String uniqueId;
  int id;
  String? room;
  String? description;

  Item({required this.uniqueId, required this.id, this.room, this.description});

  Map<String, dynamic> toJson() => {
        'uniqueId': uniqueId,
        'id': id,
        'room': room,
        'description': description,
      };

  static Item fromJson(Map<String, dynamic> json) => Item(
        uniqueId: json['uniqueId'],
        id: json['id'],
        room: json['room'],
        description: json['description'],
      );
}

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  int _nextId = 1;
  final _uuid = Uuid();

  ItemProvider() {
    _loadItems();
  }

  List<Item> get items => _items;

  void addItem({String? room, String? description}) {
    final newItem = Item(
      uniqueId: _uuid.v4(),
      id: _nextId++,
      room: room,
      description: description,
    );
    _items.add(newItem);
    _saveItems();
    notifyListeners();
  }

  void removeItem(String uniqueId) {
    _items.removeWhere((item) => item.uniqueId == uniqueId);
    _saveItems();
    notifyListeners();
  }

  void _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonItems = prefs.getStringList('items');
    if (jsonItems != null) {
      _items = jsonItems
          .map((jsonItem) => Item.fromJson(json.decode(jsonItem)))
          .toList();
      if (_items.isNotEmpty) {
        _nextId =
            _items.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    }
    notifyListeners();
  }

  void _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonItems =
        _items.map((item) => json.encode(item.toJson())).toList();
    prefs.setStringList('items', jsonItems);
  }

  void clearItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('items');
    _items = [];
    _nextId = 1;
    notifyListeners();
  }

  void updateItem(String uniqueId, String? room, String? description) {
    final item = _items.firstWhere((item) => item.uniqueId == uniqueId);
    item.room = room;
    item.description = description;
    _saveItems();
    notifyListeners();
  }
}
