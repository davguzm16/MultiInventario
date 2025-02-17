import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';

class ProductoCategoria {
  int idProducto;
  int idCategoria;

  ProductoCategoria({
    required this.idProducto,
    required this.idCategoria,
  });

  static Future<void> asignarRelacion(int? idProducto, int? idCategoria) async {
    if (idProducto == null ||
        idCategoria == null ||
        idProducto.isNegative ||
        idCategoria.isNegative) {
      debugPrint(
          "IDs inválidos. No se puede asignar relación: idProducto=$idProducto, idCategoria=$idCategoria");
      return;
    }

    try {
      final db = await DatabaseController().database;

      await db.rawInsert('''
          INSERT INTO ProductosCategorias (idProducto, idCategoria) VALUES (?,?)
        ''', [idProducto, idCategoria]);
    } catch (e) {
      debugPrint(
          "Error al relacionar el producto $idProducto con sus categorías: ${e.toString()}");
    }
  }

  static Future<List<Categoria>> obtenerCategoriasDeProducto(
      int? idProducto) async {
    if (idProducto == null || idProducto.isNegative) {
      debugPrint(
          "ID de producto inválido. No se pueden obtener categorías: idProducto=$idProducto");
      return [];
    }

    List<Categoria> categorias = [];

    try {
      final db = await DatabaseController().database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT c.idCategoria, c.nombreCategoria 
        FROM Categorias c
        INNER JOIN ProductosCategorias pc ON c.idCategoria = pc.idCategoria
        WHERE pc.idProducto = ?
        ''', [idProducto]);

      if (result.isNotEmpty) {
        for (var item in result) {
          categorias.add(Categoria(
            idCategoria: item['idCategoria']! as int,
            nombreCategoria: item['nombreCategoria']! as String,
          ));
        }
      } else {
        debugPrint('No se encontraron categorías para el producto $idProducto');
      }
    } catch (e) {
      debugPrint(
          "Error al obtener las categorías del producto $idProducto: ${e.toString()}");
    }

    return categorias;
  }

  static Future<List<Producto>> obtenerProductosPorCargaFiltrados({
    required int numeroCarga,
    required List<Categoria> categorias,
    bool? stockBajo,
  }) async {
    const int cantidadPorCarga = 8;
    List<Producto> productos = [];
    List<int> idsCategorias = categorias.isNotEmpty
        ? categorias.map((c) => c.idCategoria!).toList()
        : [];

    try {
      final db = await DatabaseController().database;
      int offset = numeroCarga * cantidadPorCarga;

      String categoriaQuery = "";
      String stockBajoQuery = "";

      if (idsCategorias.isNotEmpty) {
        categoriaQuery =
            "AND pc.idCategoria IN (${List.filled(idsCategorias.length, '?').join(', ')})";
      }

      if (stockBajo != null) {
        if (stockBajo) {
          stockBajoQuery = "AND p.stockActual < p.stockMinimo";
        }
      }

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT p.idProducto, p.nombreProducto, p.precioProducto, 
                      p.stockActual, p.stockMinimo, p.rutaImagen
      FROM Productos p
      LEFT JOIN ProductosCategorias pc ON p.idProducto = pc.idProducto
      WHERE p.estaDisponible = 1 
      $categoriaQuery
      $stockBajoQuery
      LIMIT ? OFFSET ?
    ''', [...idsCategorias, cantidadPorCarga, offset]);

      for (var item in result) {
        productos.add(Producto(
          idProducto: item['idProducto'] as int,
          nombreProducto: item['nombreProducto'] as String,
          precioProducto: item['precioProducto'] as double,
          stockActual: item['stockActual'] as double,
          stockMinimo: item['stockMinimo'] as double,
          rutaImagen: item['rutaImagen'] as String?,
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener productos filtrados: ${e.toString()}');
    }

    return productos;
  }
}
