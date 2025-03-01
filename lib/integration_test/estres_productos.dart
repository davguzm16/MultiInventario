import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializa sqflite FFI para el entorno de pruebas.
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  late Database testDb;

  setUp(() async {
    // Abrir base de datos en memoria y crear la tabla de Productos.
    testDb = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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
        },
      ),
    );
    // Inyectar la base de datos de prueba en el DatabaseController.
    setTestDatabase(testDb);
  });

  tearDown(() async {
    await testDb.close();
    clearTestDatabase();
  });

  test('Prueba de estrés: inserción masiva de productos', () async {
    // Número de productos a insertar.
    final int cantidad = 100000;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < cantidad; i++) {
      Producto producto = Producto(
        idUnidad: 1,
        codigoProducto: 'COD${i.toString().padLeft(5, '0')}',
        nombreProducto: 'Producto Stress $i',
        precioProducto: 10.0 + i,
        stockMinimo: 1.0,
        stockActual: 100.0,
        stockMaximo: 200.0,
        rutaImagen: null,
        estaDisponible: true,
      );
      bool creado = await Producto.crearProducto(producto, []);
      // Cada inserción debe ser exitosa.
      expect(creado, isTrue);
    }
    stopwatch.stop();
    print('Tiempo para insertar $cantidad productos: ${stopwatch.elapsedMilliseconds} ms');

    // Opcional: verificar el total de productos insertados
    final List<Map<String, dynamic>> result = await testDb.rawQuery('SELECT COUNT(*) as count FROM Productos');
    final count = result.first['count'] as int;
    expect(count, equals(cantidad));
  });
}
