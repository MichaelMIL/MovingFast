import 'package:flutter/material.dart';
import '../providers/items_provider.dart';
import '../providers/rooms_provider.dart';
import '../pages/qr_code_page.dart';
import '../dialogs/edit_item_dialog.dart';
import '../dialogs/delete_dialog.dart';

class RoomsListView extends StatelessWidget {
  final List<String> allRooms;
  final RoomsProvider roomsProvider;
  final ItemProvider itemProvider;

  RoomsListView({
    required this.allRooms,
    required this.roomsProvider,
    required this.itemProvider,
  });

  Color _getTileColor(Item item) {
    Color tileColor = Colors.orange;
    if (!item.isVerified) {
      tileColor = Colors.red.withOpacity(0.3);
    } else {
      tileColor = Colors.yellow.withOpacity(0.3);
    }
    if (item.isArchived) {
      tileColor = Colors.grey.withOpacity(0.3);
    }
    if (item.isDeleted) {
      tileColor = Colors.red.withOpacity(0.8);
    }
    if (item.isDelivered) {
      tileColor = Colors.green.withOpacity(0.3);
    }
    return tileColor;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allRooms.length,
      itemBuilder: (context, roomIndex) {
        final room = allRooms[roomIndex];
        List<Item> roomItems;

        if (room == 'Unknown') {
          // Filter items that do not have a room matching any room in roomsProvider
          roomItems = itemProvider.items
              .where((item) => !roomsProvider.rooms.contains(item.room))
              .toList();
        } else {
          // Filter items by the current room
          roomItems =
              itemProvider.items.where((item) => item.room == room).toList();
        }

        return ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(room),
              Text('${roomItems.length} items'),
            ],
          ),
          children: roomItems.map((item) {
            return ListTile(
              title: Text(item.id.toString()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description!.isNotEmpty)
                    Text('Description: ${item.description}'),
                  if (item.room != null &&
                      item.room!.isNotEmpty &&
                      room != item.room)
                    Text('Room: ${item.room}'),
                ],
              ),
              tileColor: _getTileColor(item),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.qr_code),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => QrCodeScreen(id: item.uniqueId),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => DeleteDialog(),
                      );
                      if (result == true) {
                        itemProvider.removeItem(item.uniqueId.toString());
                      }
                    },
                  ),
                  if (room == 'Unknown')
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditItemDialog(item: item),
                        );
                      },
                    ),
                  if (item.isVerified)
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        itemProvider.setItemVerification(item.uniqueId, false);
                      },
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
