import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:sqflite/sqflite.dart';

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
        stockMinimo, stockMaximo, rutaImagen
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        producto.idUnidad,
        producto.codigoProducto,
        producto.nombreProducto,
        producto.precioProducto,
        producto.stockActual,
        producto.stockMinimo,
        producto.stockMaximo,
        producto.rutaImagen,
      ]);

      if (result > 0) {
        final resultId = await db.rawQuery('SELECT last_insert_rowid()');
        int? idProductoInsertado = Sqflite.firstIntValue(resultId);

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
            stockMinimo: (result.first['stockMinimo'] as num?)?.toDouble(),
            stockMaximo: (result.first['stockMaximo'] as num?)?.toDouble(),
            estaDisponible: (result.first['estaDisponible'] as int) == 1,
            rutaImagen: (result.first['rutaImagen'] as String?));
      }
    } catch (e) {
      debugPrint("Error al obtener el producto $idProducto: ${e.toString()}");
    }

    return null;
  }

  static Future<List<Producto>> obtenerProductosPorCarga(
      int numeroCarga) async {
    List<Producto> productos = [];

    try {
      final db = await DatabaseController().database;
      int offset = numeroCarga * 8;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
      SELECT idProducto, idUnidad, codigoProducto, nombreProducto, precioProducto, 
             stockActual, stockMinimo, stockMaximo, estaDisponible, rutaImagen
      FROM Productos
      LIMIT ? OFFSET ?
      ''',
        [8, offset],
      );

      for (var item in result) {
        productos.add(Producto(
          idProducto: item['idProducto'] as int,
          idUnidad: item['idUnidad'] as int,
          codigoProducto: item['codigoProducto'] as String?,
          nombreProducto: item['nombreProducto'] as String,
          precioProducto: item['precioProducto'] as double,
          stockActual: item['stockActual'] as double,
          stockMinimo: item['stockMinimo'] as double?,
          stockMaximo: item['stockMaximo'] as double?,
          estaDisponible: (item['estaDisponible'] as int) == 1,
          rutaImagen: item['rutaImagen'] as String?,
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener productos: ${e.toString()}');
    }

    return productos;
  }

  static Future<int?> contarProductos() async {
    try {
      final db = await DatabaseController().database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as total FROM Productos');

      if (result.isNotEmpty) {
        return result.first['total'] as int;
      }
    } catch (e) {
      debugPrint('Error al contar los productos: ${e.toString()}');
    }

    return null;
  }

  static Future<void> insertarProductosPorDefecto() async {
    if (await DatabaseController.tableHasData("Productos")) return;

    try {
      List<Categoria> categorias = await Categoria.obtenerCategorias();
      Random random = Random();

      List<Producto> productos = List.generate(100, (index) {
        int idUnidad = random.nextInt(3) + 1; // Valores entre 1 y 3
        double precio =
            (random.nextDouble() * 90) + 10; // Precio entre 10 y 100
        int stockActual = random.nextInt(200) + 1; // Stock entre 1 y 200
        int stockMinimo = random.nextInt(20) + 5; // Mínimo entre 5 y 25
        int stockMaximo = stockActual +
            random.nextInt(100) +
            50; // Máximo entre stockActual+50 y stockActual+150

        return Producto(
          idUnidad: idUnidad,
          codigoProducto: "7501000000${(index + 1).toString().padLeft(4, '0')}",
          nombreProducto: "Producto ${index + 1}",
          precioProducto:
              double.parse(precio.toStringAsFixed(2)), // Redondeo a 2 decimales
          stockActual: double.parse(stockActual.toStringAsFixed(2)),
          stockMinimo: double.parse(stockMinimo.toStringAsFixed(2)),
          stockMaximo: double.parse(stockMaximo.toStringAsFixed(2)),
          rutaImagen: null,
        );
      });

      // Asignar categorías aleatorias a cada producto
      for (var producto in productos) {
        int cantidadCategorias = random.nextInt(3) + 1; // De 1 a 3 categorías
        List<Categoria> categoriasAsignadas = List.generate(
          cantidadCategorias,
          (_) => categorias[random.nextInt(categorias.length)],
        );

        await crearProducto(producto, categoriasAsignadas);
      }

      debugPrint("Se insertaron correctamente ${productos.length} productos.");
    } catch (e) {
      debugPrint("Error al insertar productos: $e");
    }
  }

  @override
  String toString() {
    return '{idProducto: $idProducto, idUnidad: $idUnidad, codigoProducto: $codigoProducto, '
        'nombreProducto: $nombreProducto, precioProducto: $precioProducto, '
        'stockActual: $stockActual, stockMinimo: $stockMinimo, stockMaximo: $stockMaximo, '
        'estaDisponible: ${estaDisponible == true ? 1 : 0}, rutaImagen: $rutaImagen}';
  }
}
