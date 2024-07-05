import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/items_provider.dart';

class QrCodeScreen extends StatelessWidget {
  final Item item;

  QrCodeScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code for ${item.uniqueId}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: item.uniqueId,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20.0),
            Text('Item ID: ${item.id}'),
            if (item.description != null && item.description!.isNotEmpty)
              Text('Description: ${item.description}'),
            if (item.room != null && item.room!.isNotEmpty)
              Text('Room: ${item.room}'),
            Text('Verified: ${item.isVerified ? 'Yes' : 'No'}'),
            Text('Archived: ${item.isArchived ? 'Yes' : 'No'}'),
            Text('Deleted: ${item.isDeleted ? 'Yes' : 'No'}'),
            Text('Delivered: ${item.isDelivered ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }
}
