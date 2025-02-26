import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Notificacion {
  int? idNotificacion;
  String titulo;
  String contenido;
  String fecha;

  // Constructor
  Notificacion({
    this.idNotificacion,
    required this.titulo,
    required this.contenido,
    required this.fecha,
  });

  // Método para crear una nueva notificación
  static Future<bool> crearNotificacion(Notificacion notificacion) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert(
        'INSERT INTO Notificaciones (titulo, contenido, fecha) VALUES (?, ?, ?)',
        [notificacion.titulo, notificacion.contenido, notificacion.fecha],
      );

      return result > 0;
    } catch (e) {
      debugPrint('Error al insertar notificación: ${e.toString()}');
    }

    return false;
  }

  // Método para obtener todas las notificaciones
  static Future<List<Notificacion>> obtenerNotificaciones() async {
    List<Notificacion> notificaciones = [];

    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result =
          await db.rawQuery('SELECT * FROM Notificaciones ORDER BY fecha DESC');

      for (var map in result) {
        notificaciones.add(Notificacion(
          idNotificacion: map['idNotificacion'],
          titulo: map['titulo'],
          contenido: map['contenido'],
          fecha: map['fecha'],
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener notificaciones: ${e.toString()}');
    }

    return notificaciones;
  }

  // Método para eliminar una notificación por ID
  static Future<bool> eliminarNotificacion(int idNotificacion) async {
    late int result;

    try {
      final db = await DatabaseController().database;
      result = await db.rawDelete(
        'DELETE FROM Notificaciones WHERE idNotificacion = ?',
        [idNotificacion],
      );
    } catch (e) {
      debugPrint('Error al eliminar notificación: ${e.toString()}');
      return false;
    }

    return result > 0;
  }

  // Método para limpiar todo el historial de notificaciones
  static Future<bool> limpiarHistorial() async {
    late int result;

    try {
      final db = await DatabaseController().database;
      result = await db.rawDelete('DELETE FROM Notificaciones');
    } catch (e) {
      debugPrint('Error al limpiar historial: ${e.toString()}');
      return false;
    }

    return result > 0;
  }

  @override
  String toString() {
    return "Notificacion = {idNotificacion: $idNotificacion, titulo: $titulo, contenido: $contenido, fecha: $fecha}";
  }
}
