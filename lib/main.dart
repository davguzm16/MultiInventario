// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/services/drive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");

  // Inicializa la base de datos
  await DatabaseController().database;
  await DatabaseController.insertDefaultData();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool sincronizacionActivada = true;

  @override
  void initState() {
    super.initState();
    cargarPreferences();
  }

  // Cargar preferencias y actualizar el estado
  Future<void> cargarPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool activada = prefs.getBool('exportacionAutomatica') ?? false;

    setState(() {
      sincronizacionActivada = activada;
    });

    debugPrint("Sincronizacion activada: $sincronizacionActivada");
  }

  Future<void> dialogoExportacionAutomatica(BuildContext context) async {
    await cargarPreferences();

    debugPrint("Estado sincronizacionActivada: $sincronizacionActivada");

    if (true) {
      debugPrint("Se activó la sincronización, mostrando el diálogo...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Exportando información",
              style: TextStyle(color: Color(0xFF2BBF55))),
          backgroundColor: Color(0xFF493D9E),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Por favor espera...",
                  style: TextStyle(color: Color(0xFF2BBF55))),
              const SizedBox(width: 10),
              const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2BBF55))),
            ],
          ),
        ),
      );

      debugPrint("Esperando 2 segundos antes de exportar...");

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await dialogoExportacionAutomatica(context);
        }
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
