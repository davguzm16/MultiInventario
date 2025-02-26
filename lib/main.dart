// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  await NotificationService().initialize();

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
