import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterSalesPage extends StatefulWidget {
  final bool? esAlContado;
  final DateTime? fechaInicio;
  final DateTime? fechaFinal;

  const FilterSalesPage({
    super.key,
    required this.esAlContado,
    this.fechaInicio,
    this.fechaFinal,
  });

  @override
  State<FilterSalesPage> createState() => _FilterSalesState();
}

class _FilterSalesState extends State<FilterSalesPage> {
  bool? esAlContado;
  bool habilitarFiltroPago = false;
  bool habilitarFiltroFecha = false;
  DateTime? fechaInicio;
  DateTime? fechaFinal;

  TextEditingController fechaInicioController = TextEditingController();
  TextEditingController fechaFinalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    esAlContado = widget.esAlContado;
    fechaInicio = widget.fechaInicio;
    fechaFinal = widget.fechaFinal;

    fechaInicioController.text =
        fechaInicio != null ? formatoFecha(fechaInicio!) : '';
    fechaFinalController.text =
        fechaFinal != null ? formatoFecha(fechaFinal!) : '';

    habilitarFiltroPago = esAlContado != null;
    habilitarFiltroFecha = fechaInicio != null || fechaFinal != null;
  }

  void aplicarFiltros() {
    context.pop({
      'esAlContado': habilitarFiltroPago ? esAlContado : null,
      'fechaInicio': habilitarFiltroFecha ? fechaInicio : null,
      'fechaFinal': habilitarFiltroFecha ? fechaFinal : null
    });
  }

  String formatoFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/"
        "${fecha.month.toString().padLeft(2, '0')}/"
        "${fecha.year}";
  }

  Future<void> seleccionarFecha(bool esInicio) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (esInicio) {
          fechaInicio = picked;
          fechaInicioController.text = formatoFecha(picked);
        } else {
          fechaFinal = picked;
          fechaFinalController.text = formatoFecha(picked);
        }
      });
    }
  }

  void limpiarFecha(bool esInicio) {
    setState(() {
      if (esInicio) {
        fechaInicio = null;
        fechaInicioController.clear();
      } else {
        fechaFinal = null;
        fechaFinalController.clear();
      }
    });
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
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                          "Activa esta opción para filtrar por tipo de pago."),
                      value: habilitarFiltroPago,
                      activeColor: const Color(0xFF2BBF55),
                      onChanged: (bool value) {
                        setState(() {
                          habilitarFiltroPago = value;
                          esAlContado = value ? esAlContado : null;
                        });
                      },
                    ),
                    if (habilitarFiltroPago) ...[
                      const Divider(),
                      RadioListTile<bool>(
                        title: const Text("Al contado"),
                        value: true,
                        groupValue: esAlContado,
                        activeColor: const Color(0xFF2BBF55),
                        onChanged: (bool? value) {
                          setState(() {
                            esAlContado = value;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text("Crédito"),
                        value: false,
                        groupValue: esAlContado,
                        activeColor: const Color(0xFF2BBF55),
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
            const SizedBox(height: 16),
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
                        "Filtrar por Rango de Fechas",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                          "Activa esta opción para filtrar por rango de fechas."),
                      value: habilitarFiltroFecha,
                      activeColor: const Color(0xFF2BBF55),
                      onChanged: (bool value) {
                        setState(() {
                          habilitarFiltroFecha = value;
                          if (!value) {
                            fechaInicioController.clear();
                            fechaFinalController.clear();
                            fechaInicio = null;
                            fechaFinal = null;
                          }
                        });
                      },
                    ),
                    if (habilitarFiltroFecha) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: fechaInicioController,
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          suffixIcon: fechaInicio != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.red),
                                  onPressed: () => limpiarFecha(true),
                                )
                              : const Icon(Icons.calendar_today,
                                  color: Color(0xFF493D9E)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        readOnly: true,
                        onTap: () => seleccionarFecha(true),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: fechaFinalController,
                        decoration: InputDecoration(
                          labelText: 'Fecha Final',
                          suffixIcon: fechaFinal != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.red),
                                  onPressed: () => limpiarFecha(false),
                                )
                              : const Icon(Icons.calendar_today,
                                  color: Color(0xFF493D9E)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        readOnly: true,
                        onTap: () => seleccionarFecha(false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: const Color(0xFF493D9E),
                ),
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: const Text("Aplicar Filtros",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: aplicarFiltros,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
