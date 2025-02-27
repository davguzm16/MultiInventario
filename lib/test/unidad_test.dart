import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI (ideal para desktop y CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir la base de datos en memoria y crear la tabla "Unidades"
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Unidades (
              idUnidad INTEGER PRIMARY KEY AUTOINCREMENT,
              tipoUnidad TEXT UNIQUE
            )
          ''');
        },
      ),
    );
    // Inyectar la base de datos de test en el DatabaseController.
    setTestDatabase(db);
  });

  tearDown(() async {
    // Cerrar la base de datos y limpiar la inyección.
    final db = await DatabaseController().database;
    await db.close();
    clearTestDatabase();
  });

  test('crearUnidadesPorDefecto inserta unidades si la tabla está vacía', () async {
    final db = await DatabaseController().database;
    // Verificar que la tabla esté inicialmente vacía.
    List<Map<String, dynamic>> initial = await db.rawQuery('SELECT * FROM Unidades');
    expect(initial.length, equals(0));

    // Ejecutar la función para crear unidades por defecto.
    await Unidad.crearUnidadesPorDefecto();

    // Verificar que se hayan insertado 4 unidades por defecto.
    List<Map<String, dynamic>> after = await db.rawQuery('SELECT * FROM Unidades');
    expect(after.length, equals(4));

    // Opcional: comprobar que se insertaron las unidades esperadas.
    List<String> expected = ['kg', 'l', 'ud', 'm'];
    List<String> inserted = after.map((e) => e['tipoUnidad'] as String).toList();
    for (var unidad in expected) {
      expect(inserted.contains(unidad), isTrue);
    }
  });

  test('crearUnidadesPorDefecto no inserta unidades si ya existen datos', () async {
    final db = await DatabaseController().database;
    // Insertar una unidad "dummy" para simular que ya hay datos.
    await db.insert('Unidades', {'tipoUnidad': 'dummy'});
    // Ejecutar la función; no debe insertar las unidades por defecto.
    await Unidad.crearUnidadesPorDefecto();

    // Verificar que la tabla siga teniendo solo la unidad "dummy".
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM Unidades');
    expect(result.length, equals(1));
    expect(result.first['tipoUnidad'], equals('dummy'));
  });

  test('obtenerUnidades retorna todas las unidades', () async {
    final db = await DatabaseController().database;
    // Insertar manualmente algunas unidades.
    await db.insert('Unidades', {'tipoUnidad': 'unit1'});
    await db.insert('Unidades', {'tipoUnidad': 'unit2'});
    await db.insert('Unidades', {'tipoUnidad': 'unit3'});

    List<Unidad> unidades = await Unidad.obtenerUnidades();
    expect(unidades.length, equals(3));

    List<String> tipos = unidades.map((u) => u.tipoUnidad).toList();
    expect(tipos.contains('unit1'), isTrue);
    expect(tipos.contains('unit2'), isTrue);
    expect(tipos.contains('unit3'), isTrue);
  });

  test('obtenerUnidadPorId retorna la unidad correcta', () async {
    final db = await DatabaseController().database;
    // Insertar una unidad y obtener su id.
    int id = await db.insert('Unidades', {'tipoUnidad': 'specificUnit'});
    Unidad? unidad = await Unidad.obtenerUnidadPorId(id);
    expect(unidad, isNotNull);
    expect(unidad!.tipoUnidad, equals('specificUnit'));
  });
}
