// test/producto_categoria_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI (ideal para desktop/CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Crear base de datos en memoria con las tablas necesarias:
    // - Categorias: idCategoria, nombreCategoria.
    // - Productos: idProducto, idUnidad, nombreProducto, precioProducto, stockActual, stockMinimo, rutaImagen, estaDisponible.
    // - ProductosCategorias: idProducto, idCategoria.
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Tabla Categorias
          await db.execute('''
            CREATE TABLE Categorias (
              idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreCategoria TEXT UNIQUE
            )
          ''');
          // Tabla Productos (definición mínima para las pruebas)
          await db.execute('''
            CREATE TABLE Productos (
              idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
              idUnidad INTEGER,
              nombreProducto TEXT,
              precioProducto REAL,
              stockActual REAL,
              stockMinimo REAL,
              rutaImagen TEXT,
              estaDisponible INTEGER
            )
          ''');
          // Tabla ProductosCategorias
          await db.execute('''
            CREATE TABLE ProductosCategorias (
              idProducto INTEGER,
              idCategoria INTEGER,
              PRIMARY KEY (idProducto, idCategoria)
            )
          ''');
        },
      ),
    );
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  group('ProductoCategoria', () {
    test('asignarRelacion inserta relación en ProductosCategorias', () async {
      final db = await DatabaseController().database;
      // Llamar al método con valores válidos.
      await ProductoCategoria.asignarRelacion(1, 1);

      // Verificar que se inserte en la tabla ProductosCategorias.
      final List<Map<String, dynamic>> result = await db.rawQuery(
          'SELECT * FROM ProductosCategorias WHERE idProducto = ? AND idCategoria = ?',
          [1, 1]);
      expect(result.length, equals(1));
    });

    test('asignarRelacion no inserta relación si los IDs son inválidos', () async {
      final db = await DatabaseController().database;
      // Pasar null o números negativos
      await ProductoCategoria.asignarRelacion(null, 1);
      await ProductoCategoria.asignarRelacion(1, -5);
      // Se espera que no se inserte nada
      final List<Map<String, dynamic>> result = await db.query('ProductosCategorias');
      expect(result.length, equals(0));
    });

    test('obtenerCategoriasDeProducto retorna las categorías asignadas', () async {
      final db = await DatabaseController().database;
      // Insertar categorías en la tabla Categorias.
      int idCat1 = await db.insert('Categorias', {'nombreCategoria': 'Cat1'});
      int idCat2 = await db.insert('Categorias', {'nombreCategoria': 'Cat2'});

      // Asignar relaciones para producto con idProducto = 10.
      await db.insert('ProductosCategorias', {
        'idProducto': 10,
        'idCategoria': idCat1,
      });
      await db.insert('ProductosCategorias', {
        'idProducto': 10,
        'idCategoria': idCat2,
      });

      List<Categoria> categorias = await ProductoCategoria.obtenerCategoriasDeProducto(10);
      expect(categorias.length, equals(2));
      expect(categorias.any((cat) => cat.nombreCategoria == 'Cat1'), isTrue);
      expect(categorias.any((cat) => cat.nombreCategoria == 'Cat2'), isTrue);
    });

    test('obtenerProductosPorCargaFiltrados retorna productos filtrados por categoría y stock', () async {
      final db = await DatabaseController().database;
      // Insertar una categoría.
      int idCat = await db.insert('Categorias', {'nombreCategoria': 'Filtrado'});
      Categoria cat = Categoria(idCategoria: idCat, nombreCategoria: 'Filtrado');

      // Insertar dos productos:
      // Producto 1: stockActual < stockMinimo (stockBajo = true)
      int idProd1 = await db.insert('Productos', {
        'idUnidad': 1,
        'nombreProducto': 'Producto Bajo',
        'precioProducto': 10.0,
        'stockActual': 5.0,
        'stockMinimo': 6.0,
        'rutaImagen': 'dummy',
        'estaDisponible': 1,
      });
      // Producto 2: stockActual >= stockMinimo (stockBajo = false)
      int idProd2 = await db.insert('Productos', {
        'idUnidad': 1,
        'nombreProducto': 'Producto Normal',
        'precioProducto': 20.0,
        'stockActual': 10.0,
        'stockMinimo': 5.0,
        'rutaImagen': 'dummy',
        'estaDisponible': 1,
      });
      // Asignar la categoría a ambos productos.
      await db.insert('ProductosCategorias', {
        'idProducto': idProd1,
        'idCategoria': idCat,
      });
      await db.insert('ProductosCategorias', {
        'idProducto': idProd2,
        'idCategoria': idCat,
      });

      // Llamar al método filtrando por la categoría y stockBajo true.
      List<Producto> productosBajo = await ProductoCategoria.obtenerProductosPorCargaFiltrados(
        numeroCarga: 0,
        categorias: [cat],
        stockBajo: true,
      );
      expect(productosBajo.length, equals(1));
      expect(productosBajo.first.nombreProducto, equals('Producto Bajo'));

      // Llamar filtrando por stockBajo false.
      List<Producto> productosNoBajo = await ProductoCategoria.obtenerProductosPorCargaFiltrados(
        numeroCarga: 0,
        categorias: [cat],
        stockBajo: false,
      );
      expect(productosNoBajo.length, equals(1));
      expect(productosNoBajo.first.nombreProducto, equals('Producto Normal'));

      // Llamar sin filtro de stock (debe traer ambos)
      List<Producto> productosTodos = await ProductoCategoria.obtenerProductosPorCargaFiltrados(
        numeroCarga: 0,
        categorias: [cat],
      );
      expect(productosTodos.length, equals(2));
    });

    test('actualizarCategoriasProducto actualiza las relaciones del producto', () async {
      final db = await DatabaseController().database;
      // Insertar relaciones iniciales para producto id = 3.
      await db.insert('ProductosCategorias', {'idProducto': 3, 'idCategoria': 1});
      await db.insert('ProductosCategorias', {'idProducto': 3, 'idCategoria': 2});

      // Actualizar las categorías del producto, asignando sólo [3, 4]
      await ProductoCategoria.actualizarCategoriasProducto(3, [3, 4]);

      // Consultar las relaciones para el producto 3.
      List<Map<String, dynamic>> relaciones = await db.query(
        'ProductosCategorias',
        where: 'idProducto = ?',
        whereArgs: [3],
      );
      expect(relaciones.length, equals(2));
      List<int> ids = relaciones.map((r) => r['idCategoria'] as int).toList();
      expect(ids.contains(3), isTrue);
      expect(ids.contains(4), isTrue);
      expect(ids.contains(1), isFalse);
      expect(ids.contains(2), isFalse);
    });
  });
}
