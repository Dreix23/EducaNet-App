/*
import 'package:flutter/material.dart';
import 'package:instantpulse/controllers/partners_home_controller.dart';
import 'package:instantpulse/dialogs/notification_permission.dart';
import 'package:instantpulse/utils/logger.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final PartnersHomeController controller;
  final bool isControllerInitialized;
  final VoidCallback updateState;

  CustomFloatingActionButton({
    required this.controller,
    required this.isControllerInitialized,
    required this.updateState,
  });

  @override
  Widget build(BuildContext context) {
    return controller.hasPermission
        ? permissionGrantedButton(
        isControllerInitialized, controller, updateState)
        : permissionRequiredButton(
        context, isControllerInitialized, controller, updateState);
  }

  Widget permissionGrantedButton(bool isControllerInitialized,
      PartnersHomeController controller, VoidCallback updateState) {
    if (!isControllerInitialized) {
      return SizedBox();
    }
    return FloatingActionButton(
      onPressed: () async {
        AppLogger.log("Permission Granted Button Pressed");
        await controller.toggleNotificationListener();
        updateState();
      },
      backgroundColor: Colors.white, // Cambiado a blanco
      child: Icon(
        controller.isListening ? Icons.pause : Icons.play_arrow,
        size: 30, // Icono más grande
        color: controller.isListening ? Colors.pink : Colors.purple, // Fucsia para pausa, verde para play
      ),
    );
  }

  Widget permissionRequiredButton(BuildContext context,
      bool isControllerInitialized, PartnersHomeController controller,
      VoidCallback updateState) {
    if (!isControllerInitialized) {
      return SizedBox();
    }
    return FloatingActionButton(
      onPressed: () async {
        AppLogger.log("Permission Required Button Pressed");
        final result = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => NotificationPermissionDialog(),
        );
        if (result == true) {
          await controller.checkAndRequestPermission();
        }
        updateState();
      },
      backgroundColor: Colors.white, // Cambiado a blanco
      child: Icon(
        Icons.play_arrow,
        size: 30, // Icono más grande
        color: Colors.purple, // Verde para play
      ),
    );
  }
}

 */
