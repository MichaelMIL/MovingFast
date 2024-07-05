import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _descriptionController = TextEditingController();
  String? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
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
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
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
            final description = _descriptionController.text;
            Navigator.pop(
                context, {'room': _selectedRoom, 'description': description});
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
