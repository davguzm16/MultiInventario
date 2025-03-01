// test/volumenes_actualizacion_stock_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;
  late Database testDb;

  setUp(() async {
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
    setTestDatabase(testDb);
    // Insertar un producto de prueba
    await testDb.insert('Productos', {
      'nombreProducto': 'Producto Stress',
      'precioProducto': 10.0,
      'stockActual': 100.0,
      'stockMinimo': 10.0,
      'stockMaximo': 200.0,
      'estaDisponible': 1,
    });
  });

  tearDown(() async {
    await testDb.close();
    clearTestDatabase();
  });

  test('Prueba de estrés: actualización masiva de stock', () async {
    final stopwatch = Stopwatch()..start();
    // Actualizar el stock del producto "Producto Stress" 50,000 veces.
    for (int i = 0; i < 50000; i++) {
      await testDb.rawUpdate(
        'UPDATE Productos SET stockActual = stockActual - 1 WHERE nombreProducto = ?',
        ['Producto Stress'],
      );
    }
    stopwatch.stop();
    print('Tiempo para 50,000 actualizaciones: ${stopwatch.elapsedMilliseconds} ms');

    // Verificar el stock final: 100 - 50000 = -49900.
    final List<Map<String, dynamic>> resultado = await testDb.rawQuery(
      'SELECT stockActual FROM Productos WHERE nombreProducto = ?',
      ['Producto Stress'],
    );
    double stockFinal = resultado.first['stockActual'] as double;
    expect(stockFinal, equals(100.0 - 50000));
  });
}
