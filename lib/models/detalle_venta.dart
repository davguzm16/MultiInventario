import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/venta.dart';

class DetalleVenta {
  int idProducto;
  int idLote;
  int? idVenta;
  int cantidadProducto;
  double precioUnidadProducto;
  double subtotalProducto;
  double gananciaProducto;
  double? descuentoProducto;

  DetalleVenta({
    required this.idProducto,
    required this.idLote,
    this.idVenta,
    required this.cantidadProducto,
    required this.precioUnidadProducto,
    required this.subtotalProducto,
    required this.gananciaProducto,
    this.descuentoProducto,
  });

  static Future<bool> asignarRelacion(int idVenta, DetalleVenta detalle) async {
    try {
      final db = await DatabaseController().database;
      await db.rawInsert('''
        INSERT INTO DetallesVentas (
          idProducto, idLote, idVenta, cantidadProducto, precioUnidadProducto, subtotalProducto, gananciaProducto, descuentoProducto
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        detalle.idProducto,
        detalle.idLote,
        idVenta,
        detalle.cantidadProducto,
        detalle.precioUnidadProducto,
        detalle.subtotalProducto,
        detalle.gananciaProducto,
        detalle.descuentoProducto ?? 0.0,
      ]);

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
          idLote: detalle['idLote'] as int,
          idVenta: detalle['idVenta'] as int,
          cantidadProducto: detalle['cantidadProducto'] as int,
          precioUnidadProducto:
              (detalle['precioUnidadProducto'] as num).toDouble(),
          subtotalProducto: (detalle['subtotalProducto'] as num).toDouble(),
          gananciaProducto: (detalle['gananciaProducto'] as num).toDouble(),
          descuentoProducto: detalle['descuentoProducto'] as double?,
        );
      }).toList();

      return detalles;
    } catch (e) {
      debugPrint("Error al obtener los detalles de venta: ${e.toString()}");
      return [];
    }
  }

  static Future<List<DetalleVenta>> obtenerDetallesPorFechas(
      DateTime fechaInicio, DateTime fechaFinal) async {
    List<DetalleVenta> detalles = [];
    List<Venta> ventas =
        await Venta.obtenerVentasporFecha(fechaInicio, fechaFinal);
    List<int> idsVentas =
        ventas.map((venta) => venta.idVenta).whereType<int>().toList();

    try {
      for (var id in idsVentas) {
        List<DetalleVenta> detallesVenta = await obtenerDetallesPorVenta(id);
        detalles.addAll(detallesVenta);
      }
    } catch (e) {
      debugPrint("Error al obtener los detalles de venta: ${e.toString()}");
    }
    return detalles;
  }

  static Future<int> obtenerCantidadVendidaPorLote(int idLote) async {
    try {
      final db = await DatabaseController().database;

      // Obtener la cantidad total vendida para el lote especificado
      final result = await db.rawQuery('''
      SELECT SUM(cantidadProducto) as cantidadVendida
      FROM DetallesVentas
      WHERE idLote = ?
    ''', [idLote]);

      if (result.isNotEmpty && result.first['cantidadVendida'] != null) {
        return result.first['cantidadVendida'] as int;
      }
    } catch (e) {
      debugPrint(
          "Error al obtener la cantidad vendida por lote: ${e.toString()}");
    }
    return 0;
  }
}
