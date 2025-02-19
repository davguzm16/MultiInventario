import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';

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
  });

  static Future<bool> crearLote(Lote lote) async {
    try {
      final db = await DatabaseController().database;

      final insertResult = await db.rawInsert(
        '''
        INSERT INTO Lotes (idProducto, cantidadActual, cantidadComprada, cantidadPerdida, precioCompra, precioCompraUnidad, fechaCaducidad, fechaCompra)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          lote.idProducto,
          lote.cantidadActual,
          lote.cantidadComprada,
          lote.cantidadPerdida ?? 0,
          lote.precioCompra,
          lote.precioCompraUnidad,
          lote.fechaCaducidad?.toIso8601String(),
          lote.fechaCompra?.toIso8601String(),
        ],
      );

      debugPrint("Resultado de inserción: $insertResult");
      return insertResult > 0;
    } catch (e) {
      debugPrint("Error al crear lote: ${e.toString()}");
      return false;
    }
  }

  static Future<List<Lote>> obtenerLotesDeProducto(int idProducto) async {
    List<Lote> lotes = [];

    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT idLote, idProducto, cantidadActual, cantidadComprada, cantidadPerdida, precioCompra, precioCompraUnidad, fechaCaducidad, fechaCompra 
        FROM Lotes 
        WHERE idProducto = ? 
        ORDER BY idLote ASC
        ''',
        [idProducto],
      );

      for (var item in result) {
        lotes.add(Lote(
          idLote: item['idLote'] as int?,
          idProducto: item['idProducto'] as int,
          cantidadActual: item['cantidadActual'] as int,
          cantidadComprada: item['cantidadComprada'] as int,
          cantidadPerdida: item['cantidadPerdida'] as int? ?? 0,
          precioCompra: (item['precioCompra'] as num).toDouble(),
          precioCompraUnidad: (item['precioCompraUnidad'] as num).toDouble(),
          fechaCaducidad: item['fechaCaducidad'] != null
              ? DateTime.parse(item['fechaCaducidad'])
              : null,
          fechaCompra: item['fechaCompra'] != null
              ? DateTime.parse(item['fechaCompra'])
              : null,
        ));
      }
    } catch (e) {
      debugPrint(
          "Error al obtener los lotes del producto $idProducto: ${e.toString()}");
    }
    return lotes;
  }

  static Future<bool> actualizarLote(Lote lote) async {
    try {
      final db = await DatabaseController().database;
      int result = await db.rawUpdate(
        '''
        UPDATE Lotes 
        SET cantidadActual = ?, cantidadComprada = ?, cantidadPerdida = ?, precioCompra = ?, precioCompraUnidad = ?, fechaCaducidad = ?, fechaCompra = ? 
        WHERE idLote = ?
        ''',
        [
          lote.cantidadActual,
          lote.cantidadComprada,
          lote.cantidadPerdida ?? 0,
          lote.precioCompra,
          lote.precioCompraUnidad,
          lote.fechaCaducidad?.toIso8601String(),
          lote.fechaCompra?.toIso8601String(),
          lote.idLote,
        ],
      );

      return result > 0;
    } catch (e) {
      debugPrint("Error al actualizar el lote ${lote.idLote}: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> eliminarLote(int idLote) async {
    try {
      final db = await DatabaseController().database;
      int result = await db.rawDelete(
        'DELETE FROM Lotes WHERE idLote = ?',
        [idLote],
      );
      return result > 0;
    } catch (e) {
      debugPrint("Error al eliminar lote $idLote: ${e.toString()}");
      return false;
    }
  }

  static Future<Lote?> obtenerLotePorId(int idLote) async {
    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada, cantidadPerdida, precioCompra, precioCompraUnidad, fechaCaducidad, fechaCompra 
      FROM Lotes 
      WHERE idLote = ?
      ''',
        [idLote],
      );

      if (result.isNotEmpty) {
        var item = result.first;
        return Lote(
          idLote: item['idLote'] as int?,
          idProducto: item['idProducto'] as int,
          cantidadActual: item['cantidadActual'] as int,
          cantidadComprada: item['cantidadComprada'] as int,
          cantidadPerdida: item['cantidadPerdida'] as int? ?? 0,
          precioCompra: (item['precioCompra'] as num).toDouble(),
          precioCompraUnidad: (item['precioCompraUnidad'] as num).toDouble(),
          fechaCaducidad: item['fechaCaducidad'] != null
              ? DateTime.parse(item['fechaCaducidad'])
              : null,
          fechaCompra: item['fechaCompra'] != null
              ? DateTime.parse(item['fechaCompra'])
              : null,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener el lote $idLote: ${e.toString()}");
    }
    return null;
  }


  static Future<List<Lote>> obtenerLotesporFecha(DateTime fechaInicio, DateTime fechaFinal) async{
    List<Lote> lote = [];
  
  try{
    final db = await DatabaseController().database;
    final result = await db.rawQuery('''
      SELECT idLote, idProducto, cantidadActual, cantidadComprada,
              cantidadPerdida, precioCompra, precioCompraUnidad,
              fechaCaducidad, fechaCompra
      FROM lotes 
      WHERE fechaCompra BETWEEN ? AND ?
      ORDER BY fechaCompra ASC
      ''', [fechaInicio.toIso8601String(),fechaFinal.toIso8601String()]);
      if(result.isNotEmpty){
        for (var item in result){
          lote.add(Lote(
          idLote: item['idLote'] as int,
          idProducto: item['idProducto'] as int,
          cantidadActual: item['cantidadActual'] as int,
          cantidadComprada: item['cantidadComprada'] as int,
          cantidadPerdida: item['cantidadPerdida'] as int,
          precioCompra: item['precioCompra'] as double,
          precioCompraUnidad: item['preciocompraUnidad'] as double,
          fechaCaducidad: DateTime.parse(item['fechaCaducidad'] as String),
          fechaCompra: DateTime.parse(item['fechaCompra'] as String)
        )
        );
      }
      }
  }catch(e) {
    debugPrint("Error al obtener los loten en la fechas: ${e.toString()}");
  }
  return lote;
 }

}

