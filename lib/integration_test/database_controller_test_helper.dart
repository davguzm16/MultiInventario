// test/database_controller_test_helper.dart
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Crear base de datos en memoria con la tabla Credenciales
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Credenciales (
              idCredencial INTEGER PRIMARY KEY AUTOINCREMENT,
              tipoCredencial TEXT NOT NULL UNIQUE,
              valorCredencial TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    setTestDatabase(db);
  });

  tearDown(() async {
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('Crear y obtener credencial encriptada', () async {
    final tipo = 'USER_PIN';
    final plainValue = '123456';
    // Crear la credencial
    bool creado = await Credenciales.crearCredencial(tipo, plainValue);
    expect(creado, isTrue);

    // Consultar la credencial (la función desencripta internamente)
    final obtained = await Credenciales.obtenerCredencial(tipo);
    expect(obtained, equals(plainValue));

    // Opcional: consulta directa en la BD para verificar que no se almacena en texto plano.
    final db = await DatabaseController().database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT valorCredencial FROM Credenciales WHERE tipoCredencial = ?',
      [tipo],
    );
    expect(result.length, equals(1));
    expect(result.first['valorCredencial'], isNot(equals(plainValue)));
  });
}


/// Inyecta la base de datos de test en el DatabaseController.
void setTestDatabase(Database? db) {
  DatabaseController.testDatabase = db;
}

/// Limpia la base de datos inyectada en el DatabaseController.
void clearTestDatabase() {
  DatabaseController.clearTestDatabase();
}
