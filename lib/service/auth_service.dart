import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../utils/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registra un nuevo usuario
  Future<UserCredential> registerUser(String email, String password, String name, String role, String school) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'school': school,
        'email': email,
        'role': role,
        'codigoQR': [],
      });
    }
    return userCredential;
  }

  // Inicia sesión de un usuario existente
  Future<UserCredential> loginUser(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Obtiene el rol del usuario
  Future<String?> getUserRole(User? user) async {
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (snapshot.data() is Map<String, dynamic>) {
      return (snapshot.data() as Map<String, dynamic>)['role'];
    }
    return null;
  }

  // Cierra la sesión del usuario actual
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Envía un correo para restablecer la contraseña
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Obtiene los datos de un usuario específico
  Future<AppUser> getUser(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return AppUser.fromMap(snapshot.data() as Map<String, dynamic>, uid);
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      AppLogger.log('Error al obtener usuario: $e', prefix: 'AUTH_SERVICE:');
      throw Exception('Error al obtener usuario');
    }
  }

  // Actualiza el perfil de un usuario
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      AppLogger.log('Error al actualizar perfil: $e', prefix: 'AUTH_SERVICE:');
      throw Exception('Error al actualizar perfil');
    }
  }
}