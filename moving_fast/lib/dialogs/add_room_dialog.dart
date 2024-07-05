import 'package:flutter/material.dart';

class AddRoomDialog extends StatefulWidget {
  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _roomController,
            decoration: InputDecoration(labelText: 'Room'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final room = _roomController.text;
            Navigator.pop(context, room);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
