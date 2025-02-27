import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterClientsPage extends StatefulWidget {
  final bool? esDeudor;

  const FilterClientsPage({
    super.key,
    required this.esDeudor,
  });

  @override
  State<FilterClientsPage> createState() => _FilterClientsState();
}

class _FilterClientsState extends State<FilterClientsPage> {
  bool? esDeudor;
  bool habilitarFiltro = false;

  @override
  void initState() {
    super.initState();
    esDeudor = widget.esDeudor;
    habilitarFiltro = esDeudor != null;
  }

  void aplicarFiltros() {
    debugPrint("Filtrar clientes por deuda: $esDeudor");
    context.pop(esDeudor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filtros de Clientes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de filtro por deuda
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        "Filtrar por Estado de Deuda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: const Text(
                        "Activa esta opción para filtrar clientes por su estado de deuda.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      value: habilitarFiltro,
                      activeColor: const Color(0xFF2BBF55), // Verde
                      onChanged: (bool value) {
                        setState(() {
                          habilitarFiltro = value;
                          esDeudor = value ? esDeudor : null;
                        });
                      },
                    ),
                    if (habilitarFiltro) ...[
                      const Divider(),
                      RadioListTile<bool>(
                        title: const Text("Deudor",
                            style: TextStyle(color: Colors.black)),
                        value: true,
                        groupValue: esDeudor,
                        activeColor: const Color(0xFF2BBF55),
                        onChanged: (bool? value) {
                          setState(() {
                            esDeudor = value;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text("Regular",
                            style: TextStyle(color: Colors.black)),
                        value: false,
                        groupValue: esDeudor,
                        activeColor: const Color(0xFF2BBF55),
                        onChanged: (bool? value) {
                          setState(() {
                            esDeudor = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Botón de aplicar filtro
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF493D9E), // Morado
                ),
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: const Text(
                  "Aplicar Filtros",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: aplicarFiltros,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
