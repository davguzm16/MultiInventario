import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:sqflite/sqflite.dart';

class Venta {
  int? idVenta;
  int idCliente;
  String codigoVenta;
  DateTime? fechaVenta;
  double montoTotal;
  double? montoCancelado;
  bool? esAlContado;

  // Constructor
  Venta({
    this.idVenta,
    required this.idCliente,
    required this.codigoVenta,
    this.fechaVenta,
    required this.montoTotal,
    this.montoCancelado,
    this.esAlContado,
  });

  static Future<bool> crearVenta(
      Venta venta, List<DetalleVenta> detallesVentas) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert('''
      INSERT INTO Ventas (
        idCliente, codigoVenta, montoTotal, montoCancelado, esAlContado
      ) VALUES (?, ?, ?, ?, ?)
    ''', [
        venta.idCliente,
        venta.codigoVenta,
        venta.montoTotal,
        venta.montoCancelado,
        venta.esAlContado,
      ]);

      if (result > 0) {
        final resultId = await db.rawQuery('SELECT last_insert_rowid()');
        int? idVentaInsertada = Sqflite.firstIntValue(resultId);

        if (idVentaInsertada == null) {
          debugPrint(
              "El id de la venta insertada no se pudo obtener: $idVentaInsertada");
          return false;
        }

        for (var detalle in detallesVentas) {
          DetalleVenta.asignarRelacion(idVentaInsertada, detalle);
        }

        debugPrint("Venta ${venta.codigoVenta} creada con exito!");
        return true;
      }
    } catch (e) {
      debugPrint("Error al crear la venta: ${e.toString()}");
    }

    return false;
  }

  static Future<List<Venta>> obtenerVentasPorCodigo(String codigoVenta) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT idVenta, idCliente, codigoVenta, fechaVenta, 
      montoTotal, montoCancelado, esAlContado 
      FROM Ventas WHERE codigoVenta LIKE ?
      ''',
        ['%$codigoVenta%'],
      );

      return result.map((map) {
        return Venta(
          idVenta: map['idVenta'] as int,
          idCliente: map['idCliente'] as int,
          codigoVenta: map['codigoVenta'] as String,
          fechaVenta: DateTime.parse(map['fechaVenta'] as String),
          montoTotal: (map['montoTotal'] as num).toDouble(),
          montoCancelado: (map['montoCancelado'] as num).toDouble(),
          esAlContado: (map['esAlContado'] as int) == 1,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error al buscar ventas: ${e.toString()}");
      return [];
    }
  }

  static Future<Venta?> obtenerVentaPorID(int idVenta) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT idVenta, idCliente, codigoVenta, fechaVenta, 
      montoTotal, montoCancelado, esAlContado
      FROM Ventas WHERE idVenta = ?
      ''',
        [idVenta],
      );

      if (result.isNotEmpty) {
        return Venta(
          idVenta: result.first['idVenta'] as int,
          idCliente: result.first['idCliente'] as int,
          codigoVenta: result.first['codigoVenta'] as String,
          fechaVenta: DateTime.parse(result.first['fechaVenta'] as String),
          montoTotal: (result.first['montoTotal'] as num).toDouble(),
          montoCancelado: (result.first['montoCancelado'] as num).toDouble(),
          esAlContado: (result.first['esAlContado'] as int) == 1,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener la venta $idVenta: ${e.toString()}");
    }

    return null;
  }

  static Future<List<Venta>> obtenerVentasPorCargaFiltradas({
    required int numeroCarga,
    bool? esAlContado,
  }) async {
    const int cantidadPorCarga = 8;
    List<Venta> ventas = [];

    try {
      final db = await DatabaseController().database;
      int offset = numeroCarga * cantidadPorCarga;

      String esAlContadoQuery =
          esAlContado == null ? "WHERE esAlContado = ?" : "";

      final result = await db.rawQuery('''
      SELECT idVenta, idCliente, codigoVenta, fechaVenta, 
             montoTotal, montoCancelado, esAlContado
      FROM Ventas
      $esAlContadoQuery
      LIMIT ? OFFSET ?
    ''', [cantidadPorCarga, offset]);

      for (var item in result) {
        ventas.add(Venta(
          idVenta: item['idVenta'] as int,
          idCliente: item['idCliente'] as int,
          codigoVenta: item['codigoVenta'] as String,
          fechaVenta: DateTime.parse(item['fechaVenta'] as String),
          montoTotal: (item['montoTotal'] as num).toDouble(),
          montoCancelado: (item['montoCancelado'] as num).toDouble(),
          esAlContado: (item['esAlContado'] as int) == 1,
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener ventas filtradas: ${e.toString()}');
    }

    return ventas;
  }
}
