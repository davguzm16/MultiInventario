import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multiinventario/main.dart' as app;
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/pages/inventory/inventory_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir la base de datos en memoria y crear las tablas necesarias.
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Tabla Unidades
          await db.execute('''
            CREATE TABLE Unidades (
              idUnidad INTEGER PRIMARY KEY AUTOINCREMENT,
              tipoUnidad TEXT NOT NULL UNIQUE
            )
          ''');
          // Tabla Categorias
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
          // Tabla DetallesVentas
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
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  testWidgets('InventoryPage muestra productos y actualiza la lista', (WidgetTester tester) async {
    final db = await DatabaseController().database;

    // Insertar una unidad y una categoría para la creación del producto.
    int idUnidad = await db.insert('Unidades', {'tipoUnidad': 'Unidad Test'});
    int idCategoria = await db.insert('Categorias', {'nombreCategoria': 'Categoria Test'});
    Categoria categoria = Categoria(idCategoria: idCategoria, nombreCategoria: 'Categoria Test');

    // Crear un producto.
    Producto producto = Producto(
      idUnidad: idUnidad,
      codigoProducto: 'PRD001',
      nombreProducto: 'Producto de Inventario',
      precioProducto: 100.0,
      stockMinimo: 10.0,
      stockActual: 50.0,
      stockMaximo: 100.0,
      rutaImagen: null,
      estaDisponible: true,
    );
    bool creado = await Producto.crearProducto(producto, [categoria]);
    expect(creado, isTrue);

    // Cargar la pantalla de inventario.
    await tester.pumpWidget(MaterialApp(home: InventoryPage()));
    await tester.pumpAndSettle();

    // Activar el modo de búsqueda (tocar el ícono de búsqueda).
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Buscar el TextField usando el key asignado.
    final searchFieldFinder = find.byKey(const Key('searchField'));
    expect(searchFieldFinder, findsOneWidget);
    await tester.enterText(searchFieldFinder, 'Producto de Inventario');
    await tester.pumpAndSettle();

    // En lugar de find.text, usamos un finder que filtre solo los widgets de tipo Text
    // (excluyendo el EditableText) para evitar encontrar más de uno.
    final productTextFinder = find.byWidgetPredicate((widget) =>
    widget is Text &&
        widget.data == 'Producto de Inventario');
    expect(productTextFinder.evaluate().length, equals(1));
  });
}
