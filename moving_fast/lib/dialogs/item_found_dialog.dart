import 'package:flutter/material.dart';
import '../providers/items_provider.dart';

class ItemFoundDialog extends StatelessWidget {
  final Item item;
  ItemFoundDialog({required this.item});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Item Found'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text('Room: ${item.room}'),
          Text('Description: ${item.description}'),
          Text('Item ID: ${item.id}'),
          Text("Is Verified: ${item.isVerified}"),
          Text("Is Archived: ${item.isArchived}"),
          Text("Is Deleted: ${item.isDeleted}"),
          Text("Is Delivered: ${item.isDelivered}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
