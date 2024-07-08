import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../ui/screens/padre/QRScanHijo.dart';
import '../ui/widgets/custom_snackbar.dart';
import '../ui/widgets/screen_util.dart';
import '../utils/logger.dart';

class AddAlumnoDialog extends StatefulWidget {
  @override
  _AddAlumnoDialogState createState() => _AddAlumnoDialogState();
}

class _AddAlumnoDialogState extends State<AddAlumnoDialog> {
  late TextEditingController _codeController, _grupoController, _nombreController;
  late FocusNode _codeFocusNode, _grupoFocusNode, _nombreFocusNode;
  UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _grupoController = TextEditingController();
    _nombreController = TextEditingController();
    _codeFocusNode = FocusNode();
    _grupoFocusNode = FocusNode();
    _nombreFocusNode = FocusNode();

    // Convertir a mayúsculas al escribir
    _grupoController.addListener(() {
      _grupoController.value = _grupoController.value.copyWith(
        text: _grupoController.text.toUpperCase(),
      );
    });
    _nombreController.addListener(() {
      _nombreController.value = _nombreController.value.copyWith(
        text: _nombreController.text.toUpperCase(),
      );
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _grupoController.dispose();
    _nombreController.dispose();
    _codeFocusNode.dispose();
    _grupoFocusNode.dispose();
    _nombreFocusNode.dispose();
    super.dispose();
  }

  void _openQRScanner() {
    AppLogger.log('Abriendo escáner QR');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QRScanHijo(
        onCodeScanned: (String code) {
          Navigator.of(context).pop(); // Cierra primero el escáner QR
          AppLogger.log('Actualizando campo de texto con el código escaneado');
          setState(() {
            _codeController.text = code; // Actualiza el campo de texto con el código escaneado
          });
        },
      ),
    ));
  }

  void _guardarDatosYCerrar() async {
    String qr = _codeController.text.trim();
    String grupo = _grupoController.text.trim().toUpperCase(); // Asegurar que el grupo esté en mayúsculas
    String nombre = _nombreController.text.trim();

    // Validación básica
    if (qr.isEmpty || grupo.isEmpty || nombre.isEmpty) {
      CustomSnackbar.show(
        context,
        'Por favor, completa todos los campos',
        SnackbarState.error,
      );
      return;
    }

    try {
      // Llama al método de UserController para agregar el alumno
      await _userController.agregarAlumnoAGrupo(qr, grupo, nombre);

      // Muestra un mensaje de éxito
      CustomSnackbar.show(
        context,
        'Alumno agregado con éxito',
        SnackbarState.completed,
      );

      // Cierra el diálogo
      Navigator.of(context).pop();
    } catch (e) {
      // Muestra un mensaje de error
      CustomSnackbar.show(
        context,
        'Error al agregar alumno',
        SnackbarState.error,
      );
      print('Error al agregar alumno: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ScreenUtil(
        color: Colors.transparent,
        screenType: ScreenType.column,
        maxWidth: 500, // Ajusta el ancho máximo según sea necesario
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                SizedBox(height: 40),
                Text(
                  "Añadir Alumno",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.pink[300]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  decoration: InputDecoration(
                    hintText: "Código del Alumno",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    prefixIcon: Icon(Icons.qr_code, color: _codeFocusNode.hasFocus ? Colors.teal[100] : Colors.grey),
                    suffixIcon: IconButton(icon: Icon(Icons.camera_alt), onPressed: _openQRScanner),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal[100]!, width: 2.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _grupoController,
                  focusNode: _grupoFocusNode,
                  decoration: InputDecoration(
                    hintText: "Grupo del Alumno",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    // Resto del estilo y propiedades
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _nombreController,
                  focusNode: _nombreFocusNode,
                  decoration: InputDecoration(
                    hintText: "Nombre del Alumno",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    // Resto del estilo y propiedades
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancelar", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ),
                    SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: _guardarDatosYCerrar,
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
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -36,
            child: CircleAvatar(
              backgroundColor: Colors.pink[300],
              radius: 36,
              child: Icon(Icons.person_add, size: 36, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
