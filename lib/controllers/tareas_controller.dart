import 'dart:async';
import 'package:get/get.dart';
import '../service/alumno_service.dart';
import '../utils/logger.dart';

class TareasController extends GetxController {
  final AlumnoService _alumnoService = AlumnoService();
  final RxList<String> cursos = <String>[].obs;
  final RxString cursoSeleccionado = ''.obs;
  final RxList<Map<String, dynamic>> tareas = <Map<String, dynamic>>[].obs;
  final RxString alumnoQR = ''.obs;
  final RxString tareaExpandida = ''.obs;
  StreamSubscription? _tareasSubscription;

  @override
  void onInit() {
    super.onInit();
    cargarCursos();
  }

  @override
  void onClose() {
    _tareasSubscription?.cancel();
    super.onClose();
  }

  void setAlumnoQR(String qr) {
    alumnoQR.value = qr;
    if (cursoSeleccionado.isNotEmpty) {
      cargarTareas();
    }
  }

  Future<void> cargarCursos() async {
    try {
      String grado = await _alumnoService.obtenerGradoAlumno();
      await for (var materias in _alumnoService.cargarMaterias()) {
        cursos.value = materias[grado] ?? [];
        AppLogger.log('Cursos cargados: ${cursos.value}', prefix: 'TAREAS:');
        if (cursos.isNotEmpty) {
          cursoSeleccionado.value = cursos[0];
          cargarTareas();
        }
        break; // Solo necesitamos el primer valor del stream
      }
    } catch (e) {
      AppLogger.log('Error al cargar cursos: $e', prefix: 'TAREAS:');
    }
  }

  void seleccionarCurso(String curso) {
    cursoSeleccionado.value = curso;
    AppLogger.log('Curso seleccionado: $curso', prefix: 'TAREAS:');
    cargarTareas();
  }

  Future<void> cargarTareas() async {
    try {
      if (cursoSeleccionado.isNotEmpty && alumnoQR.isNotEmpty) {
        AppLogger.log('Cargando tareas para el curso: ${cursoSeleccionado.value} y alumno QR: ${alumnoQR.value}', prefix: 'TAREAS:');

        _tareasSubscription?.cancel();

        _tareasSubscription = _alumnoService.getTareasDelAlumno(cursoSeleccionado.value, alumnoQR.value).listen(
              (updatedTareas) {
            tareas.value = updatedTareas;
            AppLogger.log('Tareas cargadas: ${tareas.length}', prefix: 'TAREAS:');
            update();
          },
          onError: (error) {
            AppLogger.log('Error en la suscripción de tareas: $error', prefix: 'TAREAS:');
          },
          onDone: () {
            AppLogger.log('Suscripción de tareas finalizada', prefix: 'TAREAS:');
          },
        );
      }
    } catch (e) {
      AppLogger.log('Error al cargar tareas: $e', prefix: 'TAREAS:');
    }
  }

  Stream<Map<String, dynamic>?> obtenerCalificacion(String tareaId) {
    if (cursoSeleccionado.value.isEmpty || tareaId.isEmpty || alumnoQR.value.isEmpty) {
      AppLogger.log('Error: cursoSeleccionado, tareaId o alumnoQR está vacío', prefix: 'TAREAS:');
      AppLogger.log('cursoSeleccionado: "${cursoSeleccionado.value}", tareaId: "$tareaId", alumnoQR: "${alumnoQR.value}"', prefix: 'TAREAS:');
      return Stream.value(null);
    }
    return _alumnoService.obtenerCalificacion(cursoSeleccionado.value, tareaId, alumnoQR.value);
  }

  void toggleExpand(String tareaId) {
    tareaExpandida.value = tareaExpandida.value == tareaId ? '' : tareaId;
  }
}
