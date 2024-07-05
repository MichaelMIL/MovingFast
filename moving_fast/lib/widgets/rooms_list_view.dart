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
    if (item.isDeleted) {
      return Colors.red.withOpacity(0.8);
    }
    if (item.isArchived) {
      return Colors.grey.withOpacity(0.3);
    }
    if (!item.isVerified) {
      return Colors.red.withOpacity(0.3);
    }
    if (item.isDelivered) {
      return Colors.green.withOpacity(0.3);
    }
    return Colors.yellow.withOpacity(0.3);
  }

  Widget _buildStatusBubble(Item item) {
    String statusText = "Unknown";
    Color bubbleColor = Colors.grey;

    if (item.isDeleted) {
      statusText = "Deleted";
      bubbleColor = Colors.red[900]!;
    } else if (item.isArchived) {
      statusText = "Archived";
      bubbleColor = Colors.grey;
    } else if (!item.isVerified && !item.isDelivered) {
      statusText = "Not Verified, Not Delivered";
      bubbleColor = Colors.red;
    } else if (item.isVerified && !item.isDelivered) {
      statusText = "Verified, Not Delivered";
      bubbleColor = Colors.yellow;
    } else if (item.isDelivered) {
      statusText = "Delivered";
      bubbleColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildStatusCountBubble(int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allRooms.length,
      itemBuilder: (context, roomIndex) {
        final room = allRooms[roomIndex];
        List<Item> roomItems;

        if (room == 'Unknown') {
          roomItems = itemProvider.items
              .where((item) => !roomsProvider.rooms.contains(item.room))
              .toList();
        } else {
          roomItems =
              itemProvider.items.where((item) => item.room == room).toList();
        }

        final int notVerifiedNotDeliveredCount = roomItems
            .where((item) =>
                !item.isVerified &&
                !item.isDelivered &&
                !item.isArchived &&
                !item.isDeleted)
            .length;
        final int verifiedNotDeliveredCount = roomItems
            .where((item) =>
                item.isVerified &&
                !item.isDelivered &&
                !item.isArchived &&
                !item.isDeleted)
            .length;
        final int deliveredCount = roomItems
            .where((item) =>
                item.isDelivered && !item.isArchived && !item.isDeleted)
            .length;
        final int archivedCount = roomItems
            .where((item) => item.isArchived && !item.isDeleted)
            .length;
        final int deletedCount =
            roomItems.where((item) => item.isDeleted).length;

        return ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(room),
              Row(
                children: [
                  if (notVerifiedNotDeliveredCount > 0)
                    _buildStatusCountBubble(
                        notVerifiedNotDeliveredCount, Colors.red),
                  if (verifiedNotDeliveredCount > 0)
                    _buildStatusCountBubble(
                        verifiedNotDeliveredCount, Colors.yellow),
                  if (deliveredCount > 0)
                    _buildStatusCountBubble(deliveredCount, Colors.green),
                  if (archivedCount > 0)
                    _buildStatusCountBubble(archivedCount, Colors.grey),
                  if (deletedCount > 0)
                    _buildStatusCountBubble(deletedCount, Colors.red[900]!),
                ],
              ),
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
                  _buildStatusBubble(item),
                  IconButton(
                    icon: Icon(Icons.qr_code),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => QrCodeScreen(item: item),
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
                  if (item.isVerified ||
                      item.isDelivered ||
                      item.isArchived ||
                      item.isDeleted)
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        if (item.isVerified) {
                          itemProvider.setItemVerification(
                              item.uniqueId, false);
                        }
                        if (item.isDelivered) {
                          itemProvider.setItemDelivered(item.uniqueId, false);
                        }
                        if (item.isArchived) {
                          itemProvider.setItemArchive(item.uniqueId, false);
                        }
                        if (item.isDeleted) {
                          itemProvider.setItemDelete(item.uniqueId, false);
                        }
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
