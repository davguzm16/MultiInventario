import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' hide equals;

void main() {
  // Inicializamos sqflite FFI para entornos de prueba
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Pruebas de Venta', () {
    // Antes de cada prueba eliminamos la base de datos para iniciar con un estado limpio
    setUp(() async {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'multiinventario.db');
      if (await File(path).exists()) {
        await deleteDatabase(path);
      }
      // Inicializamos la base de datos
      await DatabaseController().database;
    });

    test('Creación de venta exitosa', () async {
      // Creamos una venta con montoTotal > 5 para que se genere codigoBoleta
      Venta venta = Venta(
        idCliente: 1,
        montoTotal: 10.0,
        montoCancelado: 10.0,
        esAlContado: true,
      );

      bool creada = await Venta.crearVenta(venta, []);
      expect(creada, isTrue, reason: 'La venta debe crearse exitosamente');

      // Recuperamos la venta asumiendo que es la primera (ID 1)
      Venta? ventaRecuperada = await Venta.obtenerVentaPorID(1);
      expect(ventaRecuperada, isNotNull, reason: 'La venta creada debe poder recuperarse');
      expect(ventaRecuperada!.codigoBoleta, isNotNull, reason: 'La venta debe tener un código de boleta');
      expect(ventaRecuperada.codigoBoleta!.startsWith("002-"), isTrue,
          reason: 'El código de boleta debe iniciar con "002-"');
    });

    test('Obtener ventas por código', () async {
      // Creamos una venta para luego buscarla por código
      Venta venta = Venta(
        idCliente: 1,
        montoTotal: 15.0,
        montoCancelado: 15.0,
        esAlContado: true,
      );
      bool creada = await Venta.crearVenta(venta, []);
      expect(creada, isTrue);

      // Buscamos ventas cuyo código contenga "002-"
      List<Venta> ventas = await Venta.obtenerVentasPorCodigo("002-");
      expect(ventas, isNotEmpty, reason: 'Debe existir al menos una venta con código "002-"');
    });

    test('Obtener venta por ID', () async {
      // Creamos una venta con un idCliente específico
      Venta venta = Venta(
        idCliente: 2,
        montoTotal: 20.0,
        montoCancelado: 20.0,
        esAlContado: false,
      );
      bool creada = await Venta.crearVenta(venta, []);
      expect(creada, isTrue);

      // Recuperamos la venta por su ID (se asume que es 1 en BD limpia)
      Venta? ventaRecuperada = await Venta.obtenerVentaPorID(1);
      expect(ventaRecuperada, isNotNull);
      expect(ventaRecuperada!.idCliente, equals(2));
    });

    test('Obtener ventas por carga filtradas', () async {
      // Creamos varias ventas con diferentes valores de esAlContado
      Venta venta1 = Venta(
        idCliente: 1,
        montoTotal: 30.0,
        montoCancelado: 30.0,
        esAlContado: true,
      );
      bool creada1 = await Venta.crearVenta(venta1, []);
      expect(creada1, isTrue);

      Venta venta2 = Venta(
        idCliente: 1,
        montoTotal: 25.0,
        montoCancelado: 10.0,
        esAlContado: false,
      );
      bool creada2 = await Venta.crearVenta(venta2, []);
      expect(creada2, isTrue);

      Venta venta3 = Venta(
        idCliente: 2,
        montoTotal: 35.0,
        montoCancelado: 35.0,
        esAlContado: true,
      );
      bool creada3 = await Venta.crearVenta(venta3, []);
      expect(creada3, isTrue);

      // Obtener ventas filtradas para ventas al contado (esAlContado true)
      List<Venta> ventasContado = await Venta.obtenerVentasPorCargaFiltradas(numeroCarga: 0, esAlContado: true);
      expect(ventasContado.length, greaterThanOrEqualTo(1), reason: 'Debe haber al menos una venta al contado');

      // Obtener ventas filtradas para ventas a crédito (esAlContado false)
      List<Venta> ventasCredito = await Venta.obtenerVentasPorCargaFiltradas(numeroCarga: 0, esAlContado: false);
      expect(ventasCredito.length, greaterThanOrEqualTo(1), reason: 'Debe haber al menos una venta a crédito');
    });

    test('Obtener ventas de cliente', () async {
      // Creamos dos ventas para el cliente con idCliente = 3
      Venta venta1 = Venta(
        idCliente: 3,
        montoTotal: 40.0,
        montoCancelado: 40.0,
        esAlContado: true,
      );
      bool creada1 = await Venta.crearVenta(venta1, []);
      expect(creada1, isTrue);

      Venta venta2 = Venta(
        idCliente: 3,
        montoTotal: 50.0,
        montoCancelado: 20.0,
        esAlContado: false,
      );
      bool creada2 = await Venta.crearVenta(venta2, []);
      expect(creada2, isTrue);

      // Obtenemos las ventas del cliente 3
      List<Venta> ventasCliente = await Venta.obtenerVentasDeCliente(3);
      expect(ventasCliente.length, equals(2), reason: 'El cliente 3 debe tener 2 ventas');
    });

    test('Obtener ventas por fecha', () async {
      // Creamos una venta para que su fecha de venta sea la actual
      Venta venta = Venta(
        idCliente: 1,
        montoTotal: 60.0,
        montoCancelado: 60.0,
        esAlContado: true,
      );
      bool creada = await Venta.crearVenta(venta, []);
      expect(creada, isTrue);

      // Definimos un rango de fechas que incluya la fecha actual
      DateTime ahora = DateTime.now();
      DateTime inicio = ahora.subtract(Duration(days: 1));
      DateTime fin = ahora.add(Duration(days: 1));

      List<Venta> ventasPorFecha = await Venta.obtenerVentasporFecha(inicio, fin);
      expect(ventasPorFecha.isNotEmpty, isTrue, reason: 'Debe existir al menos una venta en el rango de fechas');
    });
  });
}
