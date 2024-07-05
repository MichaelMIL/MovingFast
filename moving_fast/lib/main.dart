import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/items_provider.dart';
import 'providers/rooms_provider.dart';
import 'widgets/main_screen_speed_dial.dart';
import 'widgets/rooms_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => RoomsProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter QR Code App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roomsProvider = Provider.of<RoomsProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    List<String> allRooms =
        roomsProvider.rooms.toList(); // Make a copy of rooms
    allRooms.add('Unknown'); // Add 'Unknown' room

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Manager'),
      ),
      body: RoomsListView(
        allRooms: allRooms,
        roomsProvider: roomsProvider,
        itemProvider: itemProvider,
      ),
      floatingActionButton: MainScreenSpeedDial(),
    );
  }
}
