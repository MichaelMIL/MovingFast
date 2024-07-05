import 'package:flutter/material.dart';
import '../providers/rooms_provider.dart';
import 'package:provider/provider.dart';
import 'delete_dialog.dart';

class DeleteRoomDialog extends StatefulWidget {
  @override
  _DeleteRoomDialogState createState() => _DeleteRoomDialogState();
}

class _DeleteRoomDialogState extends State<DeleteRoomDialog> {
  String? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<RoomsProvider>(
            builder: (context, provider, child) {
              return DropdownButtonFormField<String>(
                value: _selectedRoom,
                items: provider.rooms.map((String room) {
                  return DropdownMenuItem<String>(
                    value: room,
                    child: Text(room),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedRoom = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Room',
                ),
              );
            },
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
            showDialog(
              context: context,
              builder: (context) => DeleteDialog(),
            ).then((value) {
              if (value == true) {
                final room = _selectedRoom;
                Navigator.pop(context, room);
              }
            });
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
