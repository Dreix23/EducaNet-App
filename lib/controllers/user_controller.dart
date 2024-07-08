import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../service/firestore_service.dart';
import '../service/auth_service.dart';
import '../utils/logger.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Obtener el usuario actual
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

  // Guardar el código QR en Firestore
  Future<void> guardarCodigoQR(String qrCode) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        // Llamada al método de FirestoreService para guardar el código QR
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

  // Método para agregar un alumno a un grupo
  Future<void> agregarAlumnoAGrupo(String qr, String grupo, String nombreAlumno) async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        // Llamada al método de FirestoreService para agregar el alumno
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

  // Método para actualizar el perfil del usuario
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
}
