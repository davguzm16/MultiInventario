// test/volumenes_busqueda_productos_test.dart
import 'dart:math';
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

    // Insertar 50,000 productos de prueba
    for (int i = 0; i < 50000; i++) {
      await testDb.insert('Productos', {
        'nombreProducto': 'Producto $i',
        'precioProducto': 10.0,
        'stockActual': 100.0,
        'stockMinimo': 10.0,
        'stockMaximo': 200.0,
        'estaDisponible': 1,
      });
    }
  });

  tearDown(() async {
    await testDb.close();
    clearTestDatabase();
  });

  test('Prueba de estrés: búsqueda masiva de productos', () async {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    int totalEncontrados = 0;
    // Realizar 1000 búsquedas con términos aleatorios.
    for (int i = 0; i < 1000; i++) {
      int randomNumber = random.nextInt(50000);
      List<Map<String, dynamic>> resultados = await testDb.rawQuery(
        'SELECT * FROM Productos WHERE nombreProducto LIKE ?',
        ['%Producto $randomNumber%'],
      );
      totalEncontrados += resultados.length;
    }
    stopwatch.stop();
    print('Tiempo para 1000 búsquedas: ${stopwatch.elapsedMilliseconds} ms');
    print('Total de registros encontrados en búsquedas: $totalEncontrados');
    // Solo se imprime para evaluar rendimiento, no se hace un expect sobre el tiempo.
  });
}
