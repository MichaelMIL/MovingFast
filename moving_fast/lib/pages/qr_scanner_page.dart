import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/items_provider.dart';
import 'qr_code_page.dart';

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
  // Track if a snackbar is currently displayed
  bool isSnackbarVisible = false;
  String? lastScannedCode;

  Color _setQrFrameColor() {
    Color qrFrameColor = Colors.red;
    if (isVerifyMode) {
      qrFrameColor = Colors.yellow;
    }
    if (isDeliverMode) {
      qrFrameColor = Colors.green;
    }
    return qrFrameColor;
  }

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
                    _buildScanResult(itemProvider, context)
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
          borderColor: _setQrFrameColor(),
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
        _handleScanResult(scanData, context);
      }
    });
  }

  void _handleScanResult(Barcode scanData, BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final scannedCode = scanData.code;
    if (scannedCode == null) {
      return;
    }
    final item = itemProvider.getItemByUniqueId(scannedCode);

    if (lastScannedCode == scannedCode && isSnackbarVisible) {
      return;
    } else {
      // if snackbar is visible, close it
      if (isSnackbarVisible) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        isSnackbarVisible = false;
      }
    }
    lastScannedCode = scannedCode;

    if (item == null) {
      if (!isSnackbarVisible) {
        isSnackbarVisible = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text('Item not found: $scannedCode'),
                backgroundColor: Colors.red,
              ),
            )
            .closed
            .then((reason) {
          isSnackbarVisible = false;
        });
      }
    } else {
      if (isVerifyMode) {
        if (!isSnackbarVisible) {
          isSnackbarVisible = true;
          Future.microtask(() {
            itemProvider.setItemVerification(scannedCode, true);
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Expanded(
                        child: Text('Item verified for code: $scannedCode'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(item: item),
                            ),
                          );
                        },
                        child: Text('View QR'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.yellow,
                ),
              )
              .closed
              .then((reason) {
            isSnackbarVisible = false;
          });
        }
      }
      if (isDeliverMode) {
        if (!isSnackbarVisible) {
          isSnackbarVisible = true;
          Future.microtask(() {
            itemProvider.setItemDelivered(scannedCode, true);
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Expanded(
                        child: Text('Item delivered for code: $scannedCode'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(item: item),
                            ),
                          );
                        },
                        child: Text('View QR'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              )
              .closed
              .then((reason) {
            isSnackbarVisible = false;
          });
        }
      }
      if (!isVerifyMode && !isDeliverMode) {
        if (!isSnackbarVisible) {
          isSnackbarVisible = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Expanded(
                        child: Text('Item found for code: $scannedCode'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(item: item),
                            ),
                          );
                        },
                        child: Text('View QR'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                ),
              )
              .closed
              .then((reason) {
            isSnackbarVisible = false;
          });
        }
      }
    }
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

  Widget _buildScanResult(ItemProvider itemProvider, BuildContext context) {
    final scannedCode = result?.code;
    final item = itemProvider.getItemByUniqueId(scannedCode!);

    if (item == null) {
      return Text('Item not found: $scannedCode');
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
