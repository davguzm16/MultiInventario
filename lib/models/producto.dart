import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto_categoria.dart';

class Producto {
  int? idProducto;
  int idUnidad;
  String? codigoProducto;
  String nombreProducto;
  double precioProducto;
  double stockActual;
  double? stockMinimo;
  double? stockMaximo;
  bool? estaDisponible;
  String? rutaImagen;
  DateTime? fechaCreacion;
  DateTime? fechaModificacion;

  // Constructor
  Producto({
    this.idProducto,
    required this.idUnidad,
    this.codigoProducto,
    required this.nombreProducto,
    required this.precioProducto,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockMaximo,
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
        idUnidad, codigoProducto, nombreProducto, precioProducto, stockActual, 
        stockMinimo, stockMaximo, estaDisponible, rutaImagen, fechaCreacion, fechaModificacion
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        producto.idUnidad,
        producto.codigoProducto,
        producto.nombreProducto,
        producto.precioProducto,
        producto.stockActual,
        producto.stockMinimo,
        producto.stockMaximo,
        producto.estaDisponible,
        producto.rutaImagen ?? 'lib/assets/iconos/iconoImagen.png',
        producto.fechaCreacion?.toIso8601String(),
        producto.fechaModificacion?.toIso8601String(),
      ]);

      if (result > 0) {
        int idProductoInsertado =
            (await db.rawQuery('SELECT last_insert_rowid()')) as int;

        for (var categoria in categorias) {
          ProductoCategoria.asignarRelacion(idProductoInsertado, categoria.idCategoria!);
        }

        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
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
          precioProducto: result.first['precioProducto'] as double,
          stockActual: result.first['stockActual'] as double,
          stockMinimo: result.first['stockMinimo'] as double?,
          stockMaximo: result.first['stockMaximo'] as double?,
          estaDisponible: result.first['estaDisponible']! as bool,
          rutaImagen: result.first['rutaImagen'] as String?,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener el producto $idProducto: ${e.toString()}");
    }

    return null;
  }

  static Future<List<Producto>> obtenerProductosPorPagina(int pagina) async {
    List<Producto> productos = [];

    try {
      final db = await DatabaseController().database;
      int offset = (pagina - 1) * 9;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT idProducto, idUnidad, codigoProducto, nombreProducto, precioProducto, 
               stockActual, stockMinimo, stockMaximo, rutaImagen
        FROM Productos
        LIMIT 9 OFFSET ?
        ''',
        [offset],
      );

      if (result.isNotEmpty) {
        for (var item in result) {
          productos.add(Producto(
            idProducto: item['idProducto']! as int,
            idUnidad: item['idUnidad']! as int,
            codigoProducto: item['codigoProducto'] as String?,
            nombreProducto: item['nombreProducto']! as String,
            precioProducto: item['precioProducto']! as double,
            stockActual: item['stockActual']! as double,
            stockMinimo: item['stockMinimo'] as double?,
            stockMaximo: item['stockMaximo'] as double?,
            estaDisponible: item['estaDisponible']! as bool,
            rutaImagen: item['rutaImagen'] as String?,
          ));
        }
      } else {
        debugPrint('No se encontraron productos en la página $pagina');
      }
    } catch (e) {
      debugPrint('Error al obtener productos: ${e.toString()}');
    }

    return productos;
  }
}
