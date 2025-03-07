import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:multiinventario/services/notification_service.dart'
    show NotificationService;
import 'package:sqflite/sqflite.dart';

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

  String get descripcion => nombreProducto;
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
    this.fechaCreacion,
    this.fechaModificacion,
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
          fechaCreacion: map['fechaCreacion'] != null
              ? DateTime.parse(map['fechaCreacion'] as String)
              : null,
          fechaModificacion: map['fechaModificacion'] != null
              ? DateTime.parse(map['fechaModificacion'] as String)
              : null,
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
          rutaImagen: (result.first['rutaImagen'] as String?),
          fechaCreacion: result.first['fechaCreacion'] != null
              ? DateTime.parse(result.first['fechaCreacion'] as String)
              : null,
          fechaModificacion: result.first['fechaModificacion'] != null
              ? DateTime.parse(result.first['fechaModificacion'] as String)
              : null,
        );
      }
    } catch (e) {
      debugPrint("Error al obtener el producto $idProducto: ${e.toString()}");
    }

    return null;
  }

  static Future<Producto?> obtenerProductoPorCodigo(
      String codigoProducto) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery(
        '''
      SELECT * FROM Productos WHERE codigoProducto = ?
      ''',
        [codigoProducto],
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
          rutaImagen: result.first['rutaImagen'] as String?,
          fechaCreacion: result.first['fechaCreacion'] != null
              ? DateTime.parse(result.first['fechaCreacion'] as String)
              : null,
          fechaModificacion: result.first['fechaModificacion'] != null
              ? DateTime.parse(result.first['fechaModificacion'] as String)
              : null,
        );
      }
    } catch (e) {
      debugPrint(
          "Error al obtener el producto con código $codigoProducto: ${e.toString()}");
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

  static Future<bool> actualizarStockActual(int idProducto) async {
    try {
      final db = await DatabaseController().database;

      var result = await db.rawQuery(
        '''
      SELECT SUM(cantidadActual) as stockTotal 
      FROM Lotes 
      WHERE idProducto = ?
      ''',
        [idProducto],
      );

      int stockTotal = (result.isNotEmpty && result.first['stockTotal'] != null)
          ? result.first['stockTotal'] as int
          : 0;

      debugPrint("ST: $stockTotal");

      int updateResult = await db.rawUpdate(
        '''
      UPDATE Productos 
      SET stockActual = ? 
      WHERE idProducto = ?
      ''',
        [stockTotal, idProducto],
      );

      return updateResult > 0;
    } catch (e) {
      debugPrint("Error al actualizar el stock del producto $idProducto: $e");
    }

    return false;
  }

  static Future<void> verificarStockBajo(int idProducto) async {
    try {
      final producto = await obtenerProductoPorID(idProducto);

      if (producto != null) {
        final unidadProducto =
            await Unidad.obtenerUnidadPorId(producto.idUnidad!);

        debugPrint(
            "Stock actual ${producto.stockActual!}, Stock minimo: ${producto.stockMinimo}");

        if (producto.stockActual! < producto.stockMinimo) {
          await NotificationService.mostrarNotificacion(
            titulo: "🚨 ¡Atención!",
            contenido:
                "📦 Solo hay ${producto.stockActual} ${unidadProducto!.tipoUnidad} del producto ${producto.nombreProducto}.\n🔄 Es momento de reabastecer.",
          );
          debugPrint(
              "📢 Mostrando la notificacion de stock minimo del producto ${producto.nombreProducto}");
        }
      }
    } catch (e) {
      debugPrint(
          "Error al verificar stock bajo para producto $idProducto: ${e.toString()}");
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

  static Future<List<Producto>> obtenerTodosLosProductos() async {
    List<Producto> producto = [];
    try {
      final db = await DatabaseController().database;
      final result = await db.rawQuery('''
      SELECT * FROM Productos
      ''');

      // Imprimir resultado de la consulta
      debugPrint("Resultado de la consulta: $result");

      // Iterar correctamente sobre la lista
      for (var item in result) {
        if ((item['estaDisponible'] as int) == 1) {
          producto.add(Producto(
            idProducto: item['idProducto']! as int,
            idUnidad: item['idUnidad']! as int,
            codigoProducto: item['codigoProducto'] as String?,
            nombreProducto: item['nombreProducto'] as String,
            precioProducto: (item['precioProducto'] as num).toDouble(),
            stockActual: (item['stockActual'] as num).toDouble(),
            stockMinimo: (item['stockMinimo'] as num).toDouble(),
            stockMaximo: (item['stockMaximo'] as num?)?.toDouble(),
            estaDisponible: (item['estaDisponible'] as int) == 1,
            rutaImagen: item['rutaImagen'] as String?,
            fechaCreacion: result.first['fechaCreacion'] != null
                ? DateTime.parse(result.first['fechaCreacion'] as String)
                : null,
            fechaModificacion: result.first['fechaModificacion'] != null
                ? DateTime.parse(result.first['fechaModificacion'] as String)
                : null,
          ));
        }
      }
    } catch (e) {
      debugPrint("Error al obtener el producto: ${e.toString()}");
    }

    // Imprimir la lista de productos obtenida
    debugPrint("Lista de productos obtenida: $producto");
    return producto;
  }
}
