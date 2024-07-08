import 'package:flutter/material.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class CustomSnackBar {
  static void showInfo(BuildContext context, String message) {
    AnimatedSnackBar.material(
      message,
      type: AnimatedSnackBarType.info,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  static void showError(BuildContext context, String message) {
    AnimatedSnackBar.material(
      message,
      type: AnimatedSnackBarType.error,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  static void showSuccess(BuildContext context, String message) {
    AnimatedSnackBar.material(
      message,
      type: AnimatedSnackBarType.success,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  static void showWarning(BuildContext context, String message) {
    AnimatedSnackBar.material(
      message,
      type: AnimatedSnackBarType.warning,
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      duration: const Duration(seconds: 2),
    ).show(context);
  }
}
