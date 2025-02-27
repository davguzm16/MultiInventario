import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() {
  // Inicializar sqflite en modo FFI (ideal para desktop y CI)
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Abrir la base de datos en memoria y crear la tabla Categorias.
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Categorias (
              idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreCategoria TEXT UNIQUE
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

  test('crearCategoria inserta una categoría y retorna true', () async {
    bool created = await Categoria.crearCategoria(Categoria(nombreCategoria: 'Test'));
    expect(created, isTrue);

    // Verificar en la base de datos que existe la categoría insertada.
    final db = await DatabaseController().database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM Categorias WHERE nombreCategoria = ?',
      ['Test'],
    );
    expect(result.length, equals(1));
  });

  test('editarCategoria modifica la categoría', () async {
    // Insertar una categoría con nombre "OldName".
    bool created = await Categoria.crearCategoria(Categoria(nombreCategoria: 'OldName'));
    expect(created, isTrue);

    // Obtener el id de la categoría insertada.
    final db = await DatabaseController().database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT idCategoria FROM Categorias WHERE nombreCategoria = ?',
      ['OldName'],
    );
    expect(result.length, equals(1));
    int idCategoria = result.first['idCategoria'] as int;

    // Editar la categoría cambiando el nombre a "NewName".
    bool updated = await Categoria.editarCategoria(idCategoria, 'NewName');
    expect(updated, isTrue);

    // Verificar que se actualizó en la base de datos.
    List<Map<String, dynamic>> updatedResult = await db.rawQuery(
      'SELECT * FROM Categorias WHERE idCategoria = ?',
      [idCategoria],
    );
    expect(updatedResult.first['nombreCategoria'], equals('NewName'));
  });

  test('eliminarCategoria borra la categoría', () async {
    // Insertar una categoría.
    bool created = await Categoria.crearCategoria(Categoria(nombreCategoria: 'ToDelete'));
    expect(created, isTrue);

    final db = await DatabaseController().database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT idCategoria FROM Categorias WHERE nombreCategoria = ?',
      ['ToDelete'],
    );
    expect(result.length, equals(1));
    int idCategoria = result.first['idCategoria'] as int;

    // Eliminar la categoría.
    bool deleted = await Categoria.eliminarCategoria(idCategoria);
    expect(deleted, isTrue);

    // Verificar que la categoría fue eliminada.
    List<Map<String, dynamic>> checkResult = await db.rawQuery(
      'SELECT * FROM Categorias WHERE idCategoria = ?',
      [idCategoria],
    );
    expect(checkResult.length, equals(0));
  });

  test('crearCategoriasPorDefecto inserta las categorías si la tabla está vacía', () async {
    // Verificar que la tabla está vacía.
    final db = await DatabaseController().database;
    List<Map<String, dynamic>> initial = await db.rawQuery('SELECT * FROM Categorias');
    expect(initial.length, equals(0));

    // Ejecutar la función para crear categorías por defecto.
    await Categoria.crearCategoriasPorDefecto();

    // Verificar que se insertaron las categorías por defecto (se esperan al menos 5).
    List<Map<String, dynamic>> after = await db.rawQuery('SELECT * FROM Categorias');
    expect(after.length, greaterThanOrEqualTo(5));
  });

  test('obtenerCategorias retorna todas las categorías', () async {
    // Insertar dos categorías.
    await Categoria.crearCategoria(Categoria(nombreCategoria: 'Cat1'));
    await Categoria.crearCategoria(Categoria(nombreCategoria: 'Cat2'));

    List<Categoria> categorias = await Categoria.obtenerCategorias();
    expect(categorias.length, greaterThanOrEqualTo(2));
    expect(categorias.any((cat) => cat.nombreCategoria == 'Cat1'), isTrue);
    expect(categorias.any((cat) => cat.nombreCategoria == 'Cat2'), isTrue);
  });
}
