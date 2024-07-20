import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../service/firestore_service.dart';
import '../service/auth_service.dart';
import '../utils/logger.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Obtiene el usuario actual
  Future<AppUser> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        AppUser user = await _firestoreService.getUser(firebaseUser.uid);
        return user;
      } catch (e) {
        AppLogger.log('Error al cargar datos del usuario: $e');
        throw Exception('Error al cargar datos del usuario');
      }
    } else {
      AppLogger.log('No hay usuario autenticado');
      throw Exception('No hay usuario autenticado');
    }
  }

  // Guarda un nuevo código QR para el usuario actual
  Future<void> guardarCodigoQR(String qrCode) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _firestoreService.guardarCodigoQR(firebaseUser.uid, qrCode);
        AppLogger.log('Código QR guardado con éxito para el usuario: ${firebaseUser.uid}');
      } catch (e) {
        AppLogger.log('Error al guardar el código QR: $e');
        throw e;
      }
    } else {
      AppLogger.log('Usuario no autenticado');
      throw Exception('Usuario no autenticado');
    }
  }

  // Agrega un alumno a un grupo específico
  Future<void> agregarAlumnoAGrupo(String qr, String grupo, String nombreAlumno) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _firestoreService.agregarAlumnoAGrupo(qr, grupo, nombreAlumno);
        AppLogger.log('Alumno agregado con éxito: $nombreAlumno');
      } catch (e) {
        AppLogger.log('Error al agregar alumno: $e');
        throw e;
      }
    } else {
      AppLogger.log('Usuario no autenticado');
      throw Exception('Usuario no autenticado');
    }
  }

  // Actualiza el perfil del usuario
  Future<void> updateUserProfile({
    required String name,
    required String school,
    required List<String> codigoQR,
  }) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _authService.updateUserProfile(
          firebaseUser.uid,
          {
            'name': name,
            'school': school,
            'codigoQR': codigoQR,
          },
        );
        AppLogger.log('Perfil actualizado con éxito para el usuario: ${firebaseUser.uid}', prefix: 'USER_CONTROLLER:');
      } catch (e) {
        AppLogger.log('Error al actualizar el perfil: $e', prefix: 'USER_CONTROLLER:');
        throw e;
      }
    } else {
      AppLogger.log('Usuario no autenticado', prefix: 'USER_CONTROLLER:');
      throw Exception('Usuario no autenticado');
    }
  }

  // Elimina un código QR específico del usuario
  Future<void> deleteQRCode(String qrCodeToDelete) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        AppUser currentUser = await getCurrentUser();
        List<String> updatedQRCodes = currentUser.codigoQR.where((qr) => qr != qrCodeToDelete).toList();

        await updateUserProfile(
          name: currentUser.name,
          school: currentUser.school,
          codigoQR: updatedQRCodes,
        );

        AppLogger.log('Código QR eliminado con éxito', prefix: 'USER_CONTROLLER:');
      } catch (e) {
        AppLogger.log('Error al eliminar el código QR: $e', prefix: 'USER_CONTROLLER:');
        throw e;
      }
    } else {
      AppLogger.log('Usuario no autenticado', prefix: 'USER_CONTROLLER:');
      throw Exception('Usuario no autenticado');
    }
  }
}