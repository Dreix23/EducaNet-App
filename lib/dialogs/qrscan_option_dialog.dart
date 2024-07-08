import 'package:flutter/material.dart';

import '../ui/screens/profesor/ExternalScannerScreen.dart';
import '../ui/screens/profesor/QRScanScreen.dart';

class QRScanOptionDialog extends StatefulWidget {
  @override
  _QRScanOptionDialogState createState() => _QRScanOptionDialogState();
}

class _QRScanOptionDialogState extends State<QRScanOptionDialog> {
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
    // Ancho fijo para el contenedor del diálogo
    double containerWidth = 360;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          width: containerWidth,
          padding: EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Selecciona el método de escaneo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 45),  // Aumento del espacio para acomodar el ícono de QR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircularButton(
                    icon: Icons.camera_alt,
                    color: Colors.pinkAccent,
                    size: 70,  // Tamaño aumentado para los botones
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => QRScanScreen()),  // Navega a QRScanScreen
                      );
                    },
                  ),
                  SizedBox(width: 40),  // Espacio aumentado entre botones
                  _buildCircularButton(
                    icon: Icons.scanner,
                    color: Colors.purpleAccent,
                    size: 70,  // Tamaño aumentado para los botones
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ExternalScannerScreen()),  // Navega a ExternalScannerScreen
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -35,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            radius: 35,  // Tamaño ajustado del ícono de QR
            child: Icon(Icons.qr_code_scanner, size: 35, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({required IconData icon, required Color color, required double size, required VoidCallback onPressed}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size / 2,  // Tamaño del ícono basado en el tamaño del botón
        onPressed: onPressed,
      ),
    );
  }
}
