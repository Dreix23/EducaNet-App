import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PadresBox extends StatelessWidget {
  final VoidCallback onAdd;
  final Widget floatingActionButton;
  final Stream<List<Map<String, dynamic>>> asistenciasStream;

  PadresBox({
    required this.onAdd,
    required this.floatingActionButton,
    required this.asistenciasStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: asistenciasStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<Map<String, dynamic>> asistencias = snapshot.data ?? [];

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Asistencia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 44,
                child: InkWell(
                  onTap: onAdd,
                  child: Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 30.0),
                ),
              ),
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                bottom: 70,
                child: asistencias.isEmpty
                    ? Center(
                  child: Text(
                    'No hay asistencias disponibles',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
                    : ListView.builder(
                  itemCount: asistencias.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> info = asistencias[index]['info'] ?? {};
                    return _buildListTile(info);
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 122,
                right: 122,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(250, 240, 252, 1.0),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: floatingActionButton,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(Map<String, dynamic> info) {
    String entrada = _formatTime(info['entrada']);
    String salida = _formatTime(info['salida']);

    return ListTile(
      leading: Icon(Icons.account_circle, size: 40.0),
      title: Text(
        info['nombre'] ?? 'Desconocido',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14.0,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Entrada: ', style: TextStyle(color: Colors.green[200])),
            TextSpan(text: '$entrada - ', style: TextStyle(color: Colors.green[200])),
            TextSpan(text: 'Salida: ', style: TextStyle(color: Colors.red[200])),
            TextSpan(text: salida, style: TextStyle(color: Colors.red[200])),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return 'No registrado';
    DateTime parsedDate = DateTime.parse(isoString);
    return DateFormat('h:mm a').format(parsedDate);
  }
}
