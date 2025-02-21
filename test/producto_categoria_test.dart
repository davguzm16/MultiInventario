import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Inicializar el soporte para pruebas en sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Pruebas de Categoria', () {
    test('Crear una categoría de abarrotes', () async {
      final categoria = Categoria(nombreCategoria: "Arroz");

      final resultado = await Categoria.crearCategoria(categoria);

      expect(resultado, true);
    });

    test('Obtener todas las categorías', () async {
      final categorias = await Categoria.obtenerCategorias();

      expect(categorias, isA<List<Categoria>>());
      expect(categorias.isNotEmpty, true);
    });
  });

  group('Pruebas de Producto', () {
    test('Crear un producto de abarrotes', () async {
      final producto = Producto(
        idUnidad: 1,
        nombreProducto: "Leche",
        precioProducto: 3.50,
        stockActual: 50,
        stockMinimo: 5,
        stockMaximo: 100,
      );

      final resultado = await Producto.crearProducto(producto, []);

      expect(resultado, true);
    });

    test('Obtener producto por ID', () async {
      final producto = await Producto.obtenerProductoPorID(1);

      expect(producto, isNotNull);
      expect(producto?.nombreProducto, "Leche");
    });

    test('Obtener productos por página', () async {
      final productos = await Producto.obtenerProductosPorPagina(1);

      expect(productos, isA<List<Producto>>());
    });
  });
}
