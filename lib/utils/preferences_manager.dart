import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger.dart';

class PreferencesManager {
  static const String processedCodesKey = 'processed_codes';
  static const String lastNotificationDateKey = 'last_notification_date';
  static const String notificationStatusKey = 'notification_status';

  static Future<Map<String, Map<String, Map<String, bool>>>> loadProcessedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? processedData = prefs.getString(processedCodesKey);
    if (processedData != null) {
      Map<String, dynamic> tempMap = json.decode(processedData);
      Map<String, Map<String, Map<String, bool>>> processedCodes = tempMap.map((key, value) {
        Map<String, Map<String, bool>> innerMap = (value as Map).map((innerKey, innerValue) {
          Map<String, bool> innerInnerMap = (innerValue as Map).cast<String, bool>();
          return MapEntry(innerKey as String, innerInnerMap);
        });
        return MapEntry(key, innerMap);
      });
      return processedCodes;
    }
    return {};
  }

  static Future<void> saveProcessedCodes(Map<String, Map<String, Map<String, bool>>> processedCodes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(processedCodes);
    await prefs.setString(processedCodesKey, encodedData);
    AppLogger.log("Guardando códigos procesados: $encodedData");
  }

  // Método para verificar si una notificación específica ya fue enviada
  static Future<bool> wasNotificationSent(String notificationKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, bool> notificationsStatus = _loadNotificationStatus(prefs);
    return notificationsStatus[notificationKey] ?? false;
  }

  // Método para marcar una notificación como enviada
  static Future<void> markNotificationAsSent(String notificationKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, bool> notificationsStatus = _loadNotificationStatus(prefs);
    notificationsStatus[notificationKey] = true;
    await prefs.setString(notificationStatusKey, json.encode(notificationsStatus));
  }

  // Método privado para cargar el estado de las notificaciones
  static Map<String, bool> _loadNotificationStatus(SharedPreferences prefs) {
    String? statusData = prefs.getString(notificationStatusKey);
    if (statusData != null) {
      return Map<String, bool>.from(json.decode(statusData));
    }
    return {};
  }
}
