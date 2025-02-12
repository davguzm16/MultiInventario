import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Usar base de datos compatible con Web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Usar base de datos compatible con Windows/Linux
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicializa la base de datos
  await DatabaseController().database;
  await DatabaseController.insertDefaultData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
