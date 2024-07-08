import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

import '../../../controllers/attendance_controller.dart';
import '../../../utils/logger.dart';
import '../../../utils/preferences_manager.dart';
import '../../widgets/entrance_exit_control_bar.dart';

class ExternalScannerScreen extends StatefulWidget {
  ExternalScannerScreen({Key? key}) : super(key: key);

  @override
  _ExternalScannerScreenState createState() => _ExternalScannerScreenState();
}

class _ExternalScannerScreenState extends State<ExternalScannerScreen> {
  String? _barcode;
  late bool visible = false;
  bool isEntrance = true;
  bool? isDataProcessedSuccessfully;
  Map<String, Map<String, Map<String, bool>>> processedCodes = {};
  final AttendanceController _attendanceController = AttendanceController();

  @override
  void initState() {
    super.initState();
    _loadProcessedCodes();
  }

  Future<void> _loadProcessedCodes() async {
    processedCodes = await PreferencesManager.loadProcessedCodes();
    AppLogger.log("Códigos procesados cargados: ${processedCodes.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner Externo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {
                  visible = info.visibleFraction > 0;
                },
                key: Key('visible-detector-key'),
                child: BarcodeKeyboardListener(
                  bufferDuration: Duration(milliseconds: 200),
                  onBarcodeScanned: (barcode) async {
                    if (!visible) return;
                    String currentScannedData = barcode.toUpperCase();
                    String todayString = _getTodayString();

                    setState(() {
                      _barcode = currentScannedData;
                      isDataProcessedSuccessfully = null; // Estado inicial antes de verificar
                    });

                    if (!_isQRCodeProcessed(currentScannedData, todayString)) {
                      bool result = await _attendanceController.handleScannedQR(currentScannedData, isEntrance);
                      if (result) {
                        setState(() {
                          isDataProcessedSuccessfully = true;
                          processedCodes[currentScannedData] ??= {};
                          processedCodes[currentScannedData]![todayString] ??= {};
                          processedCodes[currentScannedData]![todayString]![isEntrance.toString()] = true;
                        });
                        await PreferencesManager.saveProcessedCodes(processedCodes);
                        AppLogger.log("Código QR procesado y guardado: $currentScannedData");
                      } else {
                        setState(() {
                          isDataProcessedSuccessfully = false;
                        });
                        AppLogger.log("Error al procesar el código QR: $currentScannedData");
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _getIconData(),
                        color: _getIconColor(),
                        size: 48.0, // Tamaño más grande para el icono
                      ),
                      SizedBox(height: 10), // Espacio entre el icono y el texto
                      Text(
                        _barcode ?? 'SCAN CODE',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  useKeyDownEvent: !kIsWeb, // Ajuste para compatibilidad con web
                ),
              ),
            ),
          ),
          EntranceExitControlBar(
            isEntrance: isEntrance,
            onSelectionChanged: (bool isSelected) {
              setState(() {
                isEntrance = isSelected;
                // Restablecer los estados cuando se cambia entre entrada/salida
                _barcode = null;
                isDataProcessedSuccessfully = null;
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconData() {
    if (isDataProcessedSuccessfully == null) {
      return Icons.check_circle;
    }
    return isDataProcessedSuccessfully == true ? Icons.check_circle : Icons.error;
  }

  Color _getIconColor() {
    if (isDataProcessedSuccessfully == null) {
      return Colors.grey; // Color inicial
    }
    if (isDataProcessedSuccessfully == true) {
      return isEntrance ? Colors.green : Colors.redAccent;
    }
    return Colors.red; // Rojo para error
  }

  bool _isQRCodeProcessed(String qrCode, String date) {
    return processedCodes.containsKey(qrCode) &&
        processedCodes[qrCode]!.containsKey(date) &&
        processedCodes[qrCode]![date]!.containsKey(isEntrance.toString());
  }

  String _getTodayString() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
