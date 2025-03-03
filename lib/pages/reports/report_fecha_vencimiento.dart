// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:intl/intl.dart';

class ReportFechaVencimiento extends StatefulWidget {
  const ReportFechaVencimiento({super.key});

  @override
  State<ReportFechaVencimiento> createState() => _ReportFechaVencimientoState();
}

class _ReportFechaVencimientoState extends State<ReportFechaVencimiento> {
  late TextEditingController diasController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    diasController = TextEditingController(text: '30'); // Por defecto 30 días
  }

  @override
  void dispose() {
    diasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Vencimientos"),
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
                  "Reporte de productos por vencer",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Días restantes para vencimiento",
              style: TextStyle(
                  color: Color(0xFF493D9E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              height: 50,
              child: TextField(
                controller: diasController,
                decoration: InputDecoration(
                    labelText: 'Días',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Color(0xFF493D9e)),
                    )),
                keyboardType: TextInputType.number,
              ),
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
                onPressed: _isLoading ? null : () => _generateReport(),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Generar",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    if (diasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese la cantidad de días')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await generarReporteVencimiento(context, int.parse(diasController.text));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> obtenerDatosVencimiento(
      int diasRestantes) async {
    List<List<String>> data = [];
    int totalProductos = 0;
    double valorTotal = 0;
    DateTime fechaLimite = DateTime.now().add(Duration(days: diasRestantes));
    final DateFormat dateFormat = DateFormat('dd/MM/yy');

    try {
      // Obtener todos los productos usando el método existente
      List<Producto> productos = await Producto.obtenerProductosPorNombre("");

      for (var producto in productos) {
        // Solo procesar productos disponibles y con stock
        if (producto.estaDisponible == true && producto.stockActual! > 0) {
          List<Lote> lotes =
              await Lote.obtenerLotesDeProducto(producto.idProducto!);

          for (var lote in lotes) {
            if (lote.cantidadActual > 0 &&
                lote.fechaCaducidad != null &&
                lote.fechaCaducidad!.isBefore(fechaLimite)) {
              int diasParaVencer =
                  lote.fechaCaducidad!.difference(DateTime.now()).inDays;
              String estado = diasParaVencer < 0 ? 'Vencido' : 'Por vencer';
              double valorLote = lote.cantidadActual * producto.precioProducto;

              data.add([
                "${data.length + 1}",
                producto.codigoProducto ?? producto.idProducto.toString(),
                producto.nombreProducto,
                lote.cantidadActual.toString(),
                lote.idLote.toString(),
                dateFormat.format(lote.fechaCaducidad!),
                diasParaVencer.abs().toString(),
                estado,
                valorLote.toStringAsFixed(2)
              ]);

              totalProductos += lote.cantidadActual;
              valorTotal += valorLote;
            }
          }
        }
      }

      // Ordenar por días para vencer (ascendente)
      data.sort((a, b) => int.parse(a[6]).compareTo(int.parse(b[6])));
    } catch (e) {
      debugPrint("Error al obtener datos de vencimiento: $e");
    }

    return {
      "data": data,
      "totalProductos": totalProductos,
      "valorTotal": valorTotal
    };
  }

  Future<void> generarReporteVencimiento(
      BuildContext context, int diasRestantes) async {
    final ReportController report = ReportController();
    final pdf = pw.Document();
    final datosTablaGeneral = await obtenerDatosVencimiento(diasRestantes);
    final datosTabla = datosTablaGeneral["data"] as List<List<String>>;
    final totalProductos = datosTablaGeneral["totalProductos"] as int;
    final valorTotal = datosTablaGeneral["valorTotal"] as double;

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text("Reporte de Productos por Vencer",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  "Productos que vencerán en los próximos $diasRestantes días"),
              pw.Text("Total de productos: $totalProductos"),
              pw.Text(
                  "Valor total del inventario por vencer: S/ ${valorTotal.toStringAsFixed(2)}"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#",
                  "Código",
                  "Producto",
                  "Cantidad",
                  "Lote",
                  "Fecha Vencimiento",
                  "Días",
                  "Estado",
                  "Valor (S/)"
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
                columnWidths: {
                  0: pw.FixedColumnWidth(35), // #
                  1: pw.FixedColumnWidth(60), // Código
                  2: pw.FixedColumnWidth(120), // Producto
                  3: pw.FixedColumnWidth(60), // Cantidad
                  4: pw.FixedColumnWidth(50), // Lote
                  5: pw.FixedColumnWidth(80), // Fecha Vencimiento
                  6: pw.FixedColumnWidth(40), // Días
                  7: pw.FixedColumnWidth(60), // Estado
                  8: pw.FixedColumnWidth(70), // Valor
                },
              ),
            ];
          },
        ),
      );

      final path = await report.generarPDF(pdf, "reporte_vencimientos.pdf");
      if (context.mounted) {
        await report.mostrarPDF(context, path);
      }
    } catch (e) {
      debugPrint("Error al generar PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el reporte: $e')),
        );
      }
    }
  }
}
