import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    final pluginAndroid = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (pluginAndroid != null) {
      final notificationGranted = await pluginAndroid.requestNotificationsPermission();
      if (notificationGranted != true) {
        debugPrint("Permiso denegado para notificaciones");
      }

      // Solicitar permiso de alarmas exactas (Android 12+)
      final exactAlarmGranted = await pluginAndroid.requestExactAlarmsPermission();
      if (exactAlarmGranted != true) {
        debugPrint("Permiso denegado para alarmas exactas. Las notificaciones pueden no ser puntuales.");
      } else {
        debugPrint("Permiso de alarmas exactas concedido");
      }
    }
  }

  Future<void> programarNotificacion({
    required DateTime fechaHora,
    required String titulo,
    required String descripcion,
    required int id,
  }) async {
    debugPrint("Programando notificación:");
    debugPrint("   ID: $id");
    debugPrint("   Título: $titulo");
    debugPrint("   Fecha/Hora: $fechaHora");
    debugPrint("   Ahora: ${DateTime.now()}");
    
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        channelDescription: 'Canal para recordatorios locales',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        titulo,
        descripcion.isNotEmpty ? descripcion : 'Tienes una tarea pendiente.',
        tz.TZDateTime.from(fechaHora, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Notificación programada exitosamente");
    } catch (e) {
      debugPrint("Error programando notificación: $e");
    }
  }

  Future<void> cancelarNotificacion(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint("Error cancelando notificación: $e");
    }
  }

  int generarNotificationId() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
