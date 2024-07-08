import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _serverKey = 'AAAAviCy8tc:APA91bEzBlpicFdg2R-WycoLHEdcazJyeHfpRTyFc6U_kLvWplhb24ESUX95wj-YF24CWHvAXGF7X75C-k275g9qwvtCm_JNx7QP1l6xljYuP79KmLaeqpJRwznzMG7wpxTxMuSev7ij';

  Future<NotificationService> init() async {
    AppLogger.log('Iniciando NotificationService', prefix: 'NOTIFICACION:');
    await inicializarNotificaciones();
    _configurarManejadorNotificaciones();
    AppLogger.log('NotificationService inicializado', prefix: 'NOTIFICACION:');
    return this;
  }

  Future<void> inicializarNotificaciones() async {
    AppLogger.log('Solicitando permisos de notificación', prefix: 'NOTIFICACION:');
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.log('Permisos de notificación concedidos', prefix: 'NOTIFICACION:');
      String? token = await obtenerTokenFCM();
      if (token != null) {
        await actualizarTokenFCM(token);
      } else {
        AppLogger.log('No se pudo obtener el token FCM', prefix: 'ERROR:');
      }
      _firebaseMessaging.onTokenRefresh.listen(actualizarTokenFCM);
    } else {
      AppLogger.log('Permisos de notificación denegados', prefix: 'ADVERTENCIA:');
    }
  }

  void _configurarManejadorNotificaciones() {
    AppLogger.log('Configurando manejadores de notificaciones', prefix: 'NOTIFICACION:');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.log('Notificación recibida en primer plano', prefix: 'NOTIFICACION:');
      _mostrarNotificacion(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.log('Notificación abierta desde la app', prefix: 'NOTIFICACION:');
      _mostrarNotificacion(message);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _mostrarNotificacion(RemoteMessage message) {
    AppLogger.log('Mostrando notificación: ${message.messageId}', prefix: 'NOTIFICACION:');
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alertas_importantes',
        title: message.notification?.title ?? 'Nueva alerta',
        body: message.notification?.body ?? 'Tienes una nueva notificación importante',
      ),
    );
  }

  Future<String?> obtenerTokenFCM() async {
    AppLogger.log('Obteniendo token FCM', prefix: 'NOTIFICACION:');
    return await _firebaseMessaging.getToken();
  }

  Future<void> actualizarTokenFCM(String token) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        AppLogger.log('Actualizando token FCM para usuario: ${user.uid}', prefix: 'NOTIFICACION:');
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData['role'] == 'padre') {
            String? currentToken = userData['fcmToken'];
            if (currentToken != token) {
              await _firestore.collection('users').doc(user.uid).set({
                'fcmToken': token,
              }, SetOptions(merge: true));
              AppLogger.log('Token FCM actualizado para padre: ${user.uid}', prefix: 'NOTIFICACION:');
            } else {
              AppLogger.log('Token FCM no necesita actualización para padre: ${user.uid}', prefix: 'NOTIFICACION:');
            }
          } else {
            AppLogger.log('Usuario no es padre: ${user.uid}', prefix: 'ADVERTENCIA:');
          }
        } else {
          AppLogger.log('Usuario no existe: ${user.uid}', prefix: 'ERROR:');
        }
      } catch (e) {
        AppLogger.log('Error al actualizar el token FCM: $e', prefix: 'ERROR:');
      }
    } else {
      AppLogger.log('No hay usuario autenticado', prefix: 'ERROR:');
    }
  }

  Future<void> enviarNotificacionPorQR({required String qrCode, required String titulo, required String cuerpo}) async {
    try {
      AppLogger.log('Enviando notificación por QR: $qrCode', prefix: 'NOTIFICACION:');
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('codigoQR', arrayContains: qrCode)
          .where('role', isEqualTo: 'padre')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.log('No se encontró padre para el QR: $qrCode', prefix: 'ADVERTENCIA:');
        return;
      }

      DocumentSnapshot padreDoc = querySnapshot.docs.first;
      String? tokenDestinatario = padreDoc.get('fcmToken');

      if (tokenDestinatario == null) {
        AppLogger.log('No se encontró el token FCM del padre', prefix: 'ERROR:');
        return;
      }

      final String url = 'https://fcm.googleapis.com/fcm/send';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      final Map<String, dynamic> body = {
        'notification': {
          'title': titulo,
          'body': cuerpo,
        },
        'to': tokenDestinatario,
      };

      AppLogger.log('Enviando solicitud HTTP para notificación', prefix: 'NOTIFICACION:');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        AppLogger.log('Notificación enviada correctamente al padre: ${padreDoc.id}', prefix: 'NOTIFICACION:');
      } else {
        AppLogger.log('Error al enviar la notificación. Código de estado: ${response.statusCode}', prefix: 'ERROR:');
        AppLogger.log('Respuesta del servidor: ${response.body}', prefix: 'ERROR:');
      }
    } catch (e) {
      AppLogger.log('Error al enviar notificación: $e', prefix: 'ERROR:');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.log('Notificación recibida en segundo plano: ${message.messageId}', prefix: 'NOTIFICACION:');
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'alertas_importantes',
      title: message.notification?.title ?? 'Nueva alerta en segundo plano',
      body: message.notification?.body ?? 'Tienes una notificación importante que requiere tu atención',
    ),
  );
}
