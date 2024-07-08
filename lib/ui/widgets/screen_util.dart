// screen_util.dart
import 'package:flutter/material.dart';

enum ScreenType { column, row, dual }

class ScreenUtil extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onPress;
  final ScreenType screenType;
  final double maxWidth;
  final Widget? secondChild; // Segundo widget para el modo dual

  const ScreenUtil({
    Key? key,
    required this.color,
    required this.child,
    this.onPress,
    required this.screenType,
    this.maxWidth = 600,
    this.secondChild, // Parámetro opcional para el segundo hijo en el modo dual
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (screenType == ScreenType.dual && constraints.maxWidth > maxWidth) {
            // Diseño dual para pantallas grandes
            return Row(
              children: [
                Expanded(child: _buildContainer(child)),
                VerticalDivider(width: 1),
                Expanded(child: _buildContainer(secondChild ?? Container())),
              ],
            );
          } else {
            // Diseño de columna o fila para pantallas más pequeñas
            Widget content = (screenType == ScreenType.row && constraints.maxWidth > maxWidth) ?
            Row(children: [Expanded(child: _buildContainer(child))]) :
            _buildContainer(child);

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildContainer(Widget child) {
    return Container(
      child: child,
      margin: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  // Función para determinar el número de columnas
  static int getCrossAxisCount(BuildContext context, {int largeScreenColumns = 16}) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return largeScreenColumns;
    } else if (screenWidth > 900) {
      return 10;
    } else if (screenWidth > 600) {
      return 8;
    } else {
      return 4;
    }
  }
}
