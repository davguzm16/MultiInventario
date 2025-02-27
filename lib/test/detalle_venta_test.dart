// test/detalle_venta_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI (útil para desktop y CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Crear la tabla Productos con stockActual.
          await db.execute('''
            CREATE TABLE Productos (
              idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
              stockActual REAL
            )
          ''');
          // Crear la tabla DetallesVentas.
          await db.execute('''
            CREATE TABLE DetallesVentas (
              idProducto INTEGER,
              idLote INTEGER,
              idVenta INTEGER,
              cantidadProducto INTEGER,
              precioUnidadProducto REAL,
              subtotalProducto REAL,
              gananciaProducto REAL,
              descuentoProducto REAL
            )
          ''');
          // Crear la tabla Ventas (necesaria para obtenerDetallesPorFechas).
          await db.execute('''
            CREATE TABLE Ventas (
              idVenta INTEGER PRIMARY KEY AUTOINCREMENT,
              idCliente INTEGER,
              codigoBoleta TEXT NOT NULL,
              fechaVenta TEXT,
              montoTotal REAL,
              montoCancelado REAL,
              esAlContado INTEGER
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test en el DatabaseController.
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('asignarRelacion inserta detalle y actualiza stock del producto', () async {
    final db = await DatabaseController().database;
    // Insertar un producto con stockActual = 100.
    int productId = await db.insert('Productos', {'stockActual': 100.0});
    // Crear un detalle de venta.
    DetalleVenta detalle = DetalleVenta(
      idProducto: productId,
      idLote: 1,
      cantidadProducto: 10,
      precioUnidadProducto: 5.0,
      subtotalProducto: 50.0,
      gananciaProducto: 10.0,
      descuentoProducto: 0.0,
    );
    // Asignar relación con idVenta = 1.
    bool success = await DetalleVenta.asignarRelacion(1, detalle);
    expect(success, isTrue);

    // Verificar que se insertó en DetallesVentas.
    List<Map<String, dynamic>> detalles = await db.rawQuery(
      'SELECT * FROM DetallesVentas WHERE idVenta = ?',
      [1],
    );
    expect(detalles.length, equals(1));
    expect(detalles.first['idProducto'], equals(productId));
    expect(detalles.first['cantidadProducto'], equals(10));

    // Verificar que se actualizó el stock del producto: 100 - 10 = 90.
    List<Map<String, dynamic>> productos = await db.rawQuery(
      'SELECT * FROM Productos WHERE idProducto = ?',
      [productId],
    );
    expect(productos.length, equals(1));
    double updatedStock = productos.first['stockActual'] as double;
    expect(updatedStock, equals(90.0));
  });

  test('deshacerRelacion restaura stock y elimina detalles de venta', () async {
    final db = await DatabaseController().database;
    // Insertar un producto con stockActual = 100.
    int productId = await db.insert('Productos', {'stockActual': 100.0});
    // Asignar un detalle de venta (cantidad 15) con idVenta = 2.
    DetalleVenta detalle = DetalleVenta(
      idProducto: productId,
      idLote: 1,
      cantidadProducto: 15,
      precioUnidadProducto: 4.0,
      subtotalProducto: 60.0,
      gananciaProducto: 12.0,
      descuentoProducto: 0.0,
    );
    bool asignado = await DetalleVenta.asignarRelacion(2, detalle);
    expect(asignado, isTrue);

    // Verificar que el stock se actualizó: 100 - 15 = 85.
    List<Map<String, dynamic>> productos = await db.rawQuery(
      'SELECT * FROM Productos WHERE idProducto = ?',
      [productId],
    );
    double stockAfterAsignar = productos.first['stockActual'] as double;
    expect(stockAfterAsignar, equals(85.0));

    // Deshacer la relación para idVenta = 2.
    bool deshecho = await DetalleVenta.deshacerRelacion(2);
    expect(deshecho, isTrue);

    // Verificar que ya no existen detalles para idVenta = 2.
    List<Map<String, dynamic>> detalles = await db.rawQuery(
      'SELECT * FROM DetallesVentas WHERE idVenta = ?',
      [2],
    );
    expect(detalles.length, equals(0));

    // Verificar que el stock se restauró: 85 + 15 = 100.
    List<Map<String, dynamic>> productosRestored = await db.rawQuery(
      'SELECT * FROM Productos WHERE idProducto = ?',
      [productId],
    );
    double restoredStock = productosRestored.first['stockActual'] as double;
    expect(restoredStock, equals(100.0));
  });

  test('obtenerDetallesPorVenta retorna los detalles correspondientes', () async {
    final db = await DatabaseController().database;
    // Insertar un producto (stock no es relevante en este test).
    int productId = await db.insert('Productos', {'stockActual': 50.0});
    // Insertar manualmente un detalle de venta para idVenta = 3.
    await db.insert('DetallesVentas', {
      'idProducto': productId,
      'idLote': 1,
      'idVenta': 3,
      'cantidadProducto': 5,
      'precioUnidadProducto': 6.0,
      'subtotalProducto': 30.0,
      'gananciaProducto': 5.0,
      'descuentoProducto': 0.0,
    });
    // Obtener detalles para la venta con idVenta = 3.
    List<DetalleVenta> detalles = await DetalleVenta.obtenerDetallesPorVenta(3);
    expect(detalles.length, equals(1));
    expect(detalles.first.idProducto, equals(productId));
    expect(detalles.first.cantidadProducto, equals(5));
  });

  test('obtenerDetallesPorFechas retorna detalles para ventas en el rango', () async {
    final db = await DatabaseController().database;
    // Definir fechas para ventas.
    DateTime fecha1 = DateTime.now().subtract(Duration(days: 2));
    DateTime fecha2 = DateTime.now().subtract(Duration(days: 1));
    DateTime fecha3 = DateTime.now();

    // Insertar tres ventas en la tabla Ventas.
    int ventaId1 = await db.insert('Ventas', {
      'idCliente': 1,
      'codigoBoleta': 'TEST-1',
      'fechaVenta': fecha1.toIso8601String(),
      'montoTotal': 50.0,
      'montoCancelado': 0.0,
      'esAlContado': 1,
    });
    int ventaId2 = await db.insert('Ventas', {
      'idCliente': 1,
      'codigoBoleta': 'TEST-2',
      'fechaVenta': fecha2.toIso8601String(),
      'montoTotal': 60.0,
      'montoCancelado': 0.0,
      'esAlContado': 1,
    });
    int ventaId3 = await db.insert('Ventas', {
      'idCliente': 1,
      'codigoBoleta': 'TEST-3',
      'fechaVenta': fecha3.toIso8601String(),
      'montoTotal': 70.0,
      'montoCancelado': 0.0,
      'esAlContado': 1,
    });

    // Insertar detalles para cada venta.
    await db.insert('DetallesVentas', {
      'idProducto': 1,
      'idLote': 1,
      'idVenta': ventaId1,
      'cantidadProducto': 2,
      'precioUnidadProducto': 5.0,
      'subtotalProducto': 10.0,
      'gananciaProducto': 2.0,
      'descuentoProducto': 0.0,
    });
    await db.insert('DetallesVentas', {
      'idProducto': 2,
      'idLote': 1,
      'idVenta': ventaId2,
      'cantidadProducto': 3,
      'precioUnidadProducto': 6.0,
      'subtotalProducto': 18.0,
      'gananciaProducto': 3.0,
      'descuentoProducto': 0.0,
    });
    await db.insert('DetallesVentas', {
      'idProducto': 3,
      'idLote': 1,
      'idVenta': ventaId3,
      'cantidadProducto': 4,
      'precioUnidadProducto': 7.0,
      'subtotalProducto': 28.0,
      'gananciaProducto': 4.0,
      'descuentoProducto': 0.0,
    });

    // Definir rango que incluya todas las ventas.
    DateTime inicio = fecha1.subtract(Duration(hours: 1));
    DateTime fin = fecha3.add(Duration(hours: 1));
    List<DetalleVenta> detalles = await DetalleVenta.obtenerDetallesPorFechas(inicio, fin);
    expect(detalles.length, equals(3));
  });
}
