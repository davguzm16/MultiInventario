// test/lote_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI para tests (ideal para desktop/CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir una base de datos en memoria y crear las tablas necesarias:
    // - Productos: con idProducto (PRIMARY KEY) y stockActual.
    // - Lotes: con las columnas utilizadas en el modelo Lote.
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Tabla Productos (se usará para actualizar stock)
          await db.execute('''
            CREATE TABLE Productos (
              idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
              stockActual REAL
            )
          ''');
          // Tabla Lotes (la estructura debe coincidir con la usada en el modelo)
          await db.execute('''
            CREATE TABLE Lotes (
              idLote INTEGER,
              idProducto INTEGER,
              cantidadActual INTEGER,
              cantidadComprada INTEGER,
              cantidadPerdida INTEGER,
              precioCompra REAL,
              precioCompraUnidad REAL,
              fechaCaducidad TEXT,
              fechaCompra TEXT,
              estaDisponible INTEGER
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test en el singleton de DatabaseController.
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('crearLote inserta un lote y actualiza stock del producto', () async {
    final db = await DatabaseController().database;
    // Insertar un producto con stockActual inicial (por ejemplo, 100)
    int productId = await db.insert('Productos', {'stockActual': 100.0});
    // Crear un lote para ese producto.
    // Notar que en crearLote se calcula nextId usando MAX(idLote)+1
    // y luego se llama a actualizarStockProducto.
    Lote lote = Lote(
      idProducto: productId,
      cantidadActual: 20,
      cantidadComprada: 20,
      cantidadPerdida: 0,
      precioCompra: 50.0,
      precioCompraUnidad: 50.0,
      fechaCaducidad: DateTime.now().add(Duration(days: 365)),
      fechaCompra: DateTime.now(),
      estaDisponible: true,
    );
    bool created = await Lote.crearLote(lote);
    expect(created, isTrue);

    // Verificar que se insertó el lote en la tabla Lotes
    List<Map<String, dynamic>> lotes = await db.rawQuery(
        'SELECT * FROM Lotes WHERE idProducto = ?', [productId]);
    expect(lotes.length, equals(1));

    // Según la lógica de actualizarStockProducto:
    // Si lote.estaDisponible es true y cantidadActual == cantidadComprada,
    // se actualiza el stock a: stockActual + (cantidadActual - stockActual) = cantidadActual.
    // Por lo tanto, stockActual del producto debe quedar igual a 20.
    List<Map<String, dynamic>> productRows = await db.rawQuery(
        'SELECT * FROM Productos WHERE idProducto = ?', [productId]);
    double newStock = productRows.first['stockActual'] as double;
    expect(newStock, equals(20.0));
  });

  test('obtenerLotePorId retorna el lote correcto', () async {
    final db = await DatabaseController().database;
    int productId = await db.insert('Productos', {'stockActual': 50.0});
    DateTime now = DateTime.now();
    // Insertar un lote manualmente en la tabla Lotes
    await db.insert('Lotes', {
      'idLote': 1,
      'idProducto': productId,
      'cantidadActual': 10,
      'cantidadComprada': 10,
      'cantidadPerdida': 0,
      'precioCompra': 100.0,
      'precioCompraUnidad': 100.0,
      'fechaCaducidad': now.add(Duration(days: 30)).toIso8601String(),
      'fechaCompra': now.toIso8601String(),
      'estaDisponible': 1,
    });
    Lote? lote = await Lote.obtenerLotePorId(productId, 1);
    expect(lote, isNotNull);
    expect(lote!.cantidadActual, equals(10));
  });

  test('obtenerLotesDeProducto retorna todos los lotes disponibles para un producto', () async {
    final db = await DatabaseController().database;
    int productId = await db.insert('Productos', {'stockActual': 100.0});
    DateTime now = DateTime.now();
    // Insertar dos lotes para el producto
    await db.insert('Lotes', {
      'idLote': 1,
      'idProducto': productId,
      'cantidadActual': 15,
      'cantidadComprada': 15,
      'cantidadPerdida': 0,
      'precioCompra': 200.0,
      'precioCompraUnidad': 200.0,
      'fechaCaducidad': now.add(Duration(days: 90)).toIso8601String(),
      'fechaCompra': now.toIso8601String(),
      'estaDisponible': 1,
    });
    await db.insert('Lotes', {
      'idLote': 2,
      'idProducto': productId,
      'cantidadActual': 25,
      'cantidadComprada': 25,
      'cantidadPerdida': 0,
      'precioCompra': 250.0,
      'precioCompraUnidad': 250.0,
      'fechaCaducidad': now.add(Duration(days: 60)).toIso8601String(),
      'fechaCompra': now.toIso8601String(),
      'estaDisponible': 1,
    });
    List<Lote> lotes = await Lote.obtenerLotesDeProducto(productId);
    expect(lotes.length, equals(2));
  });

  test('actualizarLote modifica un lote y actualiza stock del producto', () async {
    final db = await DatabaseController().database;
    // Insertar un producto con stockActual = 100
    int productId = await db.insert('Productos', {'stockActual': 100.0});
    DateTime now = DateTime.now();
    // Insertar un lote inicial
    await db.insert('Lotes', {
      'idLote': 1,
      'idProducto': productId,
      'cantidadActual': 30,
      'cantidadComprada': 30,
      'cantidadPerdida': 0,
      'precioCompra': 300.0,
      'precioCompraUnidad': 300.0,
      'fechaCaducidad': now.add(Duration(days: 180)).toIso8601String(),
      'fechaCompra': now.toIso8601String(),
      'estaDisponible': 1,
    });
    // Crear un objeto Lote con valores actualizados (por ejemplo, disminuir cantidadActual a 20)
    Lote updatedLote = Lote(
      idLote: 1,
      idProducto: productId,
      cantidadActual: 20,
      cantidadComprada: 30,
      cantidadPerdida: 0,
      precioCompra: 300.0,
      precioCompraUnidad: 300.0,
      fechaCaducidad: now.add(Duration(days: 180)),
      fechaCompra: now,
      estaDisponible: true,
    );
    bool updated = await Lote.actualizarLote(updatedLote);
    expect(updated, isTrue);

    // Verificar que el lote se actualizó en la tabla Lotes.
    List<Map<String, dynamic>> loteRows = await db.rawQuery(
        'SELECT * FROM Lotes WHERE idProducto = ? AND idLote = ?',
        [productId, 1]);
    expect(loteRows.first['cantidadActual'], equals(20));

    // Verificar que el stock del producto se actualizó.
    // En este caso, con esta lógica:
    // Cuando lote.estaDisponible es true y cantidadActual != cantidadComprada,
    // se ejecuta: UPDATE Productos SET stockActual = stockActual - (? - ?)
    // donde ? = cantidadComprada (30) y ? = cantidadActual (20)
    // Entonces, nuevo stock = 100 - (30 - 20) = 90.
    List<Map<String, dynamic>> productRows = await db.rawQuery(
        'SELECT * FROM Productos WHERE idProducto = ?', [productId]);
    double newStock = productRows.first['stockActual'] as double;
    expect(newStock, equals(90.0));
  });

  test('eliminarLote marca un lote como no disponible y actualiza stock del producto', () async {
    final db = await DatabaseController().database;
    // Insertar un producto con stockActual = 200
    int productId = await db.insert('Productos', {'stockActual': 200.0});
    DateTime now = DateTime.now();
    // Insertar un lote.
    await db.insert('Lotes', {
      'idLote': 1,
      'idProducto': productId,
      'cantidadActual': 50,
      'cantidadComprada': 50,
      'cantidadPerdida': 0,
      'precioCompra': 500.0,
      'precioCompraUnidad': 500.0,
      'fechaCaducidad': now.add(Duration(days: 365)).toIso8601String(),
      'fechaCompra': now.toIso8601String(),
      'estaDisponible': 1,
    });
    // Crear un objeto Lote representando el lote a eliminar.
    Lote lote = Lote(
      idLote: 1,
      idProducto: productId,
      cantidadActual: 50,
      cantidadComprada: 50,
      cantidadPerdida: 0,
      precioCompra: 500.0,
      precioCompraUnidad: 500.0,
      fechaCaducidad: now.add(Duration(days: 365)),
      fechaCompra: now,
      estaDisponible: true,
    );
    bool deleted = await Lote.eliminarLote(lote);
    expect(deleted, isTrue);

    // Verificar que el lote se marcó como no disponible.
    List<Map<String, dynamic>> loteRows = await db.rawQuery(
        'SELECT * FROM Lotes WHERE idProducto = ? AND idLote = ?',
        [productId, 1]);
    expect(loteRows.first['estaDisponible'], equals(0));

    // En la lógica de eliminarLote, se llama a actualizarStockProducto después de marcarlo como no disponible.
    // En actualizarStockProducto, si !(lote.estaDisponible) se ejecuta:
    // UPDATE Productos SET stockActual = stockActual - ? WHERE idProducto = ?
    // con ? = cantidadActual (50), por lo que nuevo stock = 200 - 50 = 150.
    List<Map<String, dynamic>> productRows = await db.rawQuery(
        'SELECT * FROM Productos WHERE idProducto = ?', [productId]);
    double newStock = productRows.first['stockActual'] as double;
    expect(newStock, equals(150.0));
  });

  test('obtenerLotesporFecha retorna lotes en el rango de fechas', () async {
    final db = await DatabaseController().database;
    DateTime now = DateTime.now();
    DateTime fechaCompra1 = now.subtract(Duration(days: 10));
    DateTime fechaCompra2 = now.subtract(Duration(days: 5));
    DateTime fechaCompra3 = now;

    // Insertar tres lotes con diferentes fechaCompra.
    await db.insert('Lotes', {
      'idLote': 1,
      'idProducto': 1,
      'cantidadActual': 10,
      'cantidadComprada': 10,
      'cantidadPerdida': 0,
      'precioCompra': 100.0,
      'precioCompraUnidad': 100.0,
      'fechaCaducidad': now.add(Duration(days: 30)).toIso8601String(),
      'fechaCompra': fechaCompra1.toIso8601String(),
      'estaDisponible': 1,
    });
    await db.insert('Lotes', {
      'idLote': 2,
      'idProducto': 1,
      'cantidadActual': 20,
      'cantidadComprada': 20,
      'cantidadPerdida': 0,
      'precioCompra': 200.0,
      'precioCompraUnidad': 200.0,
      'fechaCaducidad': now.add(Duration(days: 60)).toIso8601String(),
      'fechaCompra': fechaCompra2.toIso8601String(),
      'estaDisponible': 1,
    });
    await db.insert('Lotes', {
      'idLote': 3,
      'idProducto': 1,
      'cantidadActual': 30,
      'cantidadComprada': 30,
      'cantidadPerdida': 0,
      'precioCompra': 300.0,
      'precioCompraUnidad': 300.0,
      'fechaCaducidad': now.add(Duration(days: 90)).toIso8601String(),
      'fechaCompra': fechaCompra3.toIso8601String(),
      'estaDisponible': 1,
    });

    // Definir un rango que incluya los lotes 1 y 2.
    DateTime inicio = now.subtract(Duration(days: 11));
    DateTime fin = now.subtract(Duration(days: 4)); // Cambiado de 6 a 4 días

    List<Lote> lotes = await Lote.obtenerLotesporFecha(inicio, fin);
    expect(lotes.length, equals(2));
    // Verificar que se obtuvieron en orden ascendente por fechaCompra.
    expect(lotes.first.fechaCompra!.toIso8601String(), equals(fechaCompra1.toIso8601String()));
    expect(lotes.last.fechaCompra!.toIso8601String(), equals(fechaCompra2.toIso8601String()));
  });
}
