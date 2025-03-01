import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/services/notification_service.dart';

class Lote {
  int? idLote;
  int idProducto;
  int cantidadActual;
  int cantidadComprada;
  int? cantidadPerdida;
  double precioCompra;
  double precioCompraUnidad;
  DateTime? fechaCaducidad;
  DateTime? fechaCompra;
  bool? estaDisponible;

  // Constructor
  Lote({
    this.idLote,
    required this.idProducto,
    required this.cantidadActual,
    required this.cantidadComprada,
    this.cantidadPerdida,
    required this.precioCompra,
    required this.precioCompraUnidad,
    this.fechaCaducidad,
    this.fechaCompra,
    this.estaDisponible,
  });

  static Future<bool> crearLote(Lote lote) async {
    try {
      final db = await DatabaseController().database;

      // Obtener el próximo ID de lote
      final result = await db.rawQuery(
        '''
      SELECT MAX(idLote) + 1 AS nextId FROM Lotes WHERE idProducto = ?
      ''',
        [lote.idProducto],
      );

      int nextIdLote = (result.first['nextId'] as int?) ?? 1;

      // Insertar el nuevo lote
      final insertResult = await db.rawInsert(
        '''
      INSERT INTO Lotes (idLote, idProducto, cantidadActual, 
      cantidadComprada, cantidadPerdida, precioCompra, 
      precioCompraUnidad, fechaCaducidad, fechaCompra, estaDisponible)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          nextIdLote,
          lote.idProducto,
          lote.cantidadActual,
          lote.cantidadComprada,
          lote.cantidadPerdida ?? 0,
          lote.precioCompra,
          lote.precioCompraUnidad,
          lote.fechaCaducidad?.toIso8601String(),
          lote.fechaCompra?.toIso8601String(),
          lote.estaDisponible ?? 1
        ],
      );

      if (insertResult > 0) {
        return actualizarStocks(lote);
      }
    } catch (e) {
      debugPrint("Error al crear lote: ${e.toString()}");
    }

    return false;
  }

  static Future<Lote?> obtenerLotePorId(int idProducto, int idLote) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery('''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada, 
      cantidadPerdida, precioCompra, precioCompraUnidad, 
      fechaCaducidad, fechaCompra, estaDisponible
      FROM Lotes
      WHERE idProducto = ? AND idLote = ? AND estaDisponible = 1
      LIMIT 1
    ''', [idProducto, idLote]);

      if (result.isNotEmpty) {
        return Lote(
          idLote: result.first['idLote'] as int,
          idProducto: result.first['idProducto'] as int,
          cantidadActual: result.first['cantidadActual'] as int,
          cantidadComprada: result.first['cantidadComprada'] as int,
          cantidadPerdida: result.first['cantidadPerdida'] as int?,
          precioCompra: (result.first['precioCompra'] as num).toDouble(),
          precioCompraUnidad:
              (result.first['precioCompraUnidad'] as num).toDouble(),
          fechaCaducidad: result.first['fechaCaducidad'] != null
              ? DateTime.parse(result.first['fechaCaducidad'] as String)
              : null,
          fechaCompra: result.first['fechaCompra'] != null
              ? DateTime.parse(result.first['fechaCompra'] as String)
              : null,
          estaDisponible: (result.first['estaDisponible'] as int) == 1,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener el lote: ${e.toString()}");
    }

    return null;
  }

  static Future<List<Lote>> obtenerLotesDeProducto(int idProducto) async {
    List<Lote> lotes = [];

    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada, 
      cantidadPerdida, precioCompra, precioCompraUnidad, 
      fechaCaducidad, fechaCompra, estaDisponible
      FROM Lotes 
      WHERE idProducto = ? AND estaDisponible = 1
      ORDER BY idLote ASC
      ''',
        [idProducto],
      );

      for (var item in result) {
        lotes.add(
          Lote(
            idLote: item['idLote'] as int,
            idProducto: item['idProducto'] as int,
            cantidadActual: item['cantidadActual'] as int,
            cantidadComprada: item['cantidadComprada'] as int,
            cantidadPerdida: item['cantidadPerdida'] as int?,
            precioCompra: (item['precioCompra'] as num).toDouble(),
            precioCompraUnidad: (item['precioCompraUnidad'] as num).toDouble(),
            fechaCaducidad: item['fechaCaducidad'] != null
                ? DateTime.parse(item['fechaCaducidad'] as String)
                : null,
            fechaCompra: item['fechaCompra'] != null
                ? DateTime.parse(item['fechaCompra'] as String)
                : null,
            estaDisponible: (item['estaDisponible'] as int) == 1,
          ),
        );
      }
    } catch (e) {
      debugPrint(
          "Error al obtener lotes del producto $idProducto: ${e.toString()}");
    }
    return lotes;
  }

  static Future<bool> actualizarLote(Lote lote) async {
    try {
      final db = await DatabaseController().database;

      // Actualizar el lote
      int result = await db.rawUpdate(
        '''
      UPDATE Lotes 
      SET cantidadActual = cantidadActual + (? - cantidadComprada), cantidadComprada = ?, cantidadPerdida = ?, 
      precioCompra = ?, precioCompraUnidad = ?, 
      fechaCaducidad = ?, fechaCompra = ?
      WHERE idProducto = ? AND idLote = ?
      ''',
        [
          lote.cantidadComprada,
          lote.cantidadComprada,
          lote.cantidadPerdida ?? 0,
          lote.precioCompra,
          lote.precioCompraUnidad,
          lote.fechaCaducidad?.toIso8601String(),
          lote.fechaCompra?.toIso8601String(),
          lote.idProducto,
          lote.idLote,
        ],
      );
      debugPrint('${lote.fechaCaducidad?.toIso8601String()}');
      debugPrint('${lote.fechaCompra?.toIso8601String()}');
      if (result > 0) {
        Lote.actualizarStocks(lote);
        return true;
      }
    } catch (e) {
      debugPrint("Error al actualizar el lote ${lote.idLote}: ${e.toString()}");
    }

    return false;
  }

  static Future<bool> actualizarStocks(Lote lote) async {
    try {
      final db = await DatabaseController().database;

      int result = 0;

      debugPrint("Esta disponible?: ${lote.estaDisponible}");
      if (lote.estaDisponible == null) {
        result = await db.rawUpdate(
          '''
        UPDATE Productos
        SET stockActual = stockActual + ?
        WHERE idProducto = ?
        ''',
          [
            lote.cantidadActual,
            lote.idProducto,
          ],
        );
      } else {
        if (!(lote.estaDisponible!)) {
          result = await db.rawUpdate(
            '''
            UPDATE Productos
            SET stockActual = stockActual - ?
            WHERE idProducto = ?
            ''',
            [
              lote.cantidadActual,
              lote.idProducto,
            ],
          );
        } else {
          result = await db.rawUpdate(
            '''
              UPDATE Productos
              SET stockActual = stockActual + (? - stockActual)
              WHERE idProducto = ?
              ''',
            [
              lote.cantidadActual,
              lote.idProducto,
            ],
          );
        }
      }

      return result > 0;
    } catch (e) {
      debugPrint(
          "Error al actualizar el stock del producto ${lote.idProducto}: $e");
    }

    return false;
  }

  static Future<bool> eliminarLote(Lote lote) async {
    try {
      final db = await DatabaseController().database;

      int result = await db.rawUpdate(
        'UPDATE Lotes SET estaDisponible = 0 WHERE idProducto = ? AND idLote = ?',
        [lote.idProducto, lote.idLote],
      );

      if (result > 0) {
        lote.estaDisponible = false;
        return actualizarStocks(lote);
      }
    } catch (e) {
      debugPrint("Error al eliminar el lote ${lote.idLote}: ${e.toString()}");
    }

    return false;
  }

  static Future<List<Lote>> obtenerLotesporFecha(
      DateTime fechaInicio, DateTime fechaFinal) async {
    List<Lote> lote = [];

    try {
      final db = await DatabaseController().database;

      String fechaInicioStr = fechaInicio.toIso8601String();
      String fechaFinalStr =
          "${fechaFinal.year}-${fechaFinal.month.toString().padLeft(2, '0')}-${fechaFinal.day.toString().padLeft(2, '0')}T:23:59:59:999";

      final result = await db.rawQuery('''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada,
              cantidadPerdida, precioCompra, precioCompraUnidad,
              fechaCaducidad, fechaCompra
      FROM lotes 
      WHERE fechaCompra BETWEEN ? AND ?
      ORDER BY fechaCompra ASC
      ''', [fechaInicioStr, fechaFinalStr]);

      if (result.isNotEmpty) {
        for (var item in result) {
          lote.add(Lote(
            idLote: item['idLote'] as int,
            idProducto: item['idProducto'] as int,
            cantidadActual: item['cantidadActual'] as int,
            cantidadComprada: item['cantidadComprada'] as int,
            cantidadPerdida: item['cantidadPerdida'] as int,
            precioCompra: item['precioCompra'] as double,
            precioCompraUnidad: item['precioCompraUnidad'] as double,
            fechaCaducidad: DateTime.parse(item['fechaCaducidad'] as String),
            fechaCompra: DateTime.parse(item['fechaCompra'] as String),
          ));
        }
      }
    } catch (e) {
      debugPrint("Error al obtener los lotes en las fechas: ${e.toString()}");
    }
    return lote;
  }

  static Future<List<Lote>> obtenerLotesPorRangoDeFechasYDias(
      DateTime fechaInicio,
      DateTime fechaFinal,
      int diasAntesVencimiento) async {
    List<Lote> lote = [];

    try {
      DateTime fechaLimiteCaducidad =
          fechaFinal.add(Duration(days: diasAntesVencimiento));
      final db = await DatabaseController().database;

      String fechaInicioStr = fechaInicio.toIso8601String();
      String fechaFinalStr =
          "${fechaFinal.year}-${fechaFinal.month.toString().padLeft(2, '0')}-${fechaFinal.day.toString().padLeft(2, '0')}T:23:59:59:999";
      String fechaLimiteCaducidadStr =
          "${fechaLimiteCaducidad.year}-${fechaLimiteCaducidad.month.toString().padLeft(2, '0')}-${fechaLimiteCaducidad.day.toString().padLeft(2, '0')}T:23:59:59:999";

      final result = await db.rawQuery('''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada,
              cantidadPerdida, precioCompra, precioCompraUnidad,
              fechaCaducidad, fechaCompra
      FROM lotes 
      WHERE fechaCompra BETWEEN ? AND ?
      AND fechaCaducidad <= ?
      ORDER BY fechaCompra ASC
      ''', [fechaInicioStr, fechaFinalStr, fechaLimiteCaducidadStr]);
      debugPrint(fechaInicioStr);
      debugPrint(fechaFinalStr);
      debugPrint(fechaLimiteCaducidadStr);
      debugPrint("$result");
      if (result.isNotEmpty) {
        for (var item in result) {
          lote.add(Lote(
            idLote: item['idLote'] as int,
            idProducto: item['idProducto'] as int,
            cantidadActual: item['cantidadActual'] as int,
            cantidadComprada: item['cantidadComprada'] as int,
            cantidadPerdida: item['cantidadPerdida'] as int,
            precioCompra: item['precioCompra'] as double,
            precioCompraUnidad: item['precioCompraUnidad'] as double,
            fechaCaducidad: DateTime.parse(item['fechaCaducidad'] as String),
            fechaCompra: DateTime.parse(item['fechaCompra'] as String),
          ));
        }
      }
      debugPrint(' lote : $lote');
    } catch (e) {
      debugPrint("Error al obtener los lotes en las fechas: ${e.toString()}");
    }
    return lote;
  }

  static Future<bool> verificarFechasVencimientos(
      int diasAntesVencimiento) async {
    try {
      final db = await DatabaseController().database;
      DateTime fechaActual = DateTime.now();
      DateTime fechaLimite =
          fechaActual.add(Duration(days: diasAntesVencimiento));

      final result = await db.rawQuery('''
        SELECT idLote, idProducto, fechaCaducidad 
        FROM Lotes 
        WHERE fechaCaducidad IS NOT NULL AND fechaCaducidad <= ?
      ''', [fechaLimite.toIso8601String()]);

      for (var item in result) {
        DateTime fechaCaducidad =
            DateTime.parse(item['fechaCaducidad'] as String);
        if (fechaActual.isBefore(fechaCaducidad)) {
          await NotificationService.mostrarNotificacion(
            titulo: "🚨 ¡Atención!",
            contenido:
                "⏳ El lote ${item['idLote']} del producto ${item['idProducto']} vence el 📅 ${fechaCaducidad.toLocal().toString().split(' ')[0]}.\n⚠️ ¡Toma medidas a tiempo!",
          );

          debugPrint(
              "📢 Mostrando la notificación de vencimiento del lote ${item['idLote']} del producto ${item['idProducto']} con fecha ${fechaCaducidad.toLocal()}");
        }
      }

      return true;
    } catch (e) {
      debugPrint("Error verificando fechas de vencimiento: $e");
    }

    return false;
  }
}
