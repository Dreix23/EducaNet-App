import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../service/firestore_service.dart';
import '../ui/screens/padre/PadreScreen.dart';
import '../ui/screens/profesor/ProfesorScreen.dart';
import '../ui/widgets/custom_snack_bar.dart';
import '../utils/logger.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _authService.loginUser(email, password);

      if (userCredential.user != null) {
        String? role = await _authService.getUserRole(userCredential.user);

        if (role != null) {
          AppLogger.log('Usuario con rol: $role');
          if (role == 'profesor') {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfesorScreen()));
          } else if (role == 'padre') {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PadreScreen(firestoreService: _firestoreService)));
          } else {
            AppLogger.log('Rol no reconocido: $role');
            _showLoginError(context);
          }
        } else {
          AppLogger.log('Error: Rol del usuario es nulo');
          _showLoginError(context);
        }
      } else {
        AppLogger.log('Error: UserCredential.user es nulo');
        _showLoginError(context);
      }
    } catch (e) {
      AppLogger.log('Error de Login: $e');
      _showLoginError(context);
    }
  }

  void _showLoginError(BuildContext context) {
    CustomSnackBar.showError(context, 'Error al iniciar sesión. Verifica tus credenciales.');
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _authService.resetPassword(email);
      CustomSnackBar.showSuccess(context, 'Correo de restablecimiento enviado.');
    } catch (e) {
      AppLogger.log('Error al restablecer la contraseña: $e');
      CustomSnackBar.showError(context, 'Error al restablecer contraseña. Intenta de nuevo.');
    }
  }
}
