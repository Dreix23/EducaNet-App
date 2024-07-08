import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';

import '../../../controllers/attendance_controller.dart';
import '../../../utils/logger.dart';
import '../../../utils/preferences_manager.dart';
import '../../widgets/entrance_exit_control_bar.dart';
import '../../widgets/custom_snackbar.dart';

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final AttendanceController _attendanceController = AttendanceController();
  QRViewController? controller;
  bool isEntrance = true;
  String scannedData = "";
  bool isDataProcessedSuccessfully = false;
  Map<String, Map<String, Map<String, bool>>> processedCodes = {};
  Timer? _resetTimer;
  DateTime? _lastSnackbarTime;

  @override
  void initState() {
    super.initState();
    _loadProcessedCodes();
  }

  Future<void> _loadProcessedCodes() async {
    processedCodes = await PreferencesManager.loadProcessedCodes();
    AppLogger.log("Códigos procesados cargados: ${processedCodes.toString()}");
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scannedData.isEmpty ? "Escanea un QR" : scannedData,
              style: TextStyle(color: Colors.white),
            ),
            if (scannedData.isNotEmpty) ...[
              SizedBox(width: 10),
              Icon(
                Icons.check_circle,
                color: getIconColor(),
              ),
            ]
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
            cameraFacing: CameraFacing.back,
          ),
          _buildControlBar(),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: EntranceExitControlBar(
        isEntrance: isEntrance,
        onSelectionChanged: (bool isSelected) {
          setState(() {
            isEntrance = isSelected;
            isDataProcessedSuccessfully = _isQRCodeProcessed(scannedData, _getTodayString());
          });
        },
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      String currentScannedData = scanData.code ?? "Datos no encontrados";
      String todayString = _getTodayString();

      if (currentScannedData != "Datos no encontrados" && currentScannedData != scannedData) {
        if (_isQRCodeProcessed(currentScannedData, todayString)) {
          _showCustomSnackbar("Código ya escaneado", SnackbarState.pending);
          return;
        }

        setState(() {
          scannedData = currentScannedData;
          isDataProcessedSuccessfully = false;
        });

        try {
          bool result = await _attendanceController.handleScannedQR(scannedData, isEntrance);
          if (result) {
            setState(() {
              isDataProcessedSuccessfully = true;
              _updateProcessedCodes(currentScannedData, todayString);
            });
            await PreferencesManager.saveProcessedCodes(processedCodes);
            AppLogger.log("Código QR procesado y guardado: $currentScannedData");
            _showCustomSnackbar("Código procesado correctamente", SnackbarState.completed);
            _resetScanner();
          } else {
            setState(() {
              isDataProcessedSuccessfully = false;
            });
            AppLogger.log("Error al procesar el código QR: $currentScannedData");
            _showCustomSnackbar("Error al procesar el código QR", SnackbarState.error);
          }
        } catch (e) {
          AppLogger.log("Error al escanear o procesar el código QR: $e");
          _showCustomSnackbar("Error al procesar el código QR", SnackbarState.error);
        }
      }
    });
  }

  void _showCustomSnackbar(String message, SnackbarState state) {
    DateTime now = DateTime.now();
    if (_lastSnackbarTime == null || now.difference(_lastSnackbarTime!).inSeconds >= 3) {
      _lastSnackbarTime = now;
      CustomSnackbar.show(context, message, state, isTop: false);
    }
  }

  void _resetScanner() {
    if (_resetTimer != null) {
      _resetTimer!.cancel();
    }
    _resetTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        scannedData = "";
        isDataProcessedSuccessfully = false;
      });
    });
  }

  bool _isQRCodeProcessed(String qrCode, String date) {
    return processedCodes.containsKey(qrCode) &&
        processedCodes[qrCode]!.containsKey(date) &&
        processedCodes[qrCode]![date]!.containsKey(isEntrance.toString());
  }

  void _updateProcessedCodes(String qrCode, String date) {
    processedCodes[qrCode] ??= {};
    processedCodes[qrCode]![date] ??= {};
    processedCodes[qrCode]![date]![isEntrance.toString()] = true;
  }

  String _getTodayString() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Color getIconColor() {
    if (scannedData.isEmpty || !isDataProcessedSuccessfully) return Colors.grey;
    String todayString = _getTodayString();
    bool wasProcessedAsEntrance = processedCodes[scannedData] != null &&
        processedCodes[scannedData]![todayString] != null &&
        processedCodes[scannedData]![todayString]!['true'] == true;
    return isEntrance ? (wasProcessedAsEntrance ? Colors.green : Colors.grey) :
    (wasProcessedAsEntrance ? Colors.red : Colors.grey);
  }
}
