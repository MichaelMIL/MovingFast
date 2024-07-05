import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/items_provider.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isCameraPaused = false;
  bool isVerifyMode = false;
  bool isDeliverMode = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
    setState(() {
      isCameraPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    _buildScanResult(itemProvider)
                  else
                    const Text('Scan a code'),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.flash_on),
            label: 'Toggle Flash',
            onTap: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.flip_camera_android),
            label: 'Rotate Camera',
            onTap: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: Icon(isCameraPaused ? Icons.play_arrow : Icons.pause),
            label: isCameraPaused ? 'Resume Camera' : 'Pause Camera',
            onTap: () async {
              if (isCameraPaused) {
                await controller?.resumeCamera();
              } else {
                await controller?.pauseCamera();
              }
              setState(() {
                isCameraPaused = !isCameraPaused;
              });
            },
          ),
          if (!isVerifyMode)
            SpeedDialChild(
              child: Icon(Icons.verified),
              label: 'Toggle Verify Mode',
              onTap: () {
                setState(() {
                  isVerifyMode = !isVerifyMode;
                  isDeliverMode = false;
                });
              },
            ),
          if (!isDeliverMode)
            SpeedDialChild(
              child: Icon(Icons.delivery_dining),
              label: 'Toggle Deliver Mode',
              onTap: () {
                setState(() {
                  isDeliverMode = !isDeliverMode;
                  isVerifyMode = false;
                });
              },
            ),
          SpeedDialChild(
            child: Icon(Icons.info),
            label: 'Get Info',
            onTap: () {
              setState(() {
                isDeliverMode = false;
                isVerifyMode = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (mounted) {
        setState(() {
          result = scanData;
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _buildScanResult(ItemProvider itemProvider) {
    final scannedCode = result?.code;
    final item = itemProvider.getItemByUniqueId(scannedCode!);

    if (item == null) {
      return Text('Item not found: $scannedCode');
    }

    if (isVerifyMode && !item.isVerified) {
      Future.microtask(() {
        itemProvider.setItemVerification(scannedCode, true);
      });
    }

    if (isDeliverMode && !item.isDelivered) {
      Future.microtask(() {
        itemProvider.setItemDelivered(scannedCode, true);
      });
    }

    return Container(
      color: Colors.green.withOpacity(0.3),
      child: Column(
        children: [
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
    );
  }
}
