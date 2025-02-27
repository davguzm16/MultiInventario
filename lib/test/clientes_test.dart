// test/cliente_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializa sqflite en modo FFI (útil para desktop y CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir la base de datos en memoria y crear las tablas necesarias
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Crear la tabla de Clientes (asegúrate de que la definición coincida con la de producción)
          await db.execute('''
            CREATE TABLE Clientes (
              idCliente INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreCliente TEXT NOT NULL,
              dniCliente TEXT,
              correoCliente TEXT,
              esDeudor BOOLEAN DEFAULT 0
            )
          ''');
          // Crear la tabla de Ventas (usada en algunos métodos de Cliente)
          await db.execute('''
            CREATE TABLE Ventas (
              idVenta INTEGER PRIMARY KEY AUTOINCREMENT,
              idCliente INTEGER,
              codigoBoleta TEXT NOT NULL UNIQUE,
              fechaVenta DATETIME DEFAULT CURRENT_TIMESTAMP,
              montoTotal REAL NOT NULL,
              montoCancelado REAL,
              esAlContado BOOLEAN DEFAULT 1,
              FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test en el DatabaseController
    setTestDatabase(db);
  });

  tearDown(() async {
    // Cerrar la base de datos luego de cada test y limpiar la inyección
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('crearCliente inserta un cliente y retorna un id > 0', () async {
    final cliente = Cliente(
      nombreCliente: 'Juan Perez',
      dniCliente: '12345678',
      correoCliente: 'juan@example.com',
      esDeudor: false,
    );
    final id = await Cliente.crearCliente(cliente);
    expect(id, isNotNull);
    expect(id, greaterThan(0));
  });

  test('obtenerClientePorId retorna el cliente correcto', () async {
    final cliente = Cliente(
      nombreCliente: 'Maria Garcia',
      dniCliente: '87654321',
      correoCliente: 'maria@example.com',
      esDeudor: false,
    );
    final id = await Cliente.crearCliente(cliente);
    final clienteFromDb = await Cliente.obtenerClientePorId(id!);

    expect(clienteFromDb, isNotNull);
    expect(clienteFromDb!.nombreCliente, equals('Maria Garcia'));
    expect(clienteFromDb.dniCliente, equals('87654321'));
    expect(clienteFromDb.correoCliente, equals('maria@example.com'));
  });

  test('obtenerClientesPorNombre retorna una lista filtrada de clientes', () async {
    await Cliente.crearCliente(Cliente(
      nombreCliente: 'Alpha',
      dniCliente: '11111111',
      correoCliente: 'alpha@example.com',
      esDeudor: false,
    ));
    await Cliente.crearCliente(Cliente(
      nombreCliente: 'Beta',
      dniCliente: '22222222',
      correoCliente: 'beta@example.com',
      esDeudor: false,
    ));
    await Cliente.crearCliente(Cliente(
      nombreCliente: 'AlphaBeta',
      dniCliente: '33333333',
      correoCliente: 'alphabeta@example.com',
      esDeudor: true,
    ));

    final clientes = await Cliente.obtenerClientesPorNombre('Alpha');
    // Se esperan 2 clientes cuyos nombres contengan "Alpha"
    expect(clientes.length, equals(2));
  });

  test('obtenerClientesPorCarga retorna clientes paginados y filtrados por esDeudor', () async {
    // Insertar 10 clientes alternando esDeudor
    for (int i = 0; i < 10; i++) {
      await Cliente.crearCliente(Cliente(
        nombreCliente: 'Cliente $i',
        dniCliente: 'dni$i',
        correoCliente: 'cliente$i@example.com',
        esDeudor: i % 2 == 0,
      ));
    }

    // Primera carga sin filtro (máximo 8 clientes)
    final clientesCarga0 = await Cliente.obtenerClientesPorCarga(numeroCarga: 0);
    expect(clientesCarga0.length, equals(8));

    // Segunda carga (los restantes, en este caso 2)
    final clientesCarga1 = await Cliente.obtenerClientesPorCarga(numeroCarga: 1);
    expect(clientesCarga1.length, equals(2));

    // Filtrar por clientes deudores (en 10 clientes, los índices pares serán deudores: 5 en total)
    final clientesDeudores = await Cliente.obtenerClientesPorCarga(numeroCarga: 0, esDeudor: true);
    expect(clientesDeudores.length, equals(5));
  });

  test('obtenerTotalDeVentas retorna la suma de ventas del cliente', () async {
    // Crear un cliente y asociarle dos ventas
    final cliente = Cliente(
      nombreCliente: 'Pedro Martinez',
      dniCliente: '33333333',
      correoCliente: 'pedro@example.com',
      esDeudor: false,
    );
    final id = await Cliente.crearCliente(cliente);
    final db = await DatabaseController().database;

    await db.insert('Ventas', {
      'idCliente': id,
      'codigoBoleta': 'TEST001', // valor dummy único
      'montoTotal': 100.0,
      'fechaVenta': DateTime.now().toIso8601String()
    });
    await db.insert('Ventas', {
      'idCliente': id,
      'codigoBoleta': 'TEST002', // otro valor dummy único
      'montoTotal': 50.0,
      'fechaVenta': DateTime.now().toIso8601String()
    });

    // Crear una instancia de Cliente con id para llamar al metodo de instancia
    final clienteTest = Cliente(
      idCliente: id,
      nombreCliente: '',
      dniCliente: '',
      correoCliente: '',
      esDeudor: false,
    );
    final total = await clienteTest.obtenerTotalDeVentas();
    expect(total, equals(150.0));
  });

  test('obtenerFechaUltimaVenta retorna la fecha más reciente de venta', () async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(days: 1));

    final cliente = Cliente(
      nombreCliente: 'Laura Gomez',
      dniCliente: '44444444',
      correoCliente: 'laura@example.com',
      esDeudor: false,
    );
    final id = await Cliente.crearCliente(cliente);
    final db = await DatabaseController().database;

    await db.insert('Ventas', {
      'idCliente': id,
      'codigoBoleta': 'TEST001', // Valor dummy único
      'montoTotal': 80.0,
      'fechaVenta': earlier.toIso8601String()
    });
    await db.insert('Ventas', {
      'idCliente': id,
      'codigoBoleta': 'TEST002', // Otro valor dummy único
      'montoTotal': 120.0,
      'fechaVenta': now.toIso8601String()
    });

    final clienteTest = Cliente(
      idCliente: id,
      nombreCliente: '',
      dniCliente: '',
      correoCliente: '',
      esDeudor: false,
    );
    final fechaUltimaVenta = await clienteTest.obtenerFechaUltimaVenta();

    expect(fechaUltimaVenta, isNotNull);
    expect(fechaUltimaVenta!.isAtSameMomentAs(now), isTrue);
  });
}
