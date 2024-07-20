import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AlumnoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getSchoolIdForCurrentUser() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      AppLogger.log('Obteniendo schoolId para el usuario: $userId');
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String schoolId = userData['school'];
        AppLogger.log('SchoolId obtenido: $schoolId para el usuario: $userId');
        return schoolId;
      } else {
        AppLogger.log('Usuario no encontrado: $userId');
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      AppLogger.log('Error al obtener schoolId: $e');
      throw e;
    }
  }

  Stream<Map<String, List<String>>> cargarMaterias() async* {
    try {
      String jsonString = await rootBundle.loadString('assets/materias.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      Map<String, List<String>> materias = {};
      jsonMap.forEach((key, value) {
        materias[key] = List<String>.from(value);
      });
      AppLogger.log('Materias cargadas: $materias', prefix: 'CARGAR_MATERIAS:');
      yield materias;
    } catch (e) {
      AppLogger.log('Error al cargar materias: $e', prefix: 'ERROR_CARGAR_MATERIAS:');
      yield {};
    }
  }

  Stream<List<Map<String, String>>> obtenerNombresAlumnos() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return _db.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String schoolId = userData['school'];
        List<dynamic> codigosQR = userData['codigoQR'] as List<dynamic>;

        QuerySnapshot gruposSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();

        List<Map<String, String>> alumnos = [];

        for (var grupoDoc in gruposSnapshot.docs) {
          var grupoData = grupoDoc.data() as Map<String, dynamic>;
          grupoData.forEach((key, value) {
            if (value is Map<String, dynamic> &&
                value.containsKey('NOM_ALUMNO') &&
                value.containsKey('QR') &&
                codigosQR.contains(value['QR'])) {
              alumnos.add({
                'nombre': value['NOM_ALUMNO'],
                'qr': value['QR']
              });
            }
          });
        }

        AppLogger.log('Alumnos obtenidos: $alumnos');
        return alumnos;
      } else {
        throw Exception('Usuario no encontrado');
      }
    });
  }

  Future<String> obtenerGradoAlumno() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> codigosQR = userData['codigoQR'] as List<dynamic>;
        if (codigosQR.isNotEmpty) {
          String qrCode = codigosQR.first.toString();
          String schoolId = userData['school'];
          QuerySnapshot gruposSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();
          for (var grupoDoc in gruposSnapshot.docs) {
            String grupoId = grupoDoc.id;
            DocumentSnapshot grupoSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').doc(grupoId).get();
            if (grupoSnapshot.exists && grupoSnapshot.data() != null) {
              var alumnos = grupoSnapshot.data() as Map<String, dynamic>;
              for (var alumno in alumnos.values) {
                if (alumno['QR'] == qrCode) {
                  AppLogger.log('Grado del alumno encontrado: ${grupoId[0]}');
                  return grupoId[0];
                }
              }
            }
          }
        }
      }
      throw Exception('No se encontró el grado del alumno');
    } catch (e) {
      AppLogger.log('Error al obtener grado del alumno: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getTareasDelAlumno(String cursoSeleccionado, String qrAlumno) async* {
    try {
      AppLogger.log('Obteniendo tareas para el alumno con QR: $qrAlumno en el curso: $cursoSeleccionado');

      String schoolId = await getSchoolIdForCurrentUser();
      AppLogger.log('SchoolId del usuario: $schoolId');

      QuerySnapshot gruposSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();
      AppLogger.log('Ruta consulta grupos: colegios/$schoolId/alumnos');

      for (var grupoDoc in gruposSnapshot.docs) {
        String grupoId = grupoDoc.id;
        AppLogger.log('Consultando grupo: $grupoId');

        DocumentSnapshot grupoSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').doc(grupoId).get();
        AppLogger.log('Ruta consulta grupo: colegios/$schoolId/alumnos/$grupoId');

        if (grupoSnapshot.exists && grupoSnapshot.data() != null) {
          var alumnos = grupoSnapshot.data() as Map<String, dynamic>;
          bool alumnoEncontrado = alumnos.values.any((alumno) => alumno['QR'] == qrAlumno);

          if (alumnoEncontrado) {
            AppLogger.log('Alumno encontrado en grupo: $grupoId');
            AppLogger.log('Buscando tareas para el grupo: $grupoId en curso $cursoSeleccionado');
            Stream<QuerySnapshot> tareasStream = _db
                .collection('colegios')
                .doc(schoolId)
                .collection('cursos')
                .doc(cursoSeleccionado)
                .collection('tareas')
                .where('grupo', isEqualTo: grupoId)
                .snapshots();

            await for (QuerySnapshot snapshot in tareasStream) {
              List<Map<String, dynamic>> tareas = [];
              for (var doc in snapshot.docs) {
                var tarea = doc.data() as Map<String, dynamic>;
                tarea['id'] = doc.id;  // Añadir el ID del documento a la tarea
                tareas.add(tarea);
                AppLogger.log('Tarea encontrada: $tarea');
              }
              yield tareas;
            }
            break;
          }
        }
      }
    } catch (e) {
      AppLogger.log('Error al obtener tareas del alumno: $e');
      throw e;
    }
  }

  Stream<Map<String, dynamic>?> obtenerCalificacion(String cursoId, String tareaId, String alumnoQR) async* {
    try {
      // Verificar que los parámetros no estén vacíos
      if (cursoId.isEmpty || tareaId.isEmpty || alumnoQR.isEmpty) {
        AppLogger.log('Error: cursoId, tareaId o alumnoQR está vacío', prefix: 'CALIFICACION:');
        AppLogger.log('cursoId: "$cursoId", tareaId: "$tareaId", alumnoQR: "$alumnoQR"', prefix: 'CALIFICACION:');
        yield null;
        return;
      }

      AppLogger.log('Obteniendo calificación para el alumno con QR: $alumnoQR en la tarea: $tareaId del curso: $cursoId', prefix: 'CALIFICACION:');

      String schoolId = await getSchoolIdForCurrentUser();

      // Construir la ruta completa
      String rutaCompleta = 'colegios/$schoolId/cursos/$cursoId/tareas/$tareaId/calificaciones/$alumnoQR';
      AppLogger.log('Ruta completa para obtener calificación: $rutaCompleta', prefix: 'CALIFICACION:');

      Stream<DocumentSnapshot> calificacionStream = _db.doc(rutaCompleta).snapshots();

      await for (DocumentSnapshot calificacionDoc in calificacionStream) {
        if (calificacionDoc.exists) {
          var calificacionData = calificacionDoc.data() as Map<String, dynamic>;
          AppLogger.log('Calificación obtenida para el alumno $alumnoQR en la tarea $tareaId: $calificacionData', prefix: 'CALIFICACION:');
          yield calificacionData;
        } else {
          AppLogger.log('No se encontró calificación para el alumno $alumnoQR en la tarea $tareaId', prefix: 'CALIFICACION:');
          yield null;
        }
      }
    } catch (e) {
      AppLogger.log('Error al obtener calificación: $e', prefix: 'CALIFICACION:');
      yield null;
    }
  }

  Stream<Map<DateTime, Map<String, bool>>> getAsistenciasDelAlumno(String cursoSeleccionado, String qrAlumno) async* {
    try {
      AppLogger.log('Obteniendo asistencias para el alumno con QR: $qrAlumno en el curso: $cursoSeleccionado');

      String schoolId = await getSchoolIdForCurrentUser();

      QuerySnapshot gruposSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();

      for (var grupoDoc in gruposSnapshot.docs) {
        String grupoId = grupoDoc.id;
        DocumentSnapshot grupoSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').doc(grupoId).get();

        if (grupoSnapshot.exists && grupoSnapshot.data() != null) {
          var alumnos = grupoSnapshot.data() as Map<String, dynamic>;
          bool alumnoEncontrado = alumnos.values.any((alumno) => alumno['QR'] == qrAlumno);

          if (alumnoEncontrado) {
            Stream<QuerySnapshot> asistenciasStream = _db
                .collection('colegios')
                .doc(schoolId)
                .collection('cursos')
                .doc(cursoSeleccionado)
                .collection('asistencias')
                .snapshots();

            await for (QuerySnapshot snapshot in asistenciasStream) {
              Map<DateTime, Map<String, bool>> asistencias = {};
              for (var doc in snapshot.docs) {
                DateTime fecha = DateTime.parse(doc.id);
                var asistenciaData = doc.data() as Map<String, dynamic>;
                if (asistenciaData.containsKey(qrAlumno)) {
                  asistencias[fecha] = {
                    'presente': asistenciaData[qrAlumno]['presente'] ?? false,
                    'retardo': asistenciaData[qrAlumno]['retardo'] ?? false,
                    'falta': asistenciaData[qrAlumno]['falta'] ?? false,
                    'justificado': asistenciaData[qrAlumno]['justificado'] ?? false,
                  };
                }
              }
              yield asistencias;
            }
            break;
          }
        }
      }
    } catch (e) {
      AppLogger.log('Error al obtener asistencias del alumno: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getAvisosDelCurso(String cursoSeleccionado, String qrAlumno) async* {
    try {
      AppLogger.log('Obteniendo avisos para el alumno con QR: $qrAlumno en el curso: $cursoSeleccionado', prefix: 'AVISOS:');

      String schoolId = await getSchoolIdForCurrentUser();

      // Buscar el grupo del alumno
      String? grupoAlumno;
      QuerySnapshot gruposSnapshot = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();
      for (var grupoDoc in gruposSnapshot.docs) {
        var alumnos = grupoDoc.data() as Map<String, dynamic>;
        if (alumnos.values.any((alumno) => alumno['QR'] == qrAlumno)) {
          grupoAlumno = grupoDoc.id;
          break;
        }
      }

      if (grupoAlumno == null) {
        AppLogger.log('No se encontró el grupo del alumno', prefix: 'AVISOS:');
        yield [];
        return;
      }

      AppLogger.log('Alumno encontrado en grupo: $grupoAlumno', prefix: 'AVISOS:');

      Stream<QuerySnapshot> avisosStream = _db
          .collection('colegios')
          .doc(schoolId)
          .collection('cursos')
          .doc(cursoSeleccionado)
          .collection('avisos')
          .where('grupo', isEqualTo: grupoAlumno)
          .orderBy('fechaPublicacion', descending: true)
          .snapshots();

      await for (QuerySnapshot snapshot in avisosStream) {
        List<Map<String, dynamic>> avisos = snapshot.docs.map((doc) {
          var aviso = doc.data() as Map<String, dynamic>;
          aviso['id'] = doc.id;
          AppLogger.log('Aviso encontrado: $aviso', prefix: 'AVISOS:');
          return aviso;
        }).toList();
        yield avisos;
      }
    } catch (e) {
      AppLogger.log('Error al obtener avisos del alumno: $e', prefix: 'AVISOS:');
      if (e.toString().contains('The query requires an index')) {
        AppLogger.log('Se requiere un índice compuesto. Por favor, crea el índice siguiendo el enlace proporcionado en el mensaje de error.', prefix: 'AVISOS:');
      }
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getAvisosGenerales(String qrAlumno) async* {
    try {
      AppLogger.log('Obteniendo avisos generales para el alumno con QR: $qrAlumno', prefix: 'AVISOS:');

      String schoolId = await getSchoolIdForCurrentUser();

      Stream<QuerySnapshot> avisosStream = _db
          .collection('colegios')
          .doc(schoolId)
          .collection('avisos')
          .orderBy('fechaPublicacion', descending: true)
          .snapshots();

      await for (QuerySnapshot snapshot in avisosStream) {
        List<Map<String, dynamic>> avisos = snapshot.docs.map((doc) {
          var aviso = doc.data() as Map<String, dynamic>;
          aviso['id'] = doc.id;
          AppLogger.log('Aviso general encontrado: $aviso', prefix: 'AVISOS:');
          return aviso;
        }).toList();
        yield avisos;
      }
    } catch (e) {
      AppLogger.log('Error al obtener avisos generales: $e', prefix: 'AVISOS:');
      throw e;
    }
  }

}
