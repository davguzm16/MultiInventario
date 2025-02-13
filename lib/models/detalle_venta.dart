import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class DetalleVenta {
  int idProducto;
  int idVenta;
  int cantidadProducto;
  double subtotalProducto;
  double? descuentoProducto;

  DetalleVenta({
    required this.idProducto,
    required this.idVenta,
    required this.cantidadProducto,
    required this.subtotalProducto,
    this.descuentoProducto,
  });

  static Future<bool> asignarRelacion(int idVenta, DetalleVenta detalle) async {
    try {
      final db = await DatabaseController().database;
      await db.rawInsert('''
        INSERT INTO DetallesVentas (
          idProducto, idVenta, cantidadProducto, subtotalProducto, descuentoProducto
        ) VALUES (?, ?, ?, ?, ?)
      ''', [
        detalle.idProducto,
        idVenta,
        detalle.cantidadProducto,
        detalle.subtotalProducto,
        detalle.descuentoProducto ?? 0.0,
      ]);

      // Actualizar stock del producto
      await db.rawUpdate('''
        UPDATE Productos SET stockActual = stockActual - ? WHERE idProducto = ?
      ''', [detalle.cantidadProducto, detalle.idProducto]);

      return true;
    } catch (e) {
      debugPrint(
          "Error al asignar la relación de detalle de venta: ${e.toString()}");
    }
    return false;
  }

  static Future<bool> deshacerRelacion(int idVenta) async {
    try {
      final db = await DatabaseController().database;

      // Obtener detalles de la venta para restaurar stock
      final detalles = await db.rawQuery('''
        SELECT idProducto, cantidadProducto FROM DetallesVentas WHERE idVenta = ?
      ''', [idVenta]);

      for (var detalle in detalles) {
        await db.rawUpdate('''
          UPDATE Productos SET stockActual = stockActual + ? WHERE idProducto = ?
        ''', [detalle['cantidadProducto'], detalle['idProducto']]);
      }

      // Eliminar detalles de la venta
      await db.rawDelete('''
        DELETE FROM DetallesVentas WHERE idVenta = ?
      ''', [idVenta]);

      return true;
    } catch (e) {
      debugPrint(
          "Error al deshacer la relación de detalle de venta: ${e.toString()}");
    }
    return false;
  }

  static Future<List<DetalleVenta>> obtenerDetallesPorVenta(int idVenta) async {
    try {
      final db = await DatabaseController().database;

      // Obtener los detalles de la venta
      final detallesData = await db.rawQuery('''
      SELECT * FROM DetallesVentas WHERE idVenta = ?
    ''', [idVenta]);

      // Convertir los resultados en una lista de objetos DetalleVenta
      List<DetalleVenta> detalles = detallesData.map((detalle) {
        return DetalleVenta(
          idProducto: detalle['idProducto'] as int,
          idVenta: detalle['idVenta'] as int,
          cantidadProducto: detalle['cantidadProducto'] as int,
          subtotalProducto: (detalle['subtotalProducto'] as num).toDouble(),
          descuentoProducto: detalle['descuentoProducto'] as double,
        );
      }).toList();

      return detalles;
    } catch (e) {
      debugPrint("Error al obtener los detalles de venta: ${e.toString()}");
      return [];
    }
  }
}
