import 'dart:async';
import 'package:get/get.dart';
import '../service/alumno_service.dart';
import '../utils/logger.dart';

class AvisosController extends GetxController {
  final AlumnoService _alumnoService = AlumnoService();
  final RxList<Map<String, dynamic>> avisos = <Map<String, dynamic>>[].obs;
  final RxList<String> cursos = <String>[].obs;
  final RxString cursoSeleccionado = ''.obs;
  final RxString alumnoQR = ''.obs;
  final RxString avisoExpandido = ''.obs;
  StreamSubscription? _avisosSubscription;

  @override
  void onInit() {
    super.onInit();
    cargarCursos();
  }

  @override
  void onClose() {
    _avisosSubscription?.cancel();
    super.onClose();
  }

  void setAlumnoQR(String qr) {
    alumnoQR.value = qr;
    AppLogger.log('QR del alumno establecido: $qr', prefix: 'AVISOS:');
    if (cursoSeleccionado.isNotEmpty) {
      fetchAvisos();
    }
  }

  Future<void> cargarCursos() async {
    try {
      String grado = await _alumnoService.obtenerGradoAlumno();
      await for (var materias in _alumnoService.cargarMaterias()) {
        cursos.value = ['GENERAL', ...materias[grado] ?? []];
        AppLogger.log('Cursos cargados: ${cursos.value}', prefix: 'AVISOS:');
        if (cursos.isNotEmpty) {
          cursoSeleccionado.value = 'GENERAL';
          fetchAvisos();
        }
        break; // Solo necesitamos el primer valor del stream
      }
    } catch (e) {
      AppLogger.log('Error al cargar cursos: $e', prefix: 'AVISOS:');
    }
  }

  void seleccionarCurso(String curso) {
    cursoSeleccionado.value = curso;
    AppLogger.log('Curso seleccionado: $curso', prefix: 'AVISOS:');
    fetchAvisos();
  }

  void fetchAvisos() {
    if (cursoSeleccionado.isEmpty || alumnoQR.isEmpty) {
      AppLogger.log('Curso o QR del alumno no seleccionado', prefix: 'AVISOS:');
      return;
    }

    _avisosSubscription?.cancel();

    if (cursoSeleccionado.value == 'GENERAL') {
      fetchAvisosGenerales();
    } else {
      fetchAvisosDelCurso();
    }
  }

  void fetchAvisosGenerales() {
    _avisosSubscription = _alumnoService.getAvisosGenerales(alumnoQR.value).listen(
          (avisosData) {
        procesarAvisos(avisosData);
      },
      onError: (e) {
        AppLogger.log('Error al obtener avisos generales: $e', prefix: 'AVISOS:');
      },
    );
  }

  void fetchAvisosDelCurso() {
    _avisosSubscription = _alumnoService.getAvisosDelCurso(cursoSeleccionado.value, alumnoQR.value).listen(
          (avisosData) {
        procesarAvisos(avisosData);
      },
      onError: (e) {
        AppLogger.log('Error al obtener avisos del curso: $e', prefix: 'AVISOS:');
      },
    );
  }

  void procesarAvisos(List<Map<String, dynamic>> avisosData) {
    DateTime now = DateTime.now();
    avisos.assignAll(avisosData.where((aviso) {
      DateTime? fechaPublicacion = DateTime.tryParse(aviso['fechaPublicacion'] ?? '');
      bool esGeneral = cursoSeleccionado.value == 'GENERAL';
      aviso['esGeneral'] = esGeneral;
      return fechaPublicacion != null && fechaPublicacion.isAfter(now);
    }).toList());
    AppLogger.log('Avisos cargados: ${avisos.length}', prefix: 'AVISOS:');
    update();
  }

  void toggleExpand(String avisoId) {
    avisoExpandido.value = avisoExpandido.value == avisoId ? '' : avisoId;
  }
}
