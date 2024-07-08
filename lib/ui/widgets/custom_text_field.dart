import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final IconData? icon;
  final String prefixText;
  final TextInputType keyboardType;
  final ValueNotifier<Color>? borderColorNotifier;
  final bool capitalizeWords;
  final bool uppercase;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.icon,
    this.prefixText = '',
    this.keyboardType = TextInputType.text,
    this.borderColorNotifier,
    this.capitalizeWords = false,
    this.uppercase = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: widget.borderColorNotifier ?? ValueNotifier(Colors.black12),
      builder: (context, color, child) {
        return TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          textCapitalization: widget.capitalizeWords ? TextCapitalization.words : TextCapitalization.none,
          inputFormatters: [
            if (widget.uppercase)
              TextInputFormatter.withFunction((oldValue, newValue) => TextEditingValue(
                text: newValue.text.toUpperCase(),
                selection: newValue.selection,
              )),
          ],
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: Colors.grey),
            prefix: widget.prefixText.isNotEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.prefixText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
              color: color,
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : (widget.icon != null ? Icon(widget.icon, color: color) : null),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
