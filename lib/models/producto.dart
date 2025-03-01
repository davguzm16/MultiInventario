import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:sqflite/sqflite.dart';

import 'lote.dart';

class Producto {
  int? idProducto;
  int? idUnidad;
  String? codigoProducto;
  String nombreProducto;
  double precioProducto;
  double? stockActual;
  double stockMinimo;
  double? stockMaximo;
  bool? estaDisponible;
  String? rutaImagen;
  DateTime? fechaCreacion;
  DateTime? fechaModificacion;

  // Constructor
  Producto({
    this.idProducto,
    this.idUnidad,
    this.codigoProducto,
    required this.nombreProducto,
    required this.precioProducto,
    this.stockActual,
    required this.stockMinimo,
    this.stockMaximo,
    this.rutaImagen,
    this.estaDisponible,
  });

  // Metodos CRUD
  static Future<bool> crearProducto(
      Producto producto, List<Categoria> categorias) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert('''
      INSERT INTO Productos (
        idUnidad, codigoProducto, nombreProducto, precioProducto,
        stockActual, stockMinimo, stockMaximo, rutaImagen
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        producto.idUnidad,
        producto.codigoProducto,
        producto.nombreProducto,
        producto.precioProducto,
        producto.stockActual ?? 0,
        producto.stockMinimo,
        producto.stockMaximo,
        producto.rutaImagen,
      ]);

      if (result > 0) {
        final resultId = await db.rawQuery('SELECT last_insert_rowid()');
        int? idProductoInsertado = Sqflite.firstIntValue(resultId);

        if (idProductoInsertado == null) {
          debugPrint(
              "El id del producto insertado no se pudo obtener: $idProductoInsertado");
          return false;
        }

        for (var categoria in categorias) {
          ProductoCategoria.asignarRelacion(
              idProductoInsertado, categoria.idCategoria);
        }

        return true;
      }
    } catch (e) {
      debugPrint("Error al crear el producto: ${e.toString()}");
    }

    return false;
  }

  static Future<List<Producto>> obtenerProductosPorNombre(String nombre) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT * FROM Productos WHERE nombreProducto LIKE ?
      ''',
        ['%$nombre%'],
      );

      return result.map((map) {
        return Producto(
          idProducto: map['idProducto'] as int,
          idUnidad: map['idUnidad'] as int?,
          codigoProducto: map['codigoProducto'] as String?,
          nombreProducto: map['nombreProducto'] as String,
          precioProducto: (map['precioProducto'] as num).toDouble(),
          stockActual: (map['stockActual'] as num).toDouble(),
          stockMinimo: (map['stockMinimo'] as num).toDouble(),
          stockMaximo: (map['stockMaximo'] as num?)?.toDouble(),
          estaDisponible: (map['estaDisponible'] as int) == 1,
          rutaImagen: map['rutaImagen'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error al buscar productos: ${e.toString()}");
      return [];
    }
  }

  static Future<Producto?> obtenerProductoPorID(int idProducto) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
        SELECT * FROM Productos WHERE idProducto = ?
        ''',
        [idProducto],
      );

      if (result.isNotEmpty) {
        return Producto(
            idProducto: result.first['idProducto']! as int,
            idUnidad: result.first['idUnidad']! as int,
            codigoProducto: result.first['codigoProducto'] as String?,
            nombreProducto: result.first['nombreProducto'] as String,
            precioProducto: (result.first['precioProducto'] as num).toDouble(),
            stockActual: (result.first['stockActual'] as num).toDouble(),
            stockMinimo: (result.first['stockMinimo'] as num).toDouble(),
            stockMaximo: (result.first['stockMaximo'] as num?)?.toDouble(),
            estaDisponible: (result.first['estaDisponible'] as int) == 1,
            rutaImagen: (result.first['rutaImagen'] as String?));
      }
    } catch (e) {
      debugPrint("Error al obtener el producto $idProducto: ${e.toString()}");
    }

    return null;
  }

  static Future<bool> actualizarProducto(Producto producto) async {
    try {
      final db = await DatabaseController().database;
      int result = await db.rawUpdate('''
      UPDATE Productos
      SET idUnidad = ?, codigoProducto = ?, nombreProducto = ?, 
          precioProducto = ?, stockMinimo = ?, 
          stockMaximo = ?, rutaImagen = ?, fechaModificacion = ?
      WHERE idProducto = ?
    ''', [
        producto.idUnidad,
        producto.codigoProducto,
        producto.nombreProducto,
        producto.precioProducto,
        producto.stockMinimo,
        producto.stockMaximo,
        producto.rutaImagen,
        DateTime.now().toIso8601String(),
        producto.idProducto
      ]);

      return result > 0;
    } catch (e) {
      debugPrint("Error al actualizar el producto: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> eliminarProducto(int idProducto) async {
    try {
      final db = await DatabaseController().database;
      int result = await db.rawUpdate('''
      UPDATE Productos
      SET estaDisponible = 0, fechaModificacion = ?
      WHERE idProducto = ?
    ''', [DateTime.now().toIso8601String(), idProducto]);

      return result > 0;
    } catch (e) {
      debugPrint(
          "Error al eliminar el producto (deshabilitar): ${e.toString()}");
      return false;
    }
  }

  @override
  String toString() {
    return 'Producto = {idProducto: $idProducto, idUnidad: $idUnidad, codigoProducto: $codigoProducto, '
        'nombreProducto: $nombreProducto, precioProducto: $precioProducto, '
        'stockActual: $stockActual, stockMinimo: $stockMinimo, stockMaximo: $stockMaximo, '
        'estaDisponible: ${estaDisponible == true ? 1 : 0}, rutaImagen: $rutaImagen}';
  }

  static Future<List<Producto>> obtenerProductosPorFechas(
      DateTime fechaInicio, DateTime fechaFinal) async {
    List<Producto> productos = [];
    try {
      List<DetalleVenta> ventas =
          await DetalleVenta.obtenerDetallesPorFechas(fechaInicio, fechaFinal);
      List<int> idsProductos =
          ventas.map((venta) => venta.idProducto).whereType<int>().toList();

      for (var id in idsProductos) {
        Producto? productoFiltrado = await obtenerProductoPorID(id);
        if (productoFiltrado != null) {
          productos.add(productoFiltrado);
        }
      }
    } catch (e) {
      debugPrint("Error al obtener los detalles de venta: ${e.toString()}");
    }
    return productos;
  }
  static Future<bool> eliminarProductoDefinitivo(int idProducto) async {
    final db = await DatabaseController().database;
    Batch batch = db.batch();

    try {
      // 1. Eliminar los lotes asociados al producto
      final lotes = await Lote.obtenerLotesDeProducto(idProducto);
      for (var lote in lotes) {
        batch.update(
          'Lotes',
          {'estaDisponible': 0},
          where: 'idProducto = ? AND idLote = ?',
          whereArgs: [lote.idProducto, lote.idLote],
        );
      }

      // 2. Eliminar las categorías asociadas al producto
      batch.delete(
        'ProductosCategorias',
        where: 'idProducto = ?',
        whereArgs: [idProducto],
      );

      // 3. Eliminar el producto definitivamente
      batch.delete(
        'Productos',
        where: 'idProducto = ?',
        whereArgs: [idProducto],
      );

      await batch.commit(noResult: true);
      return true;
    } catch (e) {
      debugPrint("Error al eliminar el producto definitivamente: ${e.toString()}");
      return false;
    }
  }
}
