import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Item {
  String uniqueId;
  int id;
  String? room;
  String? description;
  bool isVerified = false;
  bool isArchived = false;
  bool isDeleted = false;
  bool isDelivered = false;

  Item(
      {required this.uniqueId,
      required this.id,
      this.room,
      this.description,
      this.isVerified = false,
      this.isArchived = false,
      this.isDeleted = false,
      this.isDelivered = false});

  Map<String, dynamic> toJson() => {
        'uniqueId': uniqueId,
        'id': id,
        'room': room,
        'description': description,
        'isVerified': isVerified,
        'isArchived': isArchived,
        'isDeleted': isDeleted,
        'isDelivered': isDelivered,
      };

  static Item fromJson(Map<String, dynamic> json) => Item(
        uniqueId: json['uniqueId'],
        id: json['id'],
        room: json['room'],
        description: json['description'],
        isVerified: json['isVerified'],
        isArchived: json['isArchived'],
        isDeleted: json['isDeleted'],
        isDelivered: json['isDelivered'],
      );
}

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  int _nextId = 1;
  final _uuid = Uuid();

  ItemProvider() {
    _createDemoItems();
    _loadItems();
  }

  List<Item> get items => _items;

  void _createDemoItems() {
    _items.add(Item(
        uniqueId: "ABC123", id: 1, room: "Living Room", description: "TV"));
    _items.add(Item(
        uniqueId: "DEF456", id: 2, room: "Kitchen", description: "Microwave"));
    _items.add(
        Item(uniqueId: "GHI789", id: 3, room: "Bedroom", description: "Bed"));
    _items.add(Item(
        uniqueId: "JKL012", id: 4, room: "Bathroom", description: "Toilet"));
    _items.add(
        Item(uniqueId: "MNO345", id: 5, room: "Garage", description: "Car"));
    _saveItems();
    notifyListeners();
  }

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

  Item? getItemByUniqueId(String uniqueId) {
    try {
      return _items.firstWhere((item) => item.uniqueId == uniqueId);
    } catch (e) {
      return null;
    }
  }

  Item? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateItem(String uniqueId, String? room, String? description) {
    final item = getItemByUniqueId(uniqueId);
    if (item != null) {
      item.room = room;
      item.description = description;
      _saveItems();
      notifyListeners();
    }
  }

  void setItemVerification(String uniqueId, bool isVerified) {
    final item = getItemByUniqueId(uniqueId);
    if (item != null) {
      item.isVerified = !item.isVerified;
      _saveItems();
      notifyListeners();
    }
  }

  void setItemArchive(String uniqueId, bool isArchived) {
    final item = getItemByUniqueId(uniqueId);
    if (item != null) {
      item.isArchived = !item.isArchived;
      _saveItems();
      notifyListeners();
    }
  }

  void setItemDelete(String uniqueId, bool isDeleted) {
    final item = getItemByUniqueId(uniqueId);
    if (item != null) {
      item.isDeleted = !item.isDeleted;
      _saveItems();
      notifyListeners();
    }
  }

  void setItemDelivered(String uniqueId, bool isDelivered) {
    final item = getItemByUniqueId(uniqueId);
    if (item != null) {
      item.isDelivered = !item.isDelivered;
      _saveItems();
      notifyListeners();
    }
  }
}
