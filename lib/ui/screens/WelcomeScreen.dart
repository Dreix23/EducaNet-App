import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/screen_util.dart';
import 'AuthenticationScreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfff7f6fb),
      body: SafeArea(
        child: ScreenUtil(
          color: Colors.transparent,
          child: _buildContent(),
          screenType: ScreenType.column,
          maxWidth: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: _buildColumnWidgets(),
              ),
            ],
          );
        } else {
          return _buildColumnWidgets();
        }
      },
    );
  }

  Widget _buildColumnWidgets() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            if (MediaQuery.of(context).size.width <= 600)
              Flexible(
                flex: 2,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 60), // Espacio reducido
                  Text(
                    "Empecemos",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nunca es mejor momento que ahora para empezar.",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 38),
                  _buildButton('profesor', false),
                  SizedBox(height: 22),
                  _buildButton('padre', true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String text, bool allowRegister) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = screenWidth > 600 ? 400 : double.infinity;
    final EdgeInsets padding =
    screenWidth > 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 20);

    Color backgroundColor = text == 'padre' ? Colors.white : Colors.cyan;
    Color textColor = text == 'padre' ? Colors.cyan : Colors.white;

    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          width: buttonWidth,
          child: CustomButton(
            text: text,
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AuthenticationScreen(
                      role: text, allowRegister: allowRegister)));
            },
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      ),
    );
  }
}
