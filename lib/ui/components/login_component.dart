import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import '../../dialogs/reset_password_dialog.dart';
import '../../ui/widgets/custom_button.dart';
import '../../ui/widgets/custom_text_field.dart';

class LoginComponent extends StatefulWidget {
  LoginComponent({Key? key}) : super(key: key);

  @override
  _LoginComponentState createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _loginController.login(
        emailController.text,
        passwordController.text,
        context,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: emailController,
              label: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              label: 'Contraseña',
              isPassword: true,
            ),
            SizedBox(height: 30),
            CustomButton(
              text: 'Iniciar sesión',
              onPressed: _loginUser,
              isLoading: _isLoading,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ResetPasswordDialog(loginController: _loginController);
                  },
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
