import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multiinventario/models/notificacion.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final bool inicializado = false;

  Future<void> initialize() async {
    if (inicializado) return;

    const initAndroidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: initAndroidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> mostrarNotificacion(
      {required String titulo, required String contenido}) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stock_alert_channel',
      'Stock Bajo',
      channelDescription: 'Notificaciones de alerta de stock bajo',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(contenido),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, titulo, contenido, notificationDetails);

    await Notificacion.crearNotificacion(Notificacion(
      titulo: titulo,
      contenido: contenido,
      fecha: DateTime.now().toIso8601String(),
    ));
  }
}
