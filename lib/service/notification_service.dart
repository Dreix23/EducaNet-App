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
    await inicializarNotificaciones();
    _configurarManejadorNotificaciones();
    return this;
  }

  Future<void> inicializarNotificaciones() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await obtenerTokenFCM();
      if (token != null) {
        await actualizarTokenFCM(token);
      } else {
        AppLogger.log('No se pudo obtener el token FCM', prefix: 'ERROR:');
      }
      _firebaseMessaging.onTokenRefresh.listen(actualizarTokenFCM);
    }
  }

  void _configurarManejadorNotificaciones() {
    FirebaseMessaging.onMessage.listen(_mostrarNotificacion);
    FirebaseMessaging.onMessageOpenedApp.listen(_mostrarNotificacion);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _mostrarNotificacion(RemoteMessage message) {
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
    return await _firebaseMessaging.getToken();
  }

  Future<void> actualizarTokenFCM(String token) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData['role'] == 'padre') {
            String? currentToken = userData['fcmToken'];
            if (currentToken != token) {
              await _firestore.collection('users').doc(user.uid).set({
                'fcmToken': token,
              }, SetOptions(merge: true));
              AppLogger.log('Token FCM actualizado', prefix: 'INFO:');
            } else {
              AppLogger.log('Token FCM no necesita actualización', prefix: 'INFO:');
            }
          }
        }
      } catch (e) {
        AppLogger.log('Error al actualizar el token FCM: $e', prefix: 'ERROR:');
      }
    }
  }

  Future<void> enviarNotificacionPorQR({required String qrCode, required String titulo, required String cuerpo}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('codigoQR', arrayContains: qrCode)
          .where('role', isEqualTo: 'padre')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.log('No se encontró un padre con el código QR proporcionado', prefix: 'INFO:');
        return;
      }

      DocumentSnapshot padreDoc = querySnapshot.docs.first;
      String? tokenDestinatario = padreDoc.get('fcmToken');

      if (tokenDestinatario == null) {
        AppLogger.log('El padre no tiene un token FCM registrado', prefix: 'INFO:');
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

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        AppLogger.log('Notificación enviada correctamente', prefix: 'INFO:');
      } else {
        AppLogger.log('Error al enviar la notificación. Código de estado: ${response.statusCode}', prefix: 'ERROR:');
      }
    } catch (e) {
      AppLogger.log('Error al enviar notificación: $e', prefix: 'ERROR:');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'alertas_importantes',
      title: message.notification?.title ?? 'Nueva alerta en segundo plano',
      body: message.notification?.body ?? 'Tienes una notificación importante que requiere tu atención',
    ),
  );
}
