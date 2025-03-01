import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:multiinventario/pages/login/login_page.dart';
import 'package:multiinventario/pages/inventory/inventory_page.dart';
import 'package:pinput/pinput.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'database_controller_test_helper.dart';

void main() async {
  // Inicializa sqflite en modo FFI y asigna el factory global.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Configurar un GoRouter mínimo para la prueba.
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
      ),
    ],
  );

  // SetUp: Crear la base de datos en memoria con la tabla Credenciales y
  // agregar la credencial para USER_PIN.
  setUp(() async {
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
          // Aquí podrías crear otras tablas si es necesario.
        },
      ),
    );
    setTestDatabase(db);

    // Insertar la credencial USER_PIN con el valor "123456" encriptado.
    await db.insert('Credenciales', {
      'tipoCredencial': 'USER_PIN',
      'valorCredencial': Credenciales.encryptPassword('123456'),
    });
  });

  late Database testDb;

  setUp(() async {
    testDb = await databaseFactory.openDatabase(
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
    setTestDatabase(testDb);
  });

  tearDown(() async {
    // Usamos la instancia almacenada
    await testDb.close();
    clearTestDatabase();
  });

  testWidgets('Login exitoso si el PIN es correcto', (WidgetTester tester) async {
    // Arranca la app usando MaterialApp.router con GoRouter.
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
    ));
    await tester.pumpAndSettle();

    // Verifica que se muestre la pantalla de login.
    expect(find.byType(LoginPage), findsOneWidget);

    // Encontrar el widget Pinput para ingresar el PIN.
    final pinFieldFinder = find.byType(Pinput);
    expect(pinFieldFinder, findsOneWidget);

    // Ingresa el PIN correcto (que en este test es "123456").
    await tester.enterText(pinFieldFinder, '123456');
    await tester.pumpAndSettle();

    // Presionar el botón "Confirmar"
    final confirmButtonFinder = find.text('Confirmar');
    expect(confirmButtonFinder, findsOneWidget);
    await tester.tap(confirmButtonFinder);
    await tester.pumpAndSettle();

    // Verificar que se navega a /inventory (por ejemplo, comprobando que aparece InventoryPage).
    expect(find.byType(InventoryPage), findsOneWidget);
  });
}
