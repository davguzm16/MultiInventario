import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Cliente {
  int? idCliente;
  String nombreCliente;
  String dniCliente;
  String? correoCliente;

  // Constructor
  Cliente({
    this.idCliente,
    required this.nombreCliente,
    required this.dniCliente,
    required this.correoCliente,
  });

  static Future<int?> crearCliente(Cliente cliente) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert(
        'INSERT INTO Clientes (nombreCliente, dniCliente, correoCliente) VALUES (?, ?, ?)',
        [cliente.nombreCliente, cliente.dniCliente, cliente.correoCliente],
      );

      if (result > 0) {
        debugPrint("Cliente ${cliente.nombreCliente} creado con exito!");
        return result;
      }
    } catch (e) {
      debugPrint("Error al crear el cliente: ${e.toString()}");
    }

    return null;
  }

  static Future<List<Cliente>> obtenerClientesPorNombre(String nombre) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT * FROM Clientes WHERE nombreCliente LIKE ?
        ''',
        ['%$nombre%'],
      );

      return result.map((map) {
        return Cliente(
          idCliente: map['idCliente'] as int?,
          nombreCliente: map['nombreCliente'] as String,
          dniCliente: map['dniCliente'] as String,
          correoCliente: map['correoCliente'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error al buscar clientes: ${e.toString()}");
      return [];
    }
  }
}
