// test/producto_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI (ideal para desktop y CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir base de datos en memoria y crear las tablas necesarias para Producto
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Tabla Unidades (necesaria para el campo idUnidad)
          await db.execute('''
            CREATE TABLE Unidades (
              idUnidad INTEGER PRIMARY KEY AUTOINCREMENT,
              tipoUnidad TEXT NOT NULL UNIQUE
            )
          ''');
          // Tabla Categorias (para asignar categorías a productos)
          await db.execute('''
            CREATE TABLE Categorias (
              idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreCategoria TEXT UNIQUE
            )
          ''');
          // Tabla Productos
          await db.execute('''
            CREATE TABLE Productos (
              idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
              idUnidad INTEGER,
              codigoProducto TEXT,
              nombreProducto TEXT NOT NULL UNIQUE,
              precioProducto REAL NOT NULL,
              stockActual REAL,
              stockMinimo REAL NOT NULL,
              stockMaximo REAL,
              estaDisponible INTEGER DEFAULT 1,
              rutaImagen TEXT,
              fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
              fechaModificacion DATETIME DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          // Tabla ProductosCategorias
          await db.execute('''
            CREATE TABLE ProductosCategorias (
              idCategoria INTEGER,
              idProducto INTEGER,
              PRIMARY KEY (idCategoria, idProducto)
            )
          ''');
          // Tabla DetallesVentas (si se requiere para obtenerProductosPorFechas)
          await db.execute('''
            CREATE TABLE DetallesVentas (
              idProducto INTEGER,
              idLote INTEGER,
              idVenta INTEGER,
              cantidadProducto INTEGER NOT NULL,
              precioUnidadProducto REAL NOT NULL,
              subtotalProducto REAL NOT NULL,
              gananciaProducto REAL NOT NULL,
              descuentoProducto REAL
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test en el singleton de DatabaseController
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('crearProducto inserta un producto y asigna categorías', () async {
    final db = await DatabaseController().database;
    // Insertar un registro en Unidades
    int idUnidad = await db.insert('Unidades', {'tipoUnidad': 'Unidad Test'});
    // Insertar una categoría en Categorias
    int idCategoria = await db.insert('Categorias', {'nombreCategoria': 'Categoria Test'});
    // Crear objeto Categoria (asumiendo que el modelo tiene estas propiedades)
    Categoria categoria = Categoria(idCategoria: idCategoria, nombreCategoria: 'Categoria Test');

    // Crear un producto
    Producto producto = Producto(
      idUnidad: idUnidad,
      codigoProducto: 'COD123',
      nombreProducto: 'Producto Test',
      precioProducto: 99.99,
      stockMinimo: 10,
      stockMaximo: 100,
      rutaImagen: 'ruta/test.png',
    );

    bool creado = await Producto.crearProducto(producto, [categoria]);
    expect(creado, isTrue);

    // Verificar que el producto se insertó
    final productos = await Producto.obtenerProductosPorNombre('Producto Test');
    expect(productos.length, equals(1));
    expect(productos.first.nombreProducto, equals('Producto Test'));

    // Opcional: verificar la relación en ProductosCategorias
    final rel = await db.query('ProductosCategorias',
        where: 'idProducto = ?', whereArgs: [productos.first.idProducto]);
    expect(rel.length, equals(1));
    expect(rel.first['idCategoria'], equals(idCategoria));
  });

  test('obtenerProductoPorID retorna el producto correcto', () async {
    final db = await DatabaseController().database;
    // Insertar datos en Unidades y Categorias
    int idUnidad = await db.insert('Unidades', {'tipoUnidad': 'Unidad Test'});
    int idCategoria = await db.insert('Categorias', {'nombreCategoria': 'Categoria Test'});
    Categoria categoria = Categoria(idCategoria: idCategoria, nombreCategoria: 'Categoria Test');

    Producto producto = Producto(
      idUnidad: idUnidad,
      codigoProducto: 'COD456',
      nombreProducto: 'Producto ID Test',
      precioProducto: 49.99,
      stockMinimo: 5,
      stockMaximo: 50,
      rutaImagen: 'ruta/test2.png',
    );

    bool creado = await Producto.crearProducto(producto, [categoria]);
    expect(creado, isTrue);

    // Buscar por nombre para obtener el ID asignado
    List<Producto> productos = await Producto.obtenerProductosPorNombre('Producto ID Test');
    expect(productos.length, equals(1));
    int? idProducto = productos.first.idProducto;
    expect(idProducto, isNotNull);

    Producto? productoObtenido = await Producto.obtenerProductoPorID(idProducto!);
    expect(productoObtenido, isNotNull);
    expect(productoObtenido!.nombreProducto, equals('Producto ID Test'));
  });

  test('actualizarProducto modifica el producto', () async {
    final db = await DatabaseController().database;
    // Insertar datos en Unidades y Categorias
    int idUnidad = await db.insert('Unidades', {'tipoUnidad': 'Unidad Test'});
    int idCategoria = await db.insert('Categorias', {'nombreCategoria': 'Categoria Test'});
    Categoria categoria = Categoria(idCategoria: idCategoria, nombreCategoria: 'Categoria Test');

    Producto producto = Producto(
      idUnidad: idUnidad,
      codigoProducto: 'COD789',
      nombreProducto: 'Producto Update Test',
      precioProducto: 20.0,
      stockMinimo: 2,
      stockMaximo: 20,
      rutaImagen: 'ruta/test3.png',
    );

    bool creado = await Producto.crearProducto(producto, [categoria]);
    expect(creado, isTrue);

    // Obtener el producto y actualizar campos
    List<Producto> productos = await Producto.obtenerProductosPorNombre('Producto Update Test');
    expect(productos.length, equals(1));
    Producto prod = productos.first;
    prod.precioProducto = 30.0;
    prod.nombreProducto = 'Producto Update Test Modified';
    bool actualizado = await Producto.actualizarProducto(prod);
    expect(actualizado, isTrue);

    // Verificar la actualización
    Producto? actualizadoProducto = await Producto.obtenerProductoPorID(prod.idProducto!);
    expect(actualizadoProducto, isNotNull);
    expect(actualizadoProducto!.precioProducto, equals(30.0));
    expect(actualizadoProducto.nombreProducto, equals('Producto Update Test Modified'));
  });

  test('eliminarProducto marca el producto como no disponible', () async {
    final db = await DatabaseController().database;
    // Insertar datos en Unidades y Categorias
    int idUnidad = await db.insert('Unidades', {'tipoUnidad': 'Unidad Test'});
    int idCategoria = await db.insert('Categorias', {'nombreCategoria': 'Categoria Test'});
    Categoria categoria = Categoria(idCategoria: idCategoria, nombreCategoria: 'Categoria Test');

    Producto producto = Producto(
      idUnidad: idUnidad,
      codigoProducto: 'COD101',
      nombreProducto: 'Producto Delete Test',
      precioProducto: 15.0,
      stockMinimo: 1,
      stockMaximo: 10,
      rutaImagen: 'ruta/test4.png',
    );

    bool creado = await Producto.crearProducto(producto, [categoria]);
    expect(creado, isTrue);

    // Obtener el producto y luego "eliminarlo" (deshabilitarlo)
    List<Producto> productos = await Producto.obtenerProductosPorNombre('Producto Delete Test');
    expect(productos.length, equals(1));
    Producto prod = productos.first;
    bool eliminado = await Producto.eliminarProducto(prod.idProducto!);
    expect(eliminado, isTrue);

    // Verificar que el producto esté marcado como no disponible
    Producto? productoEliminado = await Producto.obtenerProductoPorID(prod.idProducto!);
    expect(productoEliminado, isNotNull);
    expect(productoEliminado!.estaDisponible, isFalse);
  });

  // Opcionalmente, se podrían agregar tests para insertarProductosPorDefecto o
  // obtenerProductosPorFechas, considerando la necesidad de simular o insertar datos en DetallesVentas.
}
