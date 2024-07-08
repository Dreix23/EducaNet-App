import '../../controllers/register_controller.dart';
import 'package:flutter/material.dart';
import '../../ui/widgets/custom_button.dart';
import '../../ui/widgets/custom_text_field.dart';

class RegisterComponent extends StatefulWidget {
  final String role;

  RegisterComponent({Key? key, required this.role}) : super(key: key);

  @override
  _RegisterComponentState createState() => _RegisterComponentState();
}

class _RegisterComponentState extends State<RegisterComponent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RegisterController _registerController = RegisterController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _registerController.register(
        nameController.text,
        schoolController.text,
        emailController.text,
        passwordController.text,
        widget.role,
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
              controller: nameController,
              label: 'Nombre',
              capitalizeWords: true,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: schoolController,
              label: 'Codigo del Colegio',
              uppercase: true,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              label: 'Correo electrónico',
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              label: 'Contraseña',
              isPassword: true,
              icon: Icons.visibility_off,
            ),
            SizedBox(height: 30),
            CustomButton(
              text: 'Empezar',
              onPressed: _registerUser,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
