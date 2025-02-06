import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    // Inicializa SQLite FFI para sistemas de escritorio
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseController.insertDefaultData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
//Fondo
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
