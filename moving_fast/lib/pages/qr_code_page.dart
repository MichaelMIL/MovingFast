import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatelessWidget {
  final String id;

  QrCodeScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code for $id'),
      ),
      body: Center(
        child: QrImageView(
          data: id,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
