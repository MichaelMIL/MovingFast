import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';
import '../providers/items_provider.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;

  EditItemDialog({required this.item});

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  String? _selectedRoom;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // _selectedRoom = widget.item.room ?? 'Unknown';
    _descriptionController =
        TextEditingController(text: widget.item.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Item'),
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
            final updatedRoom = _selectedRoom;
            final updatedDescription = _descriptionController.text;

            // Update item details
            widget.item.room = updatedRoom;
            widget.item.description = updatedDescription;

            // Notify listeners or update provider depending on your setup
            // Assuming ItemProvider uses notifyListeners for changes
            Provider.of<ItemProvider>(context, listen: false).updateItem(
                widget.item.uniqueId, updatedRoom, updatedDescription);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
