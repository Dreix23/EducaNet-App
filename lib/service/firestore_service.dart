import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user.dart';
import '../utils/logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser> getUser(String userId) async {
    try {
      var snap = await _db.collection('users').doc(userId).get();
      if (snap.exists && snap.data() != null) {
        return AppUser.fromMap(snap.data()!, snap.id);
      } else {
        AppLogger.log('Usuario no encontrado: $userId');
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      AppLogger.log('Error al obtener usuario: $e');
      throw e;
    }
  }

  Future<String> getSchoolIdForCurrentUser() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData['role'] == 'profesor') {
          return userData['school'];
        } else {
          throw Exception('El usuario no tiene el rol de profesor');
        }
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      AppLogger.log('Error al obtener schoolId: $e');
      throw e;
    }
  }

  Future<void> registrarAsistencia(String qrCode, bool isEntrance) async {
    DateTime ahora = DateTime.now();
    String fechaDocId = DateFormat('yyyy-MM-dd').format(ahora);

    try {
      String schoolId = await getSchoolIdForCurrentUser();
      Map<String, String?> grupoYNombre = await _encontrarGrupoDeAlumno(qrCode, schoolId);
      String grupo = grupoYNombre['grupoId'] ?? '';
      String nombreAlumno = grupoYNombre['nombre'] ?? 'Desconocido';

      if (grupo.isEmpty) {
        AppLogger.log('Grupo no encontrado para el alumno: $qrCode');
        throw Exception('Grupo no encontrado para el alumno');
      }

      Map<String, dynamic> asistenciaData = {
        qrCode: {
          'nombre': nombreAlumno,
          if (isEntrance) 'entrada': ahora.toIso8601String(),
          if (!isEntrance) 'salida': ahora.toIso8601String(),
        }
      };

      await _db.collection('colegios').doc(schoolId).collection('asistencias').doc(fechaDocId).set({grupo: asistenciaData}, SetOptions(merge: true));
      AppLogger.log('Asistencia registrada exitosamente para $qrCode ($nombreAlumno) en grupo $grupo, fecha $fechaDocId');
    } catch (e) {
      AppLogger.log('Error al registrar asistencia: $e');
      throw e;
    }
  }

  Future<Map<String, String?>> _encontrarGrupoDeAlumno(String qrCode, String schoolId) async {
    try {
      QuerySnapshot grupos = await _db.collection('colegios').doc(schoolId).collection('alumnos').get();
      for (var grupoDoc in grupos.docs) {
        var data = grupoDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          for (var alumnoKey in data.keys) {
            var alumnoData = data[alumnoKey] as Map<String, dynamic>;
            if (alumnoData['QR'] == qrCode) {
              return {
                'grupoId': grupoDoc.id,
                'nombre': alumnoData['NOM_ALUMNO'] ?? 'Desconocido'
              };
            }
          }
        }
      }
      AppLogger.log('Alumno no encontrado con QR: $qrCode');
      return {'grupoId': '', 'nombre': ''};
    } catch (e) {
      AppLogger.log('Error al encontrar grupo de alumno: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getAsistenciasPorGrupoYFecha(String grupoId, DateTime fecha) async {
    String fechaFormato = DateFormat('yyyy-MM-dd').format(fecha);
    AppLogger.log("Consultando asistencias para grupo $grupoId en fecha $fechaFormato");

    try {
      String schoolId = await getSchoolIdForCurrentUser();
      DocumentSnapshot docSnapshot = await _db.collection('colegios').doc(schoolId).collection('asistencias').doc(fechaFormato).get();

      if (!docSnapshot.exists || docSnapshot.data() == null || !(docSnapshot.data() as Map<String, dynamic>).containsKey(grupoId)) {
        AppLogger.log("No se encontraron datos de asistencia para grupo $grupoId en fecha $fechaFormato");
        return [];
      }

      var grupoData = (docSnapshot.data() as Map<String, dynamic>)[grupoId];
      if (grupoData is Map<String, dynamic>) {
        List<Map<String, dynamic>> asistencias = [];
        grupoData.forEach((codigoEstudiante, infoAsistencia) {
          AppLogger.log("Encontrada asistencia: $codigoEstudiante - $infoAsistencia");
          asistencias.add({
            "codigo": codigoEstudiante,
            "info": infoAsistencia,
          });
        });
        return asistencias;
      } else {
        AppLogger.log("Los datos recuperados no tienen el formato esperado para grupo $grupoId en fecha $fechaFormato");
        return [];
      }
    } catch (e) {
      AppLogger.log('Error al obtener asistencias: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getListaCompletaAlumnos(String grupoId) async {
    try {
      String schoolId = await getSchoolIdForCurrentUser();
      DocumentSnapshot grupoDoc = await _db.collection('colegios').doc(schoolId).collection('alumnos').doc(grupoId).get();
      if (grupoDoc.exists) {
        var data = grupoDoc.data() as Map<String, dynamic>?;
        return data?.values.map((alumno) {
          Map<String, dynamic> alumnoMap = alumno as Map<String, dynamic>;
          return {
            'QR': alumnoMap['QR'] as String,
            'nombre': alumnoMap['NOM_ALUMNO'] as String,
          };
        }).toList() ?? [];
      } else {
        AppLogger.log('Grupo no encontrado: $grupoId');
        return [];
      }
    } catch (e) {
      AppLogger.log('Error al obtener lista completa de alumnos: $e');
      throw e;
    }
  }

  Future<void> guardarCodigoQR(String userId, String qrCode) async {
    try {
      Map<String, dynamic> data = {
        'codigoQR': FieldValue.arrayUnion([qrCode]),
      };

      await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
      AppLogger.log('Código QR guardado con éxito para el usuario: $userId');
    } catch (e) {
      AppLogger.log('Error al guardar el código QR: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getAsistenciasPorPadreYFecha(String padreId, DateTime fecha) {
    String fechaFormato = DateFormat('yyyy-MM-dd').format(fecha);

    return _db.collection('users').doc(padreId).snapshots().switchMap((userDoc) {
      if (!userDoc.exists) {
        AppLogger.log('Usuario no encontrado: $padreId');
        return Stream.value(<Map<String, dynamic>>[]);
      }

      var userData = userDoc.data();
      String schoolId = userData?['school'];
      List<String> codigosQR = List.from(userData?['codigoQR'] ?? []);

      return _db.collection('colegios').doc(schoolId).collection('asistencias').doc(fechaFormato)
          .snapshots().map((asistenciasDoc) {
        List<Map<String, dynamic>> asistencias = [];

        if (asistenciasDoc.exists) {
          var asistenciasData = asistenciasDoc.data();
          asistenciasData?.forEach((grupoId, grupoData) {
            if (grupoData is Map<String, dynamic>) {
              grupoData.forEach((codigoEstudiante, infoAsistencia) {
                if (codigosQR.contains(codigoEstudiante)) {
                  asistencias.add({
                    "codigo": codigoEstudiante,
                    "info": infoAsistencia,
                  });
                }
              });
            }
          });
        }

        return asistencias;
      });
    }).handleError((error) {
      AppLogger.log('Error al obtener asistencias para el padre: $error');
      return <Map<String, dynamic>>[];
    });
  }

  Future<void> agregarAlumnoAGrupo(String qr, String grupo, String nombreAlumno) async {
    try {
      String schoolId = await getSchoolIdForCurrentUser();

      var grupoRef = _db.collection('colegios').doc(schoolId).collection('alumnos').doc(grupo);

      Map<String, dynamic> datosAlumno = {
        'NOM_ALUMNO': nombreAlumno,
        'QR': qr,
      };

      var grupoDoc = await grupoRef.get();

      if (grupoDoc.exists) {
        await grupoRef.update({
          qr: datosAlumno
        });
      } else {
        await grupoRef.set({
          qr: datosAlumno
        });
      }

      AppLogger.log('Alumno agregado con éxito a grupo $grupo: $nombreAlumno');
    } catch (e) {
      AppLogger.log('Error al agregar alumno a grupo $grupo: $e');
      throw e;
    }
  }
}
