import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../service/alumno_service.dart';
import '../utils/logger.dart';

class AsistenciasController extends GetxController {
  final AlumnoService _alumnoService = AlumnoService();
  final RxList<String> cursos = <String>[].obs;
  final RxString cursoSeleccionado = ''.obs;
  final RxMap<DateTime, Map<String, bool>> asistencias = <DateTime, Map<String, bool>>{}.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxString alumnoQR = ''.obs;
  StreamSubscription? _asistenciasSubscription;

  @override
  void onInit() {
    super.onInit();
    cargarCursos();
  }

  @override
  void onClose() {
    _asistenciasSubscription?.cancel();
    super.onClose();
  }

  void setAlumnoQR(String qr) {
    alumnoQR.value = qr;
    if (cursoSeleccionado.isNotEmpty) {
      cargarAsistencias();
    }
  }

  Future<void> cargarCursos() async {
    try {
      String grado = await _alumnoService.obtenerGradoAlumno();
      Map<String, List<String>> materias = await _alumnoService.cargarMaterias();
      cursos.value = materias[grado] ?? [];
      AppLogger.log('Cursos cargados: ${cursos.value}');
      if (cursos.isNotEmpty) {
        cursoSeleccionado.value = cursos[0];
        cargarAsistencias();
      }
    } catch (e) {
      AppLogger.log('Error al cargar cursos: $e');
    }
  }

  void seleccionarCurso(String curso) {
    cursoSeleccionado.value = curso;
    AppLogger.log('Curso seleccionado: $curso');
    cargarAsistencias();
  }

  Future<void> cargarAsistencias() async {
    try {
      if (cursoSeleccionado.isNotEmpty && alumnoQR.isNotEmpty) {
        AppLogger.log('Cargando asistencias para el curso: ${cursoSeleccionado.value} y alumno QR: ${alumnoQR.value}');

        // Cancelar la suscripción anterior si existe
        _asistenciasSubscription?.cancel();

        // Suscribirse al stream de asistencias
        _asistenciasSubscription = _alumnoService.getAsistenciasDelAlumno(cursoSeleccionado.value, alumnoQR.value).listen((updatedAsistencias) {
          asistencias.value = updatedAsistencias;
          AppLogger.log('Asistencias cargadas: ${asistencias.length}');
          update();
        });
      }
    } catch (e) {
      AppLogger.log('Error al cargar asistencias: $e');
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
    AppLogger.log('Día seleccionado: $selectedDay');
  }

  Color getAsistenciaColor(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (asistencias.containsKey(dateKey)) {
      var asistencia = asistencias[dateKey]!;
      if (asistencia['presente'] == true) return Colors.green;
      if (asistencia['retardo'] == true) return Colors.orange;
      if (asistencia['falta'] == true) return Colors.red;
      if (asistencia['justificado'] == true) return Colors.blue;
    }
    return Colors.grey;
  }
}
