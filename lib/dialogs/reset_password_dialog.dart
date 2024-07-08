import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';
import '../ui/widgets/screen_util.dart';

class ResetPasswordDialog extends StatefulWidget {
  final LoginController loginController;

  ResetPasswordDialog({Key? key, required this.loginController}) : super(key: key);

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  late TextEditingController _emailController;
  late FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _sendResetEmail() async {
    try {
      await widget.loginController.resetPassword(_emailController.text, context);
      Navigator.of(context).pop(); // Cierra el diálogo si el correo se envió correctamente
    } catch (error) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ScreenUtil(
        color: Colors.transparent,
        screenType: ScreenType.column,
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 60),
              Text(
                "Restablecer Contraseña",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.lightBlue),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hintText: "Correo Electrónico",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: _emailFocusNode.hasFocus ? Colors.lightBlue : Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _sendResetEmail,
                child: Text(
                  "Enviar",
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -40,
          child: CircleAvatar(
            backgroundColor: Colors.lightBlue,
            radius: 40,
            child: Icon(Icons.vpn_key, size: 40, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
