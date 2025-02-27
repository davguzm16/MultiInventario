import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterSalesPage extends StatefulWidget {
  final bool? esAlContado;

  const FilterSalesPage({
    super.key,
    required this.esAlContado,
  });

  @override
  State<FilterSalesPage> createState() => _FilterSalesState();
}

class _FilterSalesState extends State<FilterSalesPage> {
  bool? esAlContado;
  bool habilitarFiltro = false;

  @override
  void initState() {
    super.initState();
    esAlContado = widget.esAlContado;
    habilitarFiltro = esAlContado != null;
  }

  void aplicarFiltros() {
    debugPrint("Filtrar por tipo de pago: $esAlContado");
    context.pop(esAlContado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filtros de Ventas",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de filtro por tipo de pago
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
                        "Filtrar por Tipo de Pago",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: const Text(
                        "Activa esta opción para filtrar por tipo de pago.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      value: habilitarFiltro,
                      activeColor: const Color(0xFF2BBF55), // Verde
                      onChanged: (bool value) {
                        setState(() {
                          habilitarFiltro = value;
                          esAlContado = value ? esAlContado : null;
                        });
                      },
                    ),
                    if (habilitarFiltro) ...[
                      const Divider(),
                      RadioListTile<bool>(
                        title: const Text("Al contado",
                            style: TextStyle(color: Colors.black)),
                        value: true,
                        groupValue: esAlContado,
                        activeColor: const Color(0xFF2BBF55), // Verde
                        onChanged: (bool? value) {
                          setState(() {
                            esAlContado = value;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text("Crédito",
                            style: TextStyle(color: Colors.black)),
                        value: false,
                        groupValue: esAlContado,
                        activeColor: const Color(0xFF2BBF55), // Verde
                        onChanged: (bool? value) {
                          setState(() {
                            esAlContado = value;
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
