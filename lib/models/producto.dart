// ignore_for_file: avoid_print

import 'package:multiinventario/controllers/db_controller.dart';

class Producto {
  late int idProducto;
  late int idUnidad;
  String? codigoProducto;
  late String nombreProducto;
  late double precioProducto;
  late double stockActual;
  double? stockMinimo;
  double? stockMaximo;
  bool? estaDisponible;
  String? rutaImagen;
  DateTime? fechaCreacion;
  DateTime? fechaModificacion;

  // Constructor
  Producto({
    required this.idUnidad,
    required this.codigoProducto,
    required this.nombreProducto,
    required this.precioProducto,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockMaximo,
    this.rutaImagen,
  });

  // Getters
  int get getIdProducto => idProducto;
  int get getIdUnidad => idUnidad;
  String? get getCodigoProducto => codigoProducto;
  String get getNombreProducto => nombreProducto;
  double get getPrecioProducto => precioProducto;
  double get getStockActual => stockActual;
  double? get getStockMinimo => stockMinimo;
  double? get getStockMaximo => stockMaximo;
  bool? get getEstaDisponible => estaDisponible;
  String? get getRutaImagen => rutaImagen;
  DateTime? get getFechaCreacion => fechaCreacion;
  DateTime? get getFechaModificacion => fechaModificacion;

  // Setters
  set setIdProducto(int id) => idProducto = id;
  set setIdUnidad(int id) => idUnidad = id;
  set setCodigoProducto(String codigo) => codigoProducto = codigo;
  set setNombreProducto(String nombre) => nombreProducto = nombre;
  set setPrecioProducto(double precio) => precioProducto = precio;
  set setStockActual(double stock) => stockActual = stock;
  set setStockMinimo(double stock) => stockMinimo = stock;
  set setStockMaximo(double stock) => stockMaximo = stock;
  set setEstaDisponible(bool disponible) => estaDisponible = disponible;
  set setRutaImagen(String ruta) => rutaImagen = ruta;
  set setFechaCreacion(DateTime fecha) => fechaCreacion = fecha;
  set setFechaModificacion(DateTime fecha) => fechaModificacion = fecha;

  // Metodos CRUD
  static Future<bool> crearProducto(Producto producto) async {
    try {
      final db = await DatabaseController().database;
      int result = await db.rawInsert('''
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
        producto.estaDisponible ?? true,
        producto.rutaImagen ??
            'lib/assets/iconos/iconoImagen.png', // Si rutaImagen es null, usa el valor por defecto
        producto.fechaCreacion?.toIso8601String(),
        producto.fechaModificacion?.toIso8601String(),
      ]);

      return result > 0; // Retorna true si se insertó correctamente
    } catch (e) {
      print(producto.toString());
      print(e);
      return false; // Retorna false en caso de error
    }
  }

  static Future<List<Producto>> obtenerProductosPorPagina(int pagina) async {
    try {
      final db = await DatabaseController().database;

      int offset = (pagina - 1) * 9;

      final List<Map<String, dynamic>> resultado = await db.rawQuery('''
      SELECT idProducto, idUnidad, codigoProducto, nombreProducto, precioProducto, stockActual, stockMinimo, stockMaximo, rutaImagen
      FROM Productos
      LIMIT 9 OFFSET ?
    ''', [offset]);

      if (resultado.isEmpty) {
        print('No se encontraron productos en la página $pagina');
      }

      List<Producto> productos = [];
      for (var item in resultado) {
        productos.add(Producto(
          idUnidad: item['idUnidad'] ?? 0,
          codigoProducto: item['codigoProducto'] ?? '',
          nombreProducto: item['nombreProducto'] ?? '',
          precioProducto: item['precioProducto'] ?? 0.0,
          stockActual: item['stockActual'] ?? 0.0,
          stockMinimo: item['stockMinimo'] ?? 0.0,
          stockMaximo: item['stockMaximo'] ?? 0.0,
          rutaImagen: item['rutaImagen'],
        ));
      }

      print(
          'Productos obtenidos desde la base de datos: $productos'); // Agregar para depurar
      return productos;
    } catch (e) {
      print('Error al obtener productos desde la base de datos: $e');
      return []; // Retornar una lista vacía en caso de error
    }
  }
}
