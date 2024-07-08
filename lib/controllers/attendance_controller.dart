import '../service/firestore_service.dart';
import '../utils/logger.dart';
import '../service/notification_service.dart';
import 'package:get/get.dart';

class AttendanceController {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = Get.find<NotificationService>();

  Future<bool> handleScannedQR(String qrCode, bool isEntrance) async {
    try {
      await _firestoreService.registrarAsistencia(qrCode, isEntrance);
      AppLogger.log('Asistencia registrada para $qrCode', prefix: 'ASISTENCIA:');

      await _enviarNotificacionPadre(qrCode, isEntrance);

      return true;
    } catch (e) {
      AppLogger.log('Error al registrar asistencia: $e', prefix: 'ERROR:');
      return false;
    }
  }

  Future<void> _enviarNotificacionPadre(String qrCode, bool isEntrance) async {
    try {
      String accion = isEntrance ? "ingresó" : "salió";
      String horaActual = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5);

      await _notificationService.enviarNotificacionPorQR(
        qrCode: qrCode,
        titulo: "Registro de Asistencia",
        cuerpo: "Su hijo $accion del colegio a las $horaActual",
      );
    } catch (e) {
      AppLogger.log('Error al enviar notificación: $e', prefix: 'ERROR:');
    }
  }

  Future<List<Map<String, dynamic>>> getAsistenciasPorGrupoYFecha(String grupoId, DateTime fecha) async {
    try {
      var asistencias = await _firestoreService.getAsistenciasPorGrupoYFecha(grupoId, fecha);
      AppLogger.log("Asistencias recuperadas para el grupo $grupoId en la fecha $fecha: ${asistencias.length}", prefix: 'ASISTENCIAS:');
      return asistencias;
    } catch (e) {
      AppLogger.log('Error al obtener asistencias: $e', prefix: 'ERROR:');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getAsistenciasPorPadreYFecha(String padreId, DateTime fecha) {
    return _firestoreService.getAsistenciasPorPadreYFecha(padreId, fecha).map((asistencias) {
      AppLogger.log("Asistencias actualizadas para el padre $padreId en la fecha $fecha: ${asistencias.length}", prefix: 'ASISTENCIAS:');
      return asistencias;
    }).handleError((error) {
      AppLogger.log('Error al obtener asistencias para el padre: $error', prefix: 'ERROR:');
      return <Map<String, dynamic>>[];
    });
  }

  Future<List<Map<String, dynamic>>> getIdentificarInasistencias(String grupoId, DateTime fecha) async {
    if (fecha.isAfter(DateTime.now())) {
      return [];
    }

    var asistencias = await getAsistenciasPorGrupoYFecha(grupoId, fecha);
    var listaAlumnos = await _firestoreService.getListaCompletaAlumnos(grupoId);

    List<Map<String, dynamic>> inasistencias = [];

    for (var alumno in listaAlumnos) {
      if (!asistencias.any((asistencia) => asistencia['codigo'] == alumno['QR'])) {
        inasistencias.add({
          'codigo': alumno['QR'],
          'info': {
            'nombre': alumno['nombre'],
            'entrada': null,
            'salida': null
          }
        });
      }
    }

    return inasistencias;
  }
}
