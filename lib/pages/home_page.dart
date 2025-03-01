// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:multiinventario/models/credenciales.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/services/drive_service.dart';
import 'package:multiinventario/widgets/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool sincronizacionActivada = false;
  int diasNotificarVencimiento = 0;

  @override
  void initState() {
    super.initState();
    cargarPreferences();
    notificarVencimientosLotes();
  }

  Future<void> cargarPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sincronizacionActivada = prefs.getBool('exportacionAutomatica') ?? false;
      diasNotificarVencimiento = prefs.getInt('diasNotificarVencimiento') ?? 0;
    });

    debugPrint("Sincronización activada: $sincronizacionActivada");
    debugPrint(
        "Días para notificación de vencimiento: $diasNotificarVencimiento");
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(index);
  }

  Future<void> notificarVencimientosLotes() async {
    if (diasNotificarVencimiento > 0) {
      bool exito =
          await Lote.verificarFechasVencimientos(diasNotificarVencimiento);
      if (!exito) {
        ErrorDialog(
            context: context,
            errorMessage: "Ocurrió un problema al verificar los vencimientos.");
      }
    } else {
      debugPrint(
          "No se enviarán notificaciones, días configurados: $diasNotificarVencimiento");
    }
  }

  Future<void> dialogoExportacionAutomatica(BuildContext context) async {
    await cargarPreferences();

    if (sincronizacionActivada) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            "Exportando información",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF493D9E),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Por favor espere...",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 10),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2BBF55)),
              ),
            ],
          ),
        ),
      );

      final correoUsuario = await Credenciales.obtenerCredencial("USER_EMAIL");
      final rutaBD = await DatabaseController().getDatabasePath();

      if (await DriveService.exportarBD(correoUsuario, rutaBD)) {
        debugPrint("Exportación automática completada");
      } else {
        debugPrint("Error en la exportación automática");
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    await notificarVencimientosLotes();

    SystemNavigator.pop();
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
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomNavigationBar(
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(color: Colors.black),
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.black,
            backgroundColor: const Color(0xFF493D9E),
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _goBranch,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "lib/assets/iconos/iconoInventario.png",
                  width: 30,
                  height: 30,
                ),
                label: "Inventario",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "lib/assets/iconos/iconoVentas.png",
                  width: 30,
                  height: 30,
                ),
                label: "Ventas",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "lib/assets/iconos/iconoClientes.png",
                  width: 30,
                  height: 30,
                ),
                label: "Clientes",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "lib/assets/iconos/iconoReportes.png",
                  width: 30,
                  height: 30,
                ),
                label: "Reportes",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "lib/assets/iconos/iconoConfiguraciones.png",
                  width: 30,
                  height: 30,
                ),
                label: "Configuraciones",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
