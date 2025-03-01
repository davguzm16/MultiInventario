import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializa sqflite en modo FFI.
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  late Database testDb;

  setUp(() async {
    // Abrir base de datos en memoria y crear la tabla Productos.
    testDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Productos (
              idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreProducto TEXT NOT NULL,
              precioProducto REAL NOT NULL,
              stockActual REAL,
              stockMinimo REAL NOT NULL,
              stockMaximo REAL,
              estaDisponible INTEGER DEFAULT 1
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de prueba en el DatabaseController.
    setTestDatabase(testDb);
  });

  tearDown(() async {
    // Utilizar la instancia almacenada para cerrar la base de datos.
    await testDb.close();
    clearTestDatabase();
  });

  test('Prueba de volúmenes: inserción masiva y consulta de productos', () async {
    final int totalProductos = 50000;
    final stopwatchInsert = Stopwatch()..start();

    // Inserción masiva de productos
    for (int i = 0; i < totalProductos; i++) {
      await testDb.insert('Productos', {
        'nombreProducto': 'Producto $i',
        'precioProducto': 10.0 + i,
        'stockActual': 100.0,
        'stockMinimo': 10.0,
        'stockMaximo': 200.0,
        'estaDisponible': 1,
      });
    }
    stopwatchInsert.stop();
    print('Tiempo de inserción de $totalProductos productos: ${stopwatchInsert.elapsedMilliseconds} ms');

    // Realizar una consulta para obtener todos los productos disponibles.
    final stopwatchQuery = Stopwatch()..start();
    final List<Map<String, dynamic>> results = await testDb.rawQuery(
      'SELECT * FROM Productos WHERE estaDisponible = 1',
    );
    stopwatchQuery.stop();
    print('Tiempo de consulta: ${stopwatchQuery.elapsedMilliseconds} ms');

    // Verificar que se insertaron la cantidad esperada de productos.
    expect(results.length, equals(totalProductos));
  });
}
