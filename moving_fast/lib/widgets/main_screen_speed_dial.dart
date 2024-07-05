import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../dialogs/add_item_dialog.dart';
import '../pages/qr_scanner_page.dart';
import '../providers/items_provider.dart';
import '../dialogs/add_room_dialog.dart';
import '../providers/rooms_provider.dart';
import '../dialogs/delete_room_dialog.dart';

class MainScreenSpeedDial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.menu,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.red,
      activeForegroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          label: 'Add Item',
          onTap: () async {
            final result = await showDialog<Map<String, String?>>(
              context: context,
              builder: (context) => AddItemDialog(),
            );
            if (result != null) {
              Provider.of<ItemProvider>(context, listen: false).addItem(
                room: result['room'],
                description: result['description'],
              );
            }
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.qr_code_scanner),
          label: 'Scan QR Code',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrScanner(),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.room),
          label: 'Add Room',
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => AddRoomDialog(),
            );
            if (result != null) {
              Provider.of<RoomsProvider>(context, listen: false)
                  .addRoom(result);
            }
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.delete),
          label: 'Delete Room',
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => DeleteRoomDialog(),
            );
            if (result != null) {
              Provider.of<RoomsProvider>(context, listen: false)
                  .removeRoom(result);
            }
          },
        ),
      ],
    );
  }
}
