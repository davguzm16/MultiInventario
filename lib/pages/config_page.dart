// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:multiinventario/services/drive_service.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});
  @override
  ConfigPageState createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage> {
  bool exportacionAutomatica = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      exportacionAutomatica = prefs.getBool('exportacionAutomatica') ?? false;
    });
  }

  Future<void> _guardarPreferencias(bool exportar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('exportacionAutomatica', exportar);
  }

  void activarExportacionAutomatica(bool exportar) {
    ConfirmDialog(
      context: context,
      title: "Confirmar",
      message: exportar
          ? "¿Deseas activar la exportación automática?"
          : "¿Deseas desactivar la exportación automática?",
      btnOkOnPress: () async {
        try {
          final correoUsuario =
              await Credenciales.obtenerCredencial("USER_EMAIL");
          final rutaBD = await DatabaseController().getDatabasePath();

          if (correoUsuario.isEmpty || rutaBD.isEmpty) {
            ErrorDialog(
              context: context,
              errorMessage:
                  "No se encontró un correo válido para la exportación.",
            );
            return;
          }

          setState(() => exportacionAutomatica = exportar);
          await _guardarPreferencias(exportar);
          SuccessDialog(
            context: context,
            successMessage: exportar
                ? "Exportación automática activada con éxito"
                : "Exportación automática desactivada",
          );
        } catch (e) {
          ErrorDialog(
            context: context,
            errorMessage: "Error al actualizar la exportación: $e",
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sincronización de Backups",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
            const SizedBox(height: 45),
            const Icon(Icons.sync, size: 60, color: Color(0xFF2BBF55)),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Activar exportación \nautomática al cerrar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: exportacionAutomatica,
                  onChanged: activarExportacionAutomatica,
                  activeColor: Color(0xFF2BBF55),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF493D9E),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () async {
                    final correoUsuario =
                        await Credenciales.obtenerCredencial("USER_EMAIL");
                    final rutaBD = await DatabaseController().getDatabasePath();
                    if (correoUsuario.isEmpty || rutaBD.isEmpty) {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "No se encontró un correo válido para la exportación.",
                      );
                      return;
                    }

                    if (await DriveService.exportarBD(correoUsuario, rutaBD)) {
                      SuccessDialog(
                        context: context,
                        successMessage: "Exportación completada",
                      );
                    } else {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "No se pudo realizar correctamente la exportación.",
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.upload,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Exportar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF2BBF55),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black45,
                  ),
                  onPressed: () async {
                    final correoUsuario =
                        await Credenciales.obtenerCredencial("USER_EMAIL");
                    final rutaBD = await DatabaseController().getDatabasePath();
                    if (correoUsuario.isEmpty || rutaBD.isEmpty) {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "No se encontró un correo válido para la importación.",
                      );
                      return;
                    }
                    if (await DriveService.importarBD(correoUsuario, rutaBD)) {
                      SuccessDialog(
                        context: context,
                        successMessage: "Importación completada",
                      );
                    } else {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "No se pudo realizar correctamente la importación.",
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Importar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
