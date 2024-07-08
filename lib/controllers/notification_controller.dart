import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../ui/screens/padre/PadreScreen.dart';
import '../utils/logger.dart';

class NotificationController extends GetxController {
  late final NotificationService _notificationService;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.log('Inicializando NotificationController', prefix: 'NOTIFICACION:');
    _notificationService = Get.find<NotificationService>();
    _inicializarNotificaciones();
    _configurarCanales();
  }

  Future<void> _inicializarNotificaciones() async {
    AppLogger.log('Inicializando AwesomeNotifications', prefix: 'NOTIFICACION:');
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alertas_importantes',
          channelName: 'Alertas Importantes',
          channelDescription: 'Notificaciones de alta prioridad para padres',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.red,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
        ),
      ],
    );
    await _solicitarPermisoNotificaciones();
  }

  void _configurarCanales() {
    AppLogger.log('Configurando canales de notificación', prefix: 'NOTIFICACION:');
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    AppLogger.log('Acción de notificación recibida: ${receivedAction.id}', prefix: 'NOTIFICACION:');
    final controller = Get.find<NotificationController>();
    controller.selectedIndex.value = 0;
    Get.to(() => PadreScreen(firestoreService: Get.find()));
  }

  Future<void> _solicitarPermisoNotificaciones() async {
    AppLogger.log('Solicitando permiso para notificaciones', prefix: 'NOTIFICACION:');
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AppLogger.log('Solicitando permiso para enviar notificaciones', prefix: 'NOTIFICACION:');
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        AppLogger.log('Permiso para notificaciones ya concedido', prefix: 'NOTIFICACION:');
      }
    });
  }

  Future<void> actualizarTokenFCM() async {
    AppLogger.log('Actualizando token FCM', prefix: 'NOTIFICACION:');
    String? token = await _notificationService.obtenerTokenFCM();
    if (token != null) {
      await _notificationService.actualizarTokenFCM(token);
    } else {
      AppLogger.log('No se pudo obtener el token FCM para actualizar', prefix: 'ERROR:');
    }
  }

  void mostrarNotificacion(RemoteMessage message) {
    AppLogger.log('Mostrando notificación desde el controlador: ${message.messageId}', prefix: 'NOTIFICACION:');
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alertas_importantes',
        title: message.notification?.title ?? 'Nueva alerta',
        body: message.notification?.body ?? 'Tienes una nueva notificación importante',
      ),
    );
  }
}
