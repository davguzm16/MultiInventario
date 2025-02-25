import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/cliente.dart';

void main() {
  group('Pruebas de Deudores', () {
    test('Registro de deudores: crear cliente deudor', () async {
      // Se crea un cliente marcado como deudor
      final deudor = Cliente(
        nombreCliente: 'Juan Pérez',
        dniCliente: '12345678',
        correoCliente: 'juan@example.com',
        esDeudor: true,
      );

      final id = await Cliente.crearCliente(deudor);
      expect(id, isNotNull, reason: 'El cliente deudor debe ser creado y retornar un id');

      // Se recupera el cliente para confirmar que esté marcado como deudor
      final clienteRecuperado = await Cliente.obtenerClientePorId(id!);
      expect(clienteRecuperado, isNotNull);
      expect(clienteRecuperado!.esDeudor, isTrue, reason: 'El cliente debe estar marcado como deudor');
    });

    test('Consulta de deudores: obtener clientes que son deudores', () async {
      // Se crean varios clientes: dos deudores y uno no deudor
      final deudor1 = Cliente(
        nombreCliente: 'Deudor Uno',
        dniCliente: '11111111',
        correoCliente: 'deudor1@example.com',
        esDeudor: true,
      );
      final deudor2 = Cliente(
        nombreCliente: 'Deudor Dos',
        dniCliente: '22222222',
        correoCliente: 'deudor2@example.com',
        esDeudor: true,
      );
      final clienteNormal = Cliente(
        nombreCliente: 'Cliente Normal',
        dniCliente: '33333333',
        correoCliente: 'normal@example.com',
        esDeudor: false,
      );

      await Cliente.crearCliente(deudor1);
      await Cliente.crearCliente(deudor2);
      await Cliente.crearCliente(clienteNormal);

      // Se consulta la lista de clientes filtrados por deudores (en la primera carga)
      final listaDeDeudores = await Cliente.obtenerClientesPorCarga(numeroCarga: 0, esDeudor: true);
      expect(listaDeDeudores, isNotEmpty, reason: 'Debe existir al menos un cliente deudor');
      for (final cliente in listaDeDeudores) {
        expect(cliente.esDeudor, isTrue, reason: 'Todos los clientes listados deben ser deudores');
      }
    });

    test('Listado de productos registrados a la deuda: simular ventas para un deudor', () async {
      // Se crea un cliente deudor
      final deudor = Cliente(
        nombreCliente: 'Deudor Ventas',
        dniCliente: '44444444',
        correoCliente: 'ventas@example.com',
        esDeudor: true,
      );

      final deudorId = await Cliente.crearCliente(deudor);
      expect(deudorId, isNotNull);

      // Se simulan registros en la tabla Ventas asociados a este cliente
      final db = await DatabaseController().database;

      // Insertar dos ventas simuladas
      await db.rawInsert(
          '''
        INSERT INTO Ventas (idCliente, montoTotal, fechaVenta) 
        VALUES (?, ?, ?)
        ''',
          [deudorId, 150.0, '2025-02-22']
      );

      await db.rawInsert(
          '''
        INSERT INTO Ventas (idCliente, montoTotal, fechaVenta) 
        VALUES (?, ?, ?)
        ''',
          [deudorId, 250.0, '2025-02-23']
      );

      // Se verifica el total de ventas (que en este ejemplo representa la deuda)
      final totalVentas = await deudor.obtenerTotalDeVentas();
      expect(totalVentas, equals(400.0), reason: 'El total de ventas debe ser la suma de los montos insertados');

      // Se verifica la fecha de la última venta
      final fechaUltimaVenta = await deudor.obtenerFechaUltimaVenta();
      expect(fechaUltimaVenta, isNotNull);
      expect(fechaUltimaVenta!.toIso8601String().substring(0, 10), equals('2025-02-23'));
    });

    test('Registrar el pago de una deuda: actualizar estado de deudor', () async {
      // Se crea un cliente deudor
      final deudor = Cliente(
        nombreCliente: 'Deudor Pago',
        dniCliente: '55555555',
        correoCliente: 'pago@example.com',
        esDeudor: true,
      );

      final deudorId = await Cliente.crearCliente(deudor);
      expect(deudorId, isNotNull);

      // Se simula el registro del pago actualizando el estado a no deudor
      final db = await DatabaseController().database;
      final filasActualizadas = await db.rawUpdate(
        '''
        UPDATE Clientes 
        SET esDeudor = 0 
        WHERE idCliente = ?
        ''',
        [deudorId],
      );
      expect(filasActualizadas, equals(1), reason: 'Debe actualizarse exactamente una fila');

      // Se recupera el cliente para confirmar que ya no es deudor
      final clienteActualizado = await Cliente.obtenerClientePorId(deudorId!);
      expect(clienteActualizado, isNotNull);
      expect(clienteActualizado!.esDeudor, isFalse, reason: 'El cliente debe quedar marcado como no deudor después del pago');
    });
  });
}
