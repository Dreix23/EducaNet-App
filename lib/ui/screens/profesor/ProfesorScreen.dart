import 'package:flutter/material.dart';

import '../../../controllers/user_controller.dart';
import '../../../dialogs/qrscan_option_dialog.dart';
import '../../../models/user.dart';
import '../../../service/auth_service.dart';
import '../../components/professor_box.dart';
import '../../widgets/custom_app_bar.dart';
import '../WelcomeScreen.dart';

class ProfesorScreen extends StatefulWidget {
  @override
  _ProfesorScreenState createState() => _ProfesorScreenState();
}

class _ProfesorScreenState extends State<ProfesorScreen> {
  String userName = 'Cargando...';
  final UserController _userController = UserController();
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      AppUser user = await _userController.getCurrentUser();
      setState(() {
        userName = user.name;
      });
    } catch (e) {
      setState(() {
        userName = 'Error al cargar';
      });
    }
  }

  void _showQRScanOptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRScanOptionDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        onProfileTap: () {
          // Acción al tocar el icono del perfil
        },
        onLogoutTap: () async {
          // Lógica para manejar el cierre de sesión
          await authService.logout();
          // Navegar al WelcomeScreen
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen()));
        },
      ),
      body: ProfesorBox(
        onQRButtonPressed: _showQRScanOptionDialog,
      ),
    );
  }
}