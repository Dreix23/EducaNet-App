import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/attendance_controller.dart';
import '../../../utils/logger.dart';

class AsistenciaScreen extends StatefulWidget {
  final String grupoId;

  AsistenciaScreen({Key? key, required this.grupoId}) : super(key: key);

  @override
  _AsistenciaScreenState createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> with SingleTickerProviderStateMixin {
  final AttendanceController _controller = AttendanceController();
  TabController? _tabController;

  DateTime fechaSeleccionada = DateTime.now();
  List<Map<String, dynamic>> _asistencias = [];
  List<Map<String, dynamic>> _inasistencias = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarAsistencias();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _cargarAsistencias() async {
    try {
      var asistencias = await _controller.getAsistenciasPorGrupoYFecha(widget.grupoId, fechaSeleccionada);
      var inasistencias = await _controller.getIdentificarInasistencias(widget.grupoId, fechaSeleccionada);

      // Filtrar inasistencias eliminando los alumnos que ya tienen entrada registrada
      inasistencias = inasistencias.where((inasistencia) {
        return !asistencias.any((asistencia) => asistencia['codigo'] == inasistencia['codigo']);
      }).toList();

      // Ordenar asistencias por primer apellido en orden alfabético
      asistencias.sort((a, b) {
        var apellidoA = a['info']['nombre'].split(' ').first.toUpperCase();
        var apellidoB = b['info']['nombre'].split(' ').first.toUpperCase();
        return apellidoA.compareTo(apellidoB);
      });

      // Ordenar inasistencias por primer apellido en orden alfabético
      inasistencias.sort((a, b) {
        var apellidoA = a['info']['nombre'].split(' ').first.toUpperCase();
        var apellidoB = b['info']['nombre'].split(' ').first.toUpperCase();
        return apellidoA.compareTo(apellidoB);
      });

      setState(() {
        _asistencias = asistencias;
        _inasistencias = inasistencias;
      });
    } catch (e) {
      AppLogger.log('Error al cargar datos: $e');
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
    );

    if (fechaElegida != null && fechaElegida != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = fechaElegida;
        _cargarAsistencias();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isScreenWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Asistencias - ${widget.grupoId}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Asistencias'),
            Tab(text: 'Inasistencias'),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _seleccionarFecha(context),
          ),
        ],
      ),
      body: isScreenWide
          ? Row(
        children: [
          Expanded(
            child: _buildAsistenciaList(),
          ),
          VerticalDivider(width: 1),
          Expanded(
            child: _buildInasistenciaList(),
          ),
        ],
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAsistenciaList(),
          _buildInasistenciaList(),
        ],
      ),
    );
  }

  Widget _buildAsistenciaList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _cargarAsistencias();
      },
      child: ListView.builder(
        itemCount: _asistencias.length,
        itemBuilder: (context, index) {
          var asistencia = _asistencias[index];
          var infoAsistencia = asistencia['info'] as Map<String, dynamic>;
          return _buildListTile(infoAsistencia, false);
        },
      ),
    );
  }

  Widget _buildInasistenciaList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _cargarAsistencias();
      },
      child: ListView.builder(
        itemCount: _inasistencias.length,
        itemBuilder: (context, index) {
          var inasistencia = _inasistencias[index];
          var infoInasistencia = inasistencia['info'] as Map<String, dynamic>;
          return _buildListTile(infoInasistencia, true);
        },
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> info, bool esInasistente) {
    if (esInasistente) {
      return ListTile(
        leading: Icon(Icons.account_circle, size: 40.0),
        title: Text(
          info['nombre'] ?? 'Desconocido',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'No asistió',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 14.0,
          ),
        ),
      );
    } else {
      String entrada = _formatDate(info['entrada']);
      String salida = _formatDate(info['salida']);
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
              TextSpan(text: entrada.isNotEmpty ? '$entrada - ' : '', style: TextStyle(color: Colors.green[200])),
              TextSpan(text: 'Salida: ', style: TextStyle(color: Colors.red[200])),
              TextSpan(text: salida.isNotEmpty ? salida : 'No registrado', style: TextStyle(color: Colors.red[200])),
            ],
          ),
        ),
      );
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    DateTime parsedDate = DateTime.parse(isoString);
    return DateFormat('h:mm a').format(parsedDate); // Formato 9:05 AM
  }
}
