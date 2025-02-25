import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:path/path.dart' hide equals;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  // Inicializamos sqflite FFI para entornos de prueba
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Pruebas Unitarias de Producto', () {
    // Antes de cada prueba eliminamos la base de datos para iniciar con un estado limpio
    setUp(() async {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'multiinventario.db');
      if (await File(path).exists()) {
        await deleteDatabase(path);
      }
      // Se insertan datos por defecto (categorías y unidades) si es necesario
      await DatabaseController.insertDefaultData();
    });

    test('Creación de producto', () async {
      // Producto típico para una empresa de abarrotes: "Arroz"
      final producto = Producto(
        idUnidad: 1,
        codigoProducto: 'A001',
        nombreProducto: 'Arroz',
        precioProducto: 1.50,
        stockActual: 100,
        stockMinimo: 10,
        stockMaximo: 200,
        rutaImagen: 'lib/assets/imagenes/arroz.png',
        estaDisponible: true,
      );

      // Se crea el producto sin asignar categorías (lista vacía)
      bool creado = await Producto.crearProducto(producto, []);
      expect(creado, isTrue,
          reason: 'El producto "Arroz" debe crearse correctamente.');

      // Verificamos la inserción buscando por nombre
      final productos = await Producto.obtenerProductosPorNombre('Arroz');
      expect(productos.isNotEmpty, isTrue,
          reason: 'Se debe encontrar al menos un producto con nombre "Arroz".');
      expect(productos.first.nombreProducto, equals('Arroz'));
    });

    test('Modificación de producto', () async {
      // Creamos un producto: "Frijol"
      final producto = Producto(
        idUnidad: 1,
        codigoProducto: 'A002',
        nombreProducto: 'Frijol',
        precioProducto: 2.00,
        stockActual: 50,
        stockMinimo: 5,
        stockMaximo: 100,
        rutaImagen: 'lib/assets/imagenes/frijol.png',
        estaDisponible: true,
      );
      bool creado = await Producto.crearProducto(producto, []);
      expect(creado, isTrue,
          reason: 'El producto "Frijol" debe crearse correctamente.');

      // Obtenemos el producto creado buscando por su nombre
      final listaFrijol = await Producto.obtenerProductosPorNombre('Frijol');
      expect(listaFrijol.isNotEmpty, isTrue);
      final productoCreado = listaFrijol.first;

      // Modificamos algunos atributos: cambiamos nombre y precio
      final productoModificado = Producto(
        idProducto: productoCreado.idProducto,
        idUnidad: productoCreado.idUnidad,
        codigoProducto: productoCreado.codigoProducto,
        nombreProducto: 'Frijol Rojo',
        precioProducto: 2.50,
        stockActual: productoCreado.stockActual,
        stockMinimo: productoCreado.stockMinimo,
        stockMaximo: productoCreado.stockMaximo,
        rutaImagen: productoCreado.rutaImagen,
        estaDisponible: productoCreado.estaDisponible,
      );

      bool modificado = await Producto.actualizarProducto(productoModificado);
      expect(modificado, isTrue,
          reason: 'El producto debe actualizarse correctamente.');

      // Verificamos que se hayan guardado los cambios
      final productoVerificado =
      await Producto.obtenerProductoPorID(productoCreado.idProducto!);
      expect(productoVerificado, isNotNull);
      expect(productoVerificado!.nombreProducto, equals('Frijol Rojo'));
      expect(productoVerificado.precioProducto, equals(2.50));
    });

    test('Eliminación de producto (deshabilitación)', () async {
      // Creamos un producto: "Aceite"
      final producto = Producto(
        idUnidad: 1,
        codigoProducto: 'A003',
        nombreProducto: 'Aceite',
        precioProducto: 3.00,
        stockActual: 30,
        stockMinimo: 5,
        stockMaximo: 50,
        rutaImagen: 'lib/assets/imagenes/aceite.png',
        estaDisponible: true,
      );
      bool creado = await Producto.crearProducto(producto, []);
      expect(creado, isTrue,
          reason: 'El producto "Aceite" debe crearse correctamente.');

      // Obtenemos el producto para conocer su ID
      final listaAceite =
      await Producto.obtenerProductosPorNombre('Aceite');
      expect(listaAceite.isNotEmpty, isTrue);
      final productoCreado = listaAceite.first;

      // Eliminamos (deshabilitamos) el producto
      bool eliminado =
      await Producto.eliminarProducto(productoCreado.idProducto!);
      expect(eliminado, isTrue,
          reason: 'El producto debe ser eliminado (deshabilitado) correctamente.');

      // Verificamos que el producto tenga estaDisponible en false
      final productoEliminado =
      await Producto.obtenerProductoPorID(productoCreado.idProducto!);
      expect(productoEliminado, isNotNull);
      expect(productoEliminado!.estaDisponible, isFalse,
          reason: 'El producto debe estar deshabilitado.');
    });

    test('Filtrado de productos por nombre', () async {
      // Creamos dos productos: "Azúcar" y "Sal"
      final productosData = [
        Producto(
          idUnidad: 1,
          codigoProducto: 'A004',
          nombreProducto: 'Azúcar',
          precioProducto: 0.80,
          stockActual: 200,
          stockMinimo: 20,
          stockMaximo: 500,
          rutaImagen: 'lib/assets/imagenes/azucar.png',
          estaDisponible: true,
        ),
        Producto(
          idUnidad: 1,
          codigoProducto: 'A005',
          nombreProducto: 'Sal',
          precioProducto: 0.50,
          stockActual: 150,
          stockMinimo: 15,
          stockMaximo: 300,
          rutaImagen: 'lib/assets/imagenes/sal.png',
          estaDisponible: true,
        ),
      ];

      for (var p in productosData) {
        bool creado = await Producto.crearProducto(p, []);
        expect(creado, isTrue);
      }

      // Filtramos productos que contengan "Azúcar"
      final productosFiltrados =
      await Producto.obtenerProductosPorNombre('Azúcar');
      expect(productosFiltrados.length, greaterThanOrEqualTo(1));
      expect(productosFiltrados.first.nombreProducto, equals('Azúcar'));
    });

    test('Obtener producto por ID inexistente', () async {
      final producto = await Producto.obtenerProductoPorID(9999);
      expect(producto, isNull,
          reason:
          'No debe encontrarse producto con ID inexistente.');
    });

    test('Obtener productos por fechas sin detalles de venta', () async {
      // Como no se han insertado detalles de venta, se espera una lista vacía.
      DateTime inicio = DateTime.now().subtract(Duration(days: 30));
      DateTime fin = DateTime.now();
      final productos =
      await Producto.obtenerProductosPorFechas(inicio, fin);
      expect(productos, isEmpty,
          reason:
          'No se deben obtener productos sin detalles de venta.');
    });
  });
}
