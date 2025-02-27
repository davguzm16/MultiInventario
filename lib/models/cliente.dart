import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Cliente {
  int? idCliente;
  String nombreCliente;
  String? dniCliente;
  String? correoCliente;
  bool esDeudor;

  Cliente({
    this.idCliente,
    required this.nombreCliente,
    required this.dniCliente,
    required this.correoCliente,
    this.esDeudor = false,
  });

  static Future<int?> crearCliente(Cliente cliente) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert(
        '''
        INSERT INTO Clientes (nombreCliente, dniCliente, correoCliente, esDeudor) 
        VALUES (?, ?, ?, ?)
        ''',
        [
          cliente.nombreCliente,
          cliente.dniCliente,
          cliente.correoCliente,
          cliente.esDeudor
        ],
      );

      if (result > 0) {
        debugPrint("Cliente ${cliente.nombreCliente} creado con exito!");
        return result;
      }
    } catch (e) {
      debugPrint("Error al crear el cliente: \${e.toString()}");
    }
    return null;
  }

  static Future<Cliente?> obtenerClientePorId(int id) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT idCliente, nombreCliente, dniCliente, correoCliente, esDeudor 
        FROM Clientes 
        WHERE idCliente = ?
        ''',
        [id],
      );

      if (result.isNotEmpty) {
        final map = result.first;
        return Cliente(
          idCliente: map['idCliente'] as int?,
          nombreCliente: map['nombreCliente'] as String,
          dniCliente: map['dniCliente'] as String,
          correoCliente: map['correoCliente'] as String?,
          esDeudor: (map['esDeudor'] as int) == 1,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener cliente por ID: \${e.toString()}");
    }
    return null;
  }

  static Future<List<Cliente>> obtenerClientesPorNombre(String nombre) async {
    List<Cliente> clientes = [];
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT idCliente, nombreCliente, dniCliente, correoCliente, esDeudor 
        FROM Clientes 
        WHERE nombreCliente LIKE ?
        ''',
        ['%$nombre%'],
      );

      for (var map in result) {
        clientes.add(Cliente(
          idCliente: map['idCliente'] as int?,
          nombreCliente: map['nombreCliente'] as String,
          dniCliente: map['dniCliente'] as String,
          correoCliente: map['correoCliente'] as String?,
          esDeudor: (map['esDeudor'] as int) == 1,
        ));
      }
    } catch (e) {
      debugPrint("Error al buscar clientes: \${e.toString()}");
    }
    return clientes;
  }

  static Future<List<Cliente>> obtenerClientesPorCarga({
    required int numeroCarga,
    bool? esDeudor,
  }) async {
    const int cantidadPorCarga = 8;
    List<Cliente> clientes = [];
    String esDeudorQuery = "";

    if (esDeudor != null) {
      if (esDeudor) {
        esDeudorQuery = "WHERE esDeudor = 1";
      } else {
        esDeudorQuery = "WHERE esDeudor = 0";
      }
    }

    try {
      final db = await DatabaseController().database;
      int offset = numeroCarga * cantidadPorCarga;
      final result = await db.rawQuery(
        '''
        SELECT idCliente, nombreCliente, dniCliente, correoCliente, esDeudor 
        FROM Clientes
        $esDeudorQuery
        LIMIT ? OFFSET ?
        ''',
        [cantidadPorCarga, offset],
      );

      for (var map in result) {
        clientes.add(Cliente(
          idCliente: map['idCliente'] as int?,
          nombreCliente: map['nombreCliente'] as String,
          dniCliente: map['dniCliente'] as String,
          correoCliente: map['correoCliente'] as String?,
          esDeudor: (map['esDeudor'] as int) == 1,
        ));
      }
    } catch (e) {
      debugPrint("Error al obtener clientes filtrados: \${e.toString()}");
    }
    return clientes;
  }

  Future<double?> obtenerTotalDeVentas() async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT SUM(montoTotal) AS totalVentas
        FROM Ventas
        WHERE idCliente = ?
        ''',
        [idCliente],
      );

      if (result.isNotEmpty && result.first['totalVentas'] != null) {
        return result.first['totalVentas'] as double?;
      }
      return 0.0;
    } catch (e) {
      debugPrint("Error al obtener el total de ventas: \${e.toString()}");
      return null;
    }
  }

  Future<DateTime?> obtenerFechaUltimaVenta() async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT MAX(fechaVenta) AS ultimaVenta
        FROM Ventas
        WHERE idCliente = ?
        ''',
        [idCliente],
      );

      if (result.isNotEmpty && result.first['ultimaVenta'] != null) {
        return DateTime.parse(result.first['ultimaVenta'] as String);
      }
      return null;
    } catch (e) {
      debugPrint(
          "Error al obtener la fecha de la última venta: \${e.toString()}");
      return null;
    }
  }
}
