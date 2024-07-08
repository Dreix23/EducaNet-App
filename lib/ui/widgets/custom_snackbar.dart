import 'package:flutter/material.dart';

enum SnackbarState { error, completed, pending }

class CustomSnackbar extends StatelessWidget {
  final String message;
  final SnackbarState state;
  final bool isTop;

  CustomSnackbar({
    required this.message,
    required this.state,
    this.isTop = true,
  });

  IconData _getIcon() {
    switch (state) {
      case SnackbarState.error:
        return Icons.error;
      case SnackbarState.completed:
        return Icons.check_circle;
      case SnackbarState.pending:
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  Color _getColor() {
    switch (state) {
      case SnackbarState.error:
        return Colors.red;
      case SnackbarState.completed:
        return Colors.green;
      case SnackbarState.pending:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isTop ? 84.0 : null,
      bottom: isTop ? null : 100.0,
      left: 0,
      right: 0,
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: Material(
          color: _getColor(),
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(), color: Colors.white),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, String message, SnackbarState state, {bool isTop = true}) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => CustomSnackbar(
        message: message,
        state: state,
        isTop: isTop,
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
