import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../utils/logger.dart';

class QRScanHijo extends StatefulWidget {
  final Function(String) onCodeScanned;

  QRScanHijo({required this.onCodeScanned});

  @override
  State<StatefulWidget> createState() => _QRScanHijoState();
}

class _QRScanHijoState extends State<QRScanHijo> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        AppLogger.log('Código QR escaneado: ${scanData.code}');
        widget.onCodeScanned(scanData.code!); // Llama al callback con el código escaneado

        controller.pauseCamera(); // Pausa la cámara después de escanear un código
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'QR Escanear', // Título más corto
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
