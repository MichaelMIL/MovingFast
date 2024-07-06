import 'package:flutter/material.dart';
import 'package:moving_fast/providers/settings_provider.dart';
import '../providers/items_provider.dart';
import '../providers/rooms_provider.dart';
import '../pages/qr_code_page.dart';
import '../dialogs/edit_item_dialog.dart';
import '../dialogs/delete_dialog.dart';

class RoomsListView extends StatefulWidget {
  final List<String> allRooms;
  final RoomsProvider roomsProvider;
  final ItemProvider itemProvider;
  final SettingsProvider settingsProvider;

  RoomsListView({
    required this.allRooms,
    required this.roomsProvider,
    required this.itemProvider,
    required this.settingsProvider,
  });

  @override
  _RoomsListViewState createState() => _RoomsListViewState();
}

class _RoomsListViewState extends State<RoomsListView> {
  Color _getTileColor(Item item) {
    if (item.isDeleted) {
      return Colors.red.withOpacity(0.8);
    }
    if (item.isArchived) {
      return Colors.grey.withOpacity(0.8);
    }
    if (item.isDelivered) {
      return Colors.green.withOpacity(0.8);
    }
    if (!item.isVerified) {
      return Colors.white.withOpacity(0.8);
    }
    return Colors.yellow.withOpacity(0.8);
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
      statusText = "New";
      bubbleColor = Colors.white;
    } else if (item.isVerified && !item.isDelivered) {
      statusText = "Pending";
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
        style: TextStyle(
            color: bubbleColor == Colors.yellow || bubbleColor == Colors.white
                ? Colors.black
                : Colors.white),
      ),
    );
  }

  Widget _buildStatusCountBubble(
      int count, Color color, String type, Color textColor) {
    return Tooltip(
      message: type,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[200], // Set the background color to light blue
      child: ListView.builder(
        itemCount: widget.allRooms.length,
        itemBuilder: (context, roomIndex) {
          final room = widget.allRooms[roomIndex];
          List<Item> roomItems;

          if (room == 'Unknown') {
            roomItems = widget.itemProvider.items
                .where(
                    (item) => !widget.roomsProvider.rooms.contains(item.room))
                .toList();
          } else {
            roomItems = widget.itemProvider.items
                .where((item) => item.room == room)
                .toList();
          }

          if (!widget.settingsProvider.showDeletedArchived) {
            roomItems = roomItems
                .where((item) => !item.isDeleted && !item.isArchived)
                .toList();
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

          return Card(
            color: Colors.green[300],
            child: ExpansionTile(
              key: PageStorageKey<String>(room),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(room),
                  Row(
                    children: [
                      if (notVerifiedNotDeliveredCount > 0)
                        _buildStatusCountBubble(notVerifiedNotDeliveredCount,
                            Colors.white, "New", Colors.black),
                      if (verifiedNotDeliveredCount > 0)
                        _buildStatusCountBubble(verifiedNotDeliveredCount,
                            Colors.yellow, "Pending", Colors.black),
                      if (deliveredCount > 0)
                        _buildStatusCountBubble(deliveredCount, Colors.green,
                            "Delivered", Colors.white),
                      if (archivedCount > 0)
                        _buildStatusCountBubble(archivedCount, Colors.grey,
                            "Archived", Colors.white),
                      if (deletedCount > 0)
                        _buildStatusCountBubble(deletedCount, Colors.red[900]!,
                            "Deleted", Colors.white),
                    ],
                  ),
                ],
              ),
              children: roomItems.map((item) {
                return ListTile(
                  key: ValueKey(item.uniqueId),
                  title: Text('ID: ${item.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.description!.isNotEmpty)
                        Text(
                          'Description: ${item.description}',
                        ),
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
                            widget.itemProvider
                                .removeItem(item.uniqueId.toString());
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
                              widget.itemProvider
                                  .setItemVerification(item.uniqueId, false);
                            }
                            if (item.isDelivered) {
                              widget.itemProvider
                                  .setItemDelivered(item.uniqueId, false);
                            }
                            if (item.isArchived) {
                              widget.itemProvider
                                  .setItemArchive(item.uniqueId, false);
                            }
                            if (item.isDeleted) {
                              widget.itemProvider
                                  .setItemDelete(item.uniqueId, false);
                            }
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
