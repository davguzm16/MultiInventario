import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Unidad {
  late int idUnidad;
  late String tipoUnidad;

  Unidad({
    required this.idUnidad,
    required this.tipoUnidad,
  });

  static Future<void> crearUnidadesPorDefecto() async {
    if (await DatabaseController.tableHasData("Unidades")) return;

    List<String> unidades = ["kg", "l", "ud", "m"];

    try {
      final db = await DatabaseController().database;
      for (String unidad in unidades) {
        await db.rawInsert(
          'INSERT INTO Unidades (tipoUnidad) VALUES (?)',
          [unidad],
        );
      }
    } catch (e) {
      debugPrint('Error al insertar unidades predeterminadas: ${e.toString()}');
    }
  }

  static Future<List<Unidad>> obtenerUnidades() async {
    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result =
          await db.rawQuery('SELECT * FROM Unidades');

      List<Unidad> unidades = [];

      for (var map in result) {
        unidades.add(Unidad(
          idUnidad: map['idUnidad'],
          tipoUnidad: map['tipoUnidad'],
        ));
      }

      return unidades;
    } catch (e) {
      debugPrint('Error al obtener unidades: ${e.toString()}');
      return [];
    }
  }

  static Future<Unidad?> obtenerUnidadPorId(int idUnidad) async {
    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM Unidades WHERE idUnidad = ?',
        [idUnidad],
      );

      if (result.isNotEmpty) {
        return Unidad(
          idUnidad: result.first['idUnidad'],
          tipoUnidad: result.first['tipoUnidad'],
        );
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener unidad: ${e.toString()}');
      return null;
    }
  }
}
