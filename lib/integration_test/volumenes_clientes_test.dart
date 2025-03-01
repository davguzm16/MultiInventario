import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/cliente.dart';
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
    // Abrir base de datos en memoria y crear la tabla Clientes.
    testDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Clientes (
              idCliente INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreCliente TEXT NOT NULL,
              dniCliente TEXT,
              correoCliente TEXT,
              esDeudor INTEGER NOT NULL
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

  test('Prueba de volúmenes: inserción masiva de clientes', () async {
    final int totalClientes = 50000;
    final stopwatchInsert = Stopwatch()..start();

    for (int i = 0; i < totalClientes; i++) {
      await testDb.insert('Clientes', {
        'nombreCliente': 'Cliente $i',
        'dniCliente': 'DNI$i',
        'correoCliente': 'cliente$i@test.com',
        'esDeudor': i % 2, // alterna entre 0 y 1
      });
    }

    stopwatchInsert.stop();
    print('Tiempo de inserción de $totalClientes clientes: ${stopwatchInsert.elapsedMilliseconds} ms');

    final List<Map<String, dynamic>> result = await testDb.rawQuery('SELECT COUNT(*) as count FROM Clientes');
    final count = result.first['count'] as int;
    expect(count, equals(totalClientes));
  });
}
