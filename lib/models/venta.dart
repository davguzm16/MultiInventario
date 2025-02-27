import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:sqflite/sqflite.dart';

class Venta {
  int? idVenta;
  int idCliente;
  String? codigoBoleta;
  DateTime? fechaVenta;
  double montoTotal;
  double? montoCancelado;
  bool? esAlContado;

  // Constructor
  Venta({
    this.idVenta,
    required this.idCliente,
    this.codigoBoleta,
    this.fechaVenta,
    required this.montoTotal,
    this.montoCancelado,
    this.esAlContado,
  });

  static Future<bool> crearVenta(
      Venta venta, List<DetalleVenta> detallesVentas) async {
    try {
      final db = await DatabaseController().database;

      if (venta.montoTotal > 5.00) {
        final result = await db.rawQuery('''
        SELECT MAX(CAST(SUBSTR(codigoBoleta, 5) AS INTEGER)) as ultimoNumero
        FROM Ventas WHERE codigoBoleta IS NOT NULL
      ''');

        int ultimoNumero = result.first['ultimoNumero'] != null
            ? (result.first['ultimoNumero'] as int)
            : 0;

        String numeroFormateado = (ultimoNumero + 1).toString().padLeft(5, '0');
        venta.codigoBoleta = '002-$numeroFormateado';
      }

      final result = await db.rawInsert('''
          INSERT INTO Ventas (
            idCliente, codigoBoleta, montoTotal, montoCancelado, esAlContado
          ) VALUES (?, ?, ?, ?, ?)
        ''', [
        venta.idCliente,
        venta.codigoBoleta,
        venta.montoTotal,
        venta.montoCancelado,
        venta.esAlContado,
      ]);

      if (result > 0) {
        final resultId = await db.rawQuery('SELECT last_insert_rowid()');
        int? idVentaInsertada = Sqflite.firstIntValue(resultId);

        if (idVentaInsertada == null) {
          return false;
        }

        for (var detalle in detallesVentas) {
          final lote =
              await Lote.obtenerLotePorId(detalle.idProducto, detalle.idLote);
          lote!.cantidadActual -= detalle.cantidadProducto;

          await Lote.actualizarLote(lote);

          await DetalleVenta.asignarRelacion(idVentaInsertada, detalle);
        }

        debugPrint(
            "Venta ${venta.codigoBoleta ?? 'sin boleta'} creada con éxito!");
        return true;
      }
    } catch (e) {
      debugPrint("Error al crear la venta: ${e.toString()}");
    }

    return false;
  }

  static Future<List<Venta>> obtenerVentasPorCodigo(String codigoBoleta) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT idVenta, idCliente, codigoBoleta, fechaVenta, 
      montoTotal, montoCancelado, esAlContado 
      FROM Ventas WHERE codigoBoleta LIKE ?
      ''',
        ['%$codigoBoleta%'],
      );

      return result.map((map) {
        return Venta(
          idVenta: map['idVenta'] as int,
          idCliente: map['idCliente'] as int,
          codigoBoleta: map['codigoBoleta'] as String,
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
      SELECT idVenta, idCliente, codigoBoleta, fechaVenta, 
      montoTotal, montoCancelado, esAlContado
      FROM Ventas WHERE idVenta = ?
      ''',
        [idVenta],
      );

      if (result.isNotEmpty) {
        return Venta(
          idVenta: result.first['idVenta'] as int,
          idCliente: result.first['idCliente'] as int,
          codigoBoleta: result.first['codigoBoleta'] as String,
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

      String esAlContadoQuery = "";

      if (esAlContado != null) {
        esAlContadoQuery = "WHERE esAlContado = ${esAlContado ? 1 : 0}";
      }

      final result = await db.rawQuery('''
      SELECT idVenta, idCliente, codigoBoleta, fechaVenta, 
             montoTotal, montoCancelado, esAlContado
      FROM Ventas
      $esAlContadoQuery
      LIMIT ? OFFSET ?
    ''', [cantidadPorCarga, offset]);

      for (var item in result) {
        ventas.add(Venta(
          idVenta: item['idVenta'] as int,
          idCliente: item['idCliente'] as int,
          codigoBoleta: item['codigoBoleta'] as String,
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

  static Future<List<Venta>> obtenerVentasDeCliente(int idCliente) async {
    List<Venta> ventas = [];
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery('''
        SELECT idVenta, codigoBoleta, fechaVenta, 
             montoTotal, montoCancelado, esAlContado
        FROM Ventas
        WHERE idCliente = ?
      ''', [idCliente]);

      for (var item in result) {
        ventas.add(Venta(
          idVenta: item['idVenta'] as int,
          idCliente: idCliente,
          codigoBoleta: item['codigoBoleta'] as String,
          fechaVenta: DateTime.parse(item['fechaVenta'] as String),
          montoTotal: (item['montoTotal'] as num).toDouble(),
          montoCancelado: (item['montoCancelado'] as num).toDouble(),
          esAlContado: (item['esAlContado'] as int) == 1,
        ));
      }
    } catch (e) {
      debugPrint("Error al obtener las ventas del cliente: ${e.toString()}");
    }

    return ventas;
  }

  static Future<List<Venta>> obtenerVentasporFecha(
      DateTime fechaInicio, DateTime fechaFinal) async {
    List<Venta> ventas = [];

    try {
      final db = await DatabaseController().database;

      String fechaInicioStr =
          "${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')} 00:00:00";
      String fechaFinalStr =
          "${fechaFinal.year}-${fechaFinal.month.toString().padLeft(2, '0')}-${fechaFinal.day.toString().padLeft(2, '0')} 23:59:59";
      debugPrint(fechaInicioStr);
      debugPrint(fechaFinalStr);
      final result = await db.rawQuery('''
      SELECT idVenta, idCliente, codigoBoleta, fechaVenta,
              montoTotal, montoCancelado, esAlcontado
      FROM Ventas 
      WHERE fechaVenta BETWEEN ? AND ?
      ORDER BY fechaVenta ASC
      ''', [fechaInicioStr, fechaFinalStr]);
      debugPrint('hola $result');
      if (result.isNotEmpty) {
        for (var item in result) {
          ventas.add(Venta(
            idVenta: item['idVenta'] as int,
            idCliente: item['idCliente'] as int,
            codigoBoleta: item['codigoBoleta'] as String,
            fechaVenta: DateTime.parse(item['fechaVenta'] as String),
            montoTotal: (item['montoTotal'] as num).toDouble(),
            montoCancelado: (item['montoCancelado'] as num).toDouble(),
            esAlContado: (item['esAlContado'] as int) == 1,
          ));
        }
        debugPrint("Ventas: $ventas");
      }
    } catch (e) {
      debugPrint("Error al obtener las ventas en la fechas: ${e.toString()}");
    }
    return ventas;
  }

  static Future<bool> actualizarMontoCancelado(
      int idVenta, double montoACancelar) async {
    try {
      final db = await DatabaseController().database;
      Venta? venta = await obtenerVentaPorID(idVenta);
      if (venta == null) return false;

      double nuevoMontoCancelado = (venta.montoCancelado ?? 0) + montoACancelar;

      int resultado = await db.rawUpdate(
        '''
      UPDATE Ventas
      SET montoCancelado = ?
      WHERE idVenta = ?
      ''',
        [nuevoMontoCancelado, idVenta],
      );

      if (resultado > 0) {
        return true;
      }
    } catch (e) {
      debugPrint("Error al actualizar el monto cancelado: ${e.toString()}");
    }

    return false;
  }
}
