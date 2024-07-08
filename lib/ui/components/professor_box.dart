import '../../dialogs/add_alumno_dialog.dart';
import '../../ui/screens/profesor/AsistenciaScreen.dart';
import '../../ui/widgets/group_buttons.dart';
import 'package:flutter/material.dart';

class ProfesorBox extends StatelessWidget {
  final VoidCallback onQRButtonPressed;

  ProfesorBox({required this.onQRButtonPressed});

  void _handleGroupButtonPressed(BuildContext context, String group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AsistenciaScreen(grupoId: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0), // Padding externo del contenedor principal
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFD8C7F8),
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding( // Mover el Padding aquí
                padding: const EdgeInsets.all(26.0),
                child: GroupButtons(
                  onGroupButtonPressed: (group) {
                    _handleGroupButtonPressed(context, group);
                  },
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Center(
                      child: Text(
                        "Grupos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: 62.0,
                      width: 120.0, // Asegúrate de que este ancho no sea demasiado grande para el espacio disponible
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFAF8FD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: FloatingActionButton(
                              heroTag: "qrButton",
                              onPressed: onQRButtonPressed,
                              child: Icon(Icons.qr_code_scanner),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: FloatingActionButton(
                        heroTag: "addButton",
                        onPressed: () {
                          // Lógica para el botón de agregar
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddAlumnoDialog();
                            },
                          );
                        },
                        child: Icon(Icons.add),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: CircleBorder(),
                        mini: true, // Hace el botón más pequeño
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

