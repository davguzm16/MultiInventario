import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Lote {
  int? idLote;
  int idProducto;
  int cantidadAsignada;
  int? cantidadPerdida;
  double precioCompra;
  DateTime? fechaCaducidad;

  // Constructor
  Lote({
    this.idLote,
    required this.idProducto,
    required this.cantidadAsignada,
    this.cantidadPerdida,
    required this.precioCompra,
    this.fechaCaducidad,
  });

  static Future<bool> crearLote(Lote lote) async {
    try {
      debugPrint("Iniciando creación de lote para producto ${lote.idProducto}");

      final db = await DatabaseController().database;

      final result = await db.rawQuery(
          'SELECT MAX(idLote) as maxId FROM Lotes WHERE idProducto = ?',
          [lote.idProducto]);

      int nuevoIdLote = (result.first['maxId'] as int? ?? 0) + 1;

      debugPrint("Nuevo idLote calculado: $nuevoIdLote");

      final insertResult = await db.rawInsert(
        '''
      INSERT INTO Lotes (idProducto, idLote, cantidadAsignada, cantidadPerdida, precioCompra, fechaCaducidad)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
        [
          nuevoIdLote,
          lote.idProducto,
          lote.cantidadAsignada,
          lote.cantidadPerdida,
          lote.precioCompra,
          lote.fechaCaducidad?.toIso8601String(),
        ],
      );

      debugPrint("Resultado de inserción: $insertResult");

      return insertResult > 0;
    } catch (e) {
      debugPrint("Error al crear lote: ${e.toString()}");
      return false;
    }
  }

  static Future<List<Lote>> obtenerLotesDeProducto(int? idProducto) async {
    if (idProducto == null || idProducto.isNegative) {
      debugPrint(
          "ID de producto inválido. No se pueden obtener lotes: idProducto=$idProducto");
      return [];
    }

    debugPrint("Obteniendo lotes para producto: $idProducto");

    List<Lote> lotes = [];

    try {
      final db = await DatabaseController().database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT idLote, idProducto, cantidadAsignada, cantidadPerdida, precioCompra, fechaCaducidad
      FROM Lotes
      WHERE idProducto = ?
      ORDER BY idLote ASC
      ''', [idProducto]);

      debugPrint("Cantidad de lotes encontrados: ${result.length}");

      for (var item in result) {
        lotes.add(Lote(
          idLote: item['idLote'] as int,
          idProducto: item['idProducto'] as int,
          cantidadAsignada: item['cantidadAsignada'] as int,
          cantidadPerdida:
              (item['cantidadPerdida'] as int?) ?? 0, // Si es null, asigna 0
          precioCompra: (item['precioCompra'] as num).toDouble(),
          fechaCaducidad: item['fechaCaducidad'] as DateTime?,
        ));
      }

      if (lotes.isEmpty) {
        debugPrint('No se encontraron lotes para el producto $idProducto');
      }
    } catch (e) {
      debugPrint(
          "Error al obtener los lotes del producto $idProducto: ${e.toString()}");
    }

    return lotes;
  }

  static Future<bool> actualizarLote(Lote lote) async {
    try {
      debugPrint(
          "Actualizando lote ${lote.idLote} del producto ${lote.idProducto}");

      final db = await DatabaseController().database;

      int result = await db.rawUpdate(
        '''
      UPDATE Lotes 
      SET cantidadAsignada = ?, cantidadPerdida = ?, precioCompra = ?, fechaCaducidad = ?
      WHERE idLote = ?
      ''',
        [
          lote.cantidadAsignada,
          lote.cantidadPerdida,
          lote.precioCompra,
          lote.fechaCaducidad?.toIso8601String(),
          lote.idLote
        ],
      );

      debugPrint("Filas afectadas por la actualización: $result");

      if (result > 0) {
        debugPrint("Lote ${lote.idLote} actualizado correctamente.");
        return true;
      } else {
        debugPrint("No se encontró el lote ${lote.idLote} para actualizar.");
      }
    } catch (e) {
      debugPrint("Error al actualizar el lote ${lote.idLote}: ${e.toString()}");
    }

    return false;
  }

  static Future<bool> eliminarLote(Lote lote) async {
    try {
      debugPrint(
          "Eliminando lote ${lote.idLote} del producto ${lote.idProducto}");

      final db = await DatabaseController().database;

      int result = await db.rawDelete(
          'DELETE FROM Lotes WHERE idProducto = ? AND idLote = ?',
          [lote.idProducto, lote.idLote]);

      debugPrint("Filas eliminadas: $result");

      return result > 0;
    } catch (e) {
      debugPrint(
          "Error al eliminar lote ${lote.idLote} de producto ${lote.idProducto}: ${e.toString()}");
      return false;
    }
  }
}
