import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../service/firestore_service.dart';
import '../ui/screens/padre/PadreScreen.dart';
import '../ui/screens/profesor/ProfesorScreen.dart';
import '../ui/widgets/custom_snack_bar.dart';
import '../utils/logger.dart';

class RegisterController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> register(String name, String school, String email, String password, String role, BuildContext context) async {
    try {
      UserCredential userCredential = await _authService.registerUser(email, password, name, role, school);

      if (userCredential.user != null) {
        AppLogger.log('Registro exitoso. Usuario: ${userCredential.user?.email}, Rol: $role');
        CustomSnackBar.showSuccess(context, 'Registro exitoso.');

        if (role == 'profesor') {
          await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfesorScreen()));
        } else if (role == 'padre') {
          await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PadreScreen(firestoreService: _firestoreService)));
        } else {
          _showRegistrationError(context, 'Rol no reconocido');
        }
      } else {
        _showRegistrationError(context, 'Error al registrar usuario');
      }
    } catch (e) {
      AppLogger.log('Error en el registro: $e');
      _showRegistrationError(context, 'Error al registrar usuario');
    }
  }

  void _showRegistrationError(BuildContext context, String message) {
    CustomSnackBar.showError(context, message);
  }
}
