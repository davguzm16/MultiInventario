import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializa sqflite en modo FFI y asigna el factory global.
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;
  late Database testDb;

  setUp(() async {
    // Abrir base de datos en memoria y crear la tabla Ventas.
    testDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Ventas (
              idVenta INTEGER PRIMARY KEY AUTOINCREMENT,
              idCliente INTEGER,
              codigoBoleta TEXT NOT NULL UNIQUE,
              fechaVenta DATETIME DEFAULT CURRENT_TIMESTAMP,
              montoTotal REAL NOT NULL,
              montoCancelado REAL,
              esAlContado INTEGER
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test.
    setTestDatabase(testDb);
  });

  tearDown(() async {
    await testDb.close();
    clearTestDatabase();
  });

  test('Prueba de volúmenes: inserción masiva de ventas', () async {
    final int totalVentas = 50000;
    final stopwatchInsert = Stopwatch()..start();

    // Insertar ventas; para simplicidad, usamos idCliente=1 en todas y generamos un código único.
    for (int i = 0; i < totalVentas; i++) {
      await testDb.insert('Ventas', {
        'idCliente': 1,
        'codigoBoleta': 'VTA${i.toString().padLeft(6, '0')}',
        'montoTotal': 100.0,
        'montoCancelado': 100.0,
        'esAlContado': 1,
      });
    }

    stopwatchInsert.stop();
    print('Tiempo de inserción de $totalVentas ventas: ${stopwatchInsert.elapsedMilliseconds} ms');

    final List<Map<String, dynamic>> result = await testDb.rawQuery('SELECT COUNT(*) as count FROM Ventas');
    final count = result.first['count'] as int;
    expect(count, equals(totalVentas));
  });
}
