// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/services/drive_service.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/credenciales.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});
  @override
  ConfigPageState createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage> {
  final TextEditingController _diasNotificacionController =
      TextEditingController();
  bool exportacionAutomatica = false;
  int diasNotificarVencimiento = 0;
  bool editandoDias = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      exportacionAutomatica = prefs.getBool('exportacionAutomatica') ?? false;
      diasNotificarVencimiento = prefs.getInt('diasNotificarVencimiento') ?? 0;
      _diasNotificacionController.text = diasNotificarVencimiento.toString();
    });
  }

  Future<void> _guardarDiasNotificacion() async {
    String input = _diasNotificacionController.text.trim();

    if (input.isEmpty || !RegExp(r'^\d+$').hasMatch(input)) {
      ErrorDialog(
        context: context,
        errorMessage: "Por favor, ingresa un número válido de días.",
      );
      return;
    }

    int nuevoValor = int.parse(input);

    if (nuevoValor < 0) {
      ErrorDialog(
        context: context,
        errorMessage: "El número de días no puede ser negativo.",
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diasNotificarVencimiento', nuevoValor);

    setState(() {
      diasNotificarVencimiento = nuevoValor;
      editandoDias = false;
    });

    SuccessDialog(
      context: context,
      successMessage:
          "Días de notificación ($diasNotificarVencimiento) actualizados correctamente.",
    );
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
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('exportacionAutomatica', exportar);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              context.push("/config/notifications-page");
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
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
                    ),
                    onPressed: () async {
                      final correoUsuario =
                          await Credenciales.obtenerCredencial("USER_EMAIL");
                      final rutaBD =
                          await DatabaseController().getDatabasePath();
                      if (correoUsuario.isEmpty || rutaBD.isEmpty) {
                        ErrorDialog(
                          context: context,
                          errorMessage:
                              "No se encontró un correo válido para la exportación.",
                        );
                        return;
                      }

                      if (await DriveService.exportarBD(
                          correoUsuario, rutaBD)) {
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
                    icon: const Icon(Icons.upload),
                    label: const Text("Exportar"),
                  ),
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
                    ),
                    onPressed: () async {
                      // Importación de BD...
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Importar"),
                  ),
                ],
              ),
              const SizedBox(height: 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Flexible(
                    child: const Text(
                      "Días antes de notificar productos próximos a vencer:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _diasNotificacionController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "0",
                        border: OutlineInputBorder(),
                      ),
                      enabled: editandoDias,
                    ),
                  ),
                  IconButton(
                    icon: Icon(editandoDias ? Icons.save : Icons.edit),
                    color: Colors.blue,
                    onPressed: () {
                      if (editandoDias) {
                        _guardarDiasNotificacion();
                      } else {
                        setState(() => editandoDias = true);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
