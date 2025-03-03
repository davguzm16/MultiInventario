import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:intl/intl.dart';

class ReportDetailsPage extends StatefulWidget {
  const ReportDetailsPage({super.key});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  late TextEditingController fechaInicio;
  late TextEditingController fechaFinal;
  DateTime selectedFechaInicio = DateTime.now();
  DateTime selectedFechaFinal = DateTime.now();
  String _selectedReport = "Reporte general detallado de ventas";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fechaInicio = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    fechaFinal = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
  }

  @override
  void dispose() {
    fechaInicio.dispose();
    fechaFinal.dispose();
    super.dispose();
  }

  void _generateReport(
      DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedReport == "Reporte general detallado de ventas") {
      await generarDetallesVentas(
          context, selectedFechaInicio, selectedFechaFinal);
    } else if (_selectedReport == "Reporte detallado de ventas al contado") {
      await generarDetallesTipo(
          context, selectedFechaInicio, selectedFechaFinal, true);
    } else if (_selectedReport == "Reporte detallado de ventas al crédito") {
      await generarDetallesTipo(
          context, selectedFechaInicio, selectedFechaFinal, false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Reporte detallado de ventas",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Elegir tipo",
                  style: TextStyle(
                      color: Color(0xFF493D9E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton("Reporte general detallado de ventas", _selectedReport,
                context, (selected) {
              setState(() {
                _selectedReport = selected;
              });
            }),
            const SizedBox(height: 16),
            _buildButton("Reporte detallado de ventas al contado",
                _selectedReport, context, (selected) {
              setState(() {
                _selectedReport = selected;
              });
            }),
            const SizedBox(height: 16),
            _buildButton("Reporte detallado de ventas al crédito",
                _selectedReport, context, (selected) {
              setState(() {
                _selectedReport = selected;
              });
            }),
            const SizedBox(height: 16),
            const Text(
              "Elegir rango",
              style: TextStyle(color: Color(0xFF493D9E)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: TextField(
                    controller: fechaInicio,
                    decoration: InputDecoration(
                        labelText: 'Fecha Inicio',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF493D9e),
                            ))),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFechaInicio,
                        firstDate: DateTime(2000),
                        lastDate: selectedFechaFinal,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedFechaInicio = picked;
                          fechaInicio.text =
                              DateFormat('dd/MM/yy').format(picked);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: TextField(
                    controller: fechaFinal,
                    decoration: InputDecoration(
                        labelText: 'Fecha Final',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF493D9e),
                            ))),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFechaFinal,
                        firstDate: selectedFechaInicio,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedFechaFinal = picked;
                          fechaFinal.text = DateFormat('dd/MM/yy').format(picked);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF493D9e),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  _generateReport(selectedFechaInicio, selectedFechaFinal);
                },
                child: const Text("Generar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildButton(String text, String selectedReport, BuildContext context,
    Function(String) onSelect) {
  bool isSelected = text == selectedReport;

  return SizedBox(
    width: 250,
    height: 50,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF493D9E) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF493D9E),
        side: const BorderSide(color: Color(0xFF493D9E)),
      ),
      onPressed: () {
        onSelect(text);
      },
      child: Text(text),
    ),
  );
}

Future<void> generarDetallesVentas(BuildContext context,
    DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {
  final ReportController report = ReportController();
  final pdf = pw.Document();
  final datosTablaGeneral =
      await obtenerDatosTabla(selectedFechaInicio, selectedFechaFinal);
  final datosTabla = datosTablaGeneral["data"] as List<List<String>>;
  final ganancia = datosTablaGeneral["ganancia"] as double;
  final total = datosTablaGeneral["total"] as double;
  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text("Reporte general detallado de ventas",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${DateFormat('dd/MM/yy').format(selectedFechaInicio)} - ${DateFormat('dd/MM/yy').format(selectedFechaFinal)}"),
            pw.Text("Total: S/ ${total.toStringAsFixed(2)}"),
            pw.Text("Ganancias estimadas: S/ ${ganancia.toStringAsFixed(2)}"),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha y hora",
                "Código de venta",
                "Tipo",
                "Cliente",
                "Código del producto",
                "Descripción del producto",
                "Cantidad",
                "Precio de compra por unidad (S/)",
                "Precio de venta por unidad (S/)",
                "Descuento (S/)",
                "Subtotal (S/)",
                "Ganancia estimada (S/)",
                "Estado"
              ],
              data: datosTabla,
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(2)),
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
                9: pw.Alignment.center,
                10: pw.Alignment.center,
                11: pw.Alignment.center,
                12: pw.Alignment.center,
                13: pw.Alignment.center
              },
              columnWidths: {
                0: pw.FixedColumnWidth(35), // Índice
                1: pw.FixedColumnWidth(60), // Fecha y hora
                2: pw.FixedColumnWidth(50), // Código de venta
                3: pw.FixedColumnWidth(50), // Tipo
                4: pw.FixedColumnWidth(80), // Cliente
                5: pw.FixedColumnWidth(60), // Código del producto
                6: pw.FixedColumnWidth(80), // Descripción
                7: pw.FixedColumnWidth(35), // Cantidad
                8: pw.FixedColumnWidth(55), // Precio de compra
                9: pw.FixedColumnWidth(55), // Precio de venta
                10: pw.FixedColumnWidth(60), // Descuento
                11: pw.FixedColumnWidth(60), // Subtotal
                12: pw.FixedColumnWidth(60), // Ganancia
                13: pw.FixedColumnWidth(60) // Estado
              },
            ),
          ];
        },
      ),
    );
  } catch (e) {
    debugPrint("Error $e");
  }
  final path = await report.generarPDF(pdf, "reporte_detalles_general.pdf");
  report.mostrarPDF(context, path);
}

Future<Map<String, dynamic>> obtenerDatosTabla(
    DateTime selectedFechaInicio, selectedFechaFinal) async {
  List<DetalleVenta> detalles = [];
  List<List<String>> data = [];
  double ganancia = 0;
  double total = 0;

  detalles = await DetalleVenta.obtenerDetallesPorFechas(
      selectedFechaInicio, selectedFechaFinal);

  for (int i = 0; i < detalles.length; i++) {
    Lote? lote =
        await Lote.obtenerLotePorId(detalles[i].idProducto, detalles[i].idLote);
    Producto? producto =
        await Producto.obtenerProductoPorID(detalles[i].idProducto);
    Venta? ventas;
    if (detalles[i].idVenta != null) {
      ventas = await Venta.obtenerVentaPorID(detalles[i].idVenta!);
    }
    Cliente? cliente;
    if (ventas != null) {
      cliente = await Cliente.obtenerClientePorId(ventas.idCliente);
    }
    String nombreCliente =
        cliente != null ? cliente.nombreCliente : "Desconocido";
    String nombreProducto =
        producto != null ? producto.nombreProducto : "Desconocido";
    double precioCompraUnidad = lote != null ? lote.precioCompra : 0;
    String estado = (ventas?.montoCancelado == ventas?.montoTotal)
        ? "Cancelado"
        : "No cancelado";

    ganancia = detalles[i].gananciaProducto;
    total = detalles[i].subtotalProducto;

    data.add([
      "${i + 1}", // Índice
      DateFormat('dd/MM/yy HH:mm').format(ventas?.fechaVenta ?? DateTime.now()), // Fecha y hora
      "${ventas?.idVenta}", // Código de venta
      ((ventas?.esAlContado == true) ? "Contado" : "Crédito"), // Tipo
      nombreCliente, // Cliente
      "${detalles[i].idProducto}", // Código del producto
      nombreProducto, // Descripción del producto
      "${detalles[i].cantidadProducto}", // Cantidad
      "${precioCompraUnidad.toStringAsFixed(2)}", // Precio de compra por unidad
      "${detalles[i].precioUnidadProducto.toStringAsFixed(2)}", // Precio de venta por unidad
      detalles[i].descuentoProducto?.toStringAsFixed(2) ?? '0.00', // Descuento
      detalles[i].subtotalProducto.toStringAsFixed(2), // Subtotal
      "${detalles[i].gananciaProducto.toStringAsFixed(2)}", // Ganancia
      estado // Estado
    ]);
  }
  return {"data": data, "ganancia": ganancia, "total": total};
}

Future<void> generarDetallesTipo(
    BuildContext context,
    DateTime selectedFechaInicio,
    DateTime selectedFechaFinal,
    bool tipo) async {
  final ReportController report = ReportController();
  final pdf = pw.Document();
  final datosTablaGeneral = await obtenerDatosTipoTabla(
      selectedFechaInicio, selectedFechaFinal, tipo);
  final datosTabla = datosTablaGeneral["data"] as List<List<String>>;
  final ganancia = datosTablaGeneral["ganancia"] as double;
  final total = datosTablaGeneral["total"] as double;
  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text(
                "Reporte detallado de ventas al ${(tipo == true) ? "contado" : "crédito"}",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${DateFormat('dd/MM/yy').format(selectedFechaInicio)} - ${DateFormat('dd/MM/yy').format(selectedFechaFinal)}"),
            pw.Text("Total: S/ ${total.toStringAsFixed(2)}"),
            pw.Text("Ganancias estimadas: S/ ${ganancia.toStringAsFixed(2)}"),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha y hora",
                "Código de venta",
                "Tipo",
                "Cliente",
                "Código del producto",
                "Descripción del producto",
                "Cantidad",
                "Precio de compra por unidad (S/)",
                "Precio de venta por unidad (S/)",
                "Descuento (S/)",
                "Subtotal (S/)",
                "Ganancia estimada (S/)",
                "Estado"
              ],
              data: datosTabla,
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(2)),
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
                9: pw.Alignment.center,
                10: pw.Alignment.center,
                11: pw.Alignment.center,
                12: pw.Alignment.center,
                13: pw.Alignment.center
              },
              columnWidths: {
                0: pw.FixedColumnWidth(35), // Índice
                1: pw.FixedColumnWidth(60), // Fecha y hora
                2: pw.FixedColumnWidth(50), // Código de venta
                3: pw.FixedColumnWidth(50), // Tipo
                4: pw.FixedColumnWidth(80), // Cliente
                5: pw.FixedColumnWidth(60), // Código del producto
                6: pw.FixedColumnWidth(80), // Descripción
                7: pw.FixedColumnWidth(35), // Cantidad
                8: pw.FixedColumnWidth(55), // Precio de compra
                9: pw.FixedColumnWidth(55), // Precio de venta
                10: pw.FixedColumnWidth(60), // Descuento
                11: pw.FixedColumnWidth(60), // Subtotal
                12: pw.FixedColumnWidth(60), // Ganancia
                13: pw.FixedColumnWidth(60) // Estado
              },
            ),
          ];
        },
      ),
    );
  } catch (e) {
    debugPrint("Error $e");
  }
  final path = await report.generarPDF(
      pdf, "reporte_detalles_${(tipo == true) ? 'contado' : 'credito'}.pdf");
  report.mostrarPDF(context, path);
}

Future<Map<String, dynamic>> obtenerDatosTipoTabla(
    DateTime selectedFechaInicio, selectedFechaFinal, bool tipo) async {
  List<DetalleVenta> detalles = [];
  List<List<String>> data = [];
  double ganancia = 0;
  double total = 0;

  detalles = await DetalleVenta.obtenerDetallesPorFechas(
      selectedFechaInicio, selectedFechaFinal);

  for (int i = 0; i < detalles.length; i++) {
    Venta? ventas;
    if (detalles[i].idVenta != null) {
      ventas = await Venta.obtenerVentaPorID(detalles[i].idVenta!);
    }

    if (ventas?.esAlContado == tipo) {
      Lote? lote = await Lote.obtenerLotePorId(
          detalles[i].idProducto, detalles[i].idLote);
      Producto? producto =
          await Producto.obtenerProductoPorID(detalles[i].idProducto);
      Cliente? cliente;
      if (ventas != null) {
        cliente = await Cliente.obtenerClientePorId(ventas.idCliente);
      }
      String nombreCliente =
          cliente != null ? cliente.nombreCliente : "Desconocido";
      String nombreProducto =
          producto != null ? producto.nombreProducto : "Desconocido";
      double precioCompraUnidad = lote != null ? lote.precioCompra : 0;
      String estado = (ventas?.montoCancelado == ventas?.montoTotal)
          ? "Cancelado"
          : "No cancelado";

      ganancia = detalles[i].gananciaProducto;
      total = detalles[i].subtotalProducto;

      data.add([
        "${i + 1}", // Índice
        DateFormat('dd/MM/yy HH:mm').format(ventas?.fechaVenta ?? DateTime.now()), // Fecha y hora
        "${ventas?.idVenta}", // Código de venta
        ((ventas?.esAlContado == true) ? "Contado" : "Crédito"), // Tipo
        nombreCliente, // Cliente
        "${detalles[i].idProducto}", // Código del producto
        nombreProducto, // Descripción del producto
        "${detalles[i].cantidadProducto}", // Cantidad
        "${precioCompraUnidad.toStringAsFixed(2)}", // Precio de compra por unidad
        "${detalles[i].precioUnidadProducto.toStringAsFixed(2)}", // Precio de venta por unidad
        detalles[i].descuentoProducto?.toStringAsFixed(2) ?? '0.00', // Descuento
        detalles[i].subtotalProducto.toStringAsFixed(2), // Subtotal
        "${detalles[i].gananciaProducto.toStringAsFixed(2)}", // Ganancia
        estado // Estado
      ]);
    }
  }
  return {"data": data, "ganancia": ganancia, "total": total};
}
