import 'package:flutter/material.dart';

import '../controllers/user_controller.dart';
import '../ui/screens/padre/QRScanHijo.dart';
import '../ui/widgets/custom_snackbar.dart';
import '../utils/logger.dart';

class AddHijoDialog extends StatefulWidget {
  @override
  _AddHijoDialogState createState() => _AddHijoDialogState();
}

class _AddHijoDialogState extends State<AddHijoDialog> {
  late TextEditingController _codeController;
  late FocusNode _codeFocusNode;
  UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();

    _codeFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _openQRScanner() {
    AppLogger.log('Abriendo escáner QR');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QRScanHijo(
        onCodeScanned: (String code) {
          Navigator.of(context).pop();
          AppLogger.log('Actualizando campo de texto con el código escaneado');
          setState(() {
            _codeController.text = code;
          });
        },
      ),
    ));
  }

  void _guardarCodigoYCerrar() async {
    if (_codeController.text.isNotEmpty) {
      try {
        await _userController.guardarCodigoQR(_codeController.text);
        Navigator.of(context).pop();

        CustomSnackbar.show(
          context,
          'Código QR guardado con éxito',
          SnackbarState.completed,
        );
      } catch (e) {
        CustomSnackbar.show(
          context,
          'Error al guardar el código QR',
          SnackbarState.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400), // Aumentar el ancho máximo
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Añadir Hijo",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.pink[300]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  decoration: InputDecoration(
                    hintText: "Código del Alumno",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(
                      Icons.qr_code,
                      color: _codeFocusNode.hasFocus ? Colors.teal[100] : Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _openQRScanner,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal[100]!, width: 2.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _guardarCodigoYCerrar,
                        child: Text(
                          "Aceptar",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -40,
            child: CircleAvatar(
              backgroundColor: Colors.pink[300],
              radius: 40,
              child: Icon(Icons.person_add, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
