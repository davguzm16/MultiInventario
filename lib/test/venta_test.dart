import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multiinventario/main.dart' as app;
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_controller_test_helper.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Inicializar sqflite FFI.
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  // Crear e inyectar la base de datos de prueba antes de arrancar la aplicación.
  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        // Crear tabla Clientes
        await db.execute('''
        CREATE TABLE Clientes (
          idCliente INTEGER PRIMARY KEY AUTOINCREMENT,
          nombreCliente TEXT NOT NULL,
          dniCliente TEXT,
          correoCliente TEXT,
          esDeudor INTEGER NOT NULL
        )
      ''');
        // Crear tabla Productos
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
        // Crear tabla Ventas
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
        // Crear tabla DetallesVentas
        await db.execute('''
        CREATE TABLE DetallesVentas (
          idDetalle INTEGER PRIMARY KEY AUTOINCREMENT,
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

  // Ahora arranca la aplicación.
  app.main();
  await Future.delayed(Duration(seconds: 1)); // Opcional: esperar a que se inicialice la app.

  testWidgets('Actualiza stock tras registrar una venta', (WidgetTester tester) async {
    // Para asegurarnos de que la app está lista.
    await tester.pumpAndSettle();

    // Crear un producto con stock inicial de 100.
    Producto producto = Producto(
      nombreProducto: 'Producto Test',
      precioProducto: 50.0,
      stockMinimo: 5.0,
      stockActual: 100.0,
      rutaImagen: '',
      idUnidad: 1,
    );
    bool productoCreado = await Producto.crearProducto(producto, []);
    expect(productoCreado, isTrue);

    // Recuperar el ID asignado al producto (si es que no se asignó en el objeto).
    List<Map<String, dynamic>> productRows = await db.rawQuery(
      'SELECT idProducto FROM Productos WHERE nombreProducto = ?',
      [producto.nombreProducto],
    );
    expect(productRows.length, equals(1));
    int productId = productRows.first['idProducto'] as int;

    // Registrar un cliente.
    Cliente cliente = Cliente(
      nombreCliente: 'Cliente Test',
      dniCliente: '12345678',
      correoCliente: 'cliente@test.com',
      esDeudor: false,
    );
    int? idCliente = await Cliente.crearCliente(cliente);
    expect(idCliente, isNotNull);

    // Crear un detalle de venta que indique la venta de 10 unidades.
    DetalleVenta detalle = DetalleVenta(
      idProducto: productId,
      idLote: 1, // Suponiendo un valor para idLote
      cantidadProducto: 10,
      precioUnidadProducto: 50.0,
      subtotalProducto: 500.0,
      gananciaProducto: 10.0,
      descuentoProducto: 0.0,
    );

    // Registrar una venta.
    Venta venta = Venta(
      idCliente: idCliente!,
      montoTotal: 500.0, // 50 * 10
      montoCancelado: 500.0,
      esAlContado: true,
    );
    bool ventaCreada = await Venta.crearVenta(venta, [detalle]);
    expect(ventaCreada, isTrue);

    // Consultar el stock actualizado del producto.
    List<Map<String, dynamic>> resultado = await db.rawQuery(
      'SELECT stockActual FROM Productos WHERE idProducto = ?',
      [productId],
    );
    // Suponiendo que la lógica actualiza el stock descontando 10 unidades.
    double stockActualizado = resultado.first['stockActual'] as double;
    expect(stockActualizado, equals(90.0));
  });
}
