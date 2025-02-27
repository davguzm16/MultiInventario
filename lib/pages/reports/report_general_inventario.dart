import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/lote.dart';

class ReportGeneralInventario extends StatefulWidget {
  const ReportGeneralInventario({super.key});

  @override
  State<ReportGeneralInventario> createState() =>
      _ReportGeneralInventarioState();
}

class _ReportGeneralInventarioState extends State<ReportGeneralInventario> {
  late TextEditingController fechaController;
  DateTime selectedFecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fechaController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
  }

  @override
  void dispose() {
    fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes de Inventario"),
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
                  "Reporte general de inventario",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Seleccionar fecha",
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
                controller: fechaController,
                decoration: InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Color(0xFF493D9e)),
                    )),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedFecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedFecha = picked;
                      fechaController.text =
                          picked.toIso8601String().split('T')[0];
                    });
                  }
                },
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
    setState(() => _isLoading = true);
    try {
      await generarReporteInventario(context, selectedFecha);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> generarReporteInventario(
      BuildContext context, DateTime fecha) async {
    final ReportController report = ReportController();
    final pdf = pw.Document();
    final datosTablaGeneral = await obtenerDatosInventario(fecha);
    final datosTabla = datosTablaGeneral["data"] as List<List<String>>;
    final valorTotal = datosTablaGeneral["valorTotal"] as double;

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text("Reporte General de Inventario",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Fecha de corte: ${fecha.toString().split(' ')[0]}"),
              pw.Text(
                  "Valor total del inventario: S/ ${valorTotal.toStringAsFixed(2)}"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#",
                  "Código",
                  "Producto",
                  "Stock Total",
                  "Lotes Activos",
                  "Precio Promedio (S/)",
                  "Valor Total (S/)"
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
                  3: pw.FixedColumnWidth(60), // Stock Total
                  4: pw.FixedColumnWidth(60), // Lotes Activos
                  5: pw.FixedColumnWidth(80), // Precio Promedio
                  6: pw.FixedColumnWidth(70), // Valor Total
                },
              ),
            ];
          },
        ),
      );

      final path = await report.generarPDF(pdf, "reporte_inventario.pdf");
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

  Future<Map<String, dynamic>> obtenerDatosInventario(DateTime fecha) async {
    List<List<String>> data = [];
    double valorTotal = 0;

    try {
      List<Producto> productos = await Producto.obtenerTodosLosProductos();

      for (var producto in productos) {
        if(producto.estaDisponible == true){
        if (producto.stockActual != null && producto.stockActual! > 0) {
          List<Lote> lotes =
              await Lote.obtenerLotesDeProducto(producto.idProducto!);

          int lotesActivos =
              lotes.where((lote) => lote.cantidadActual > 0).length;
          double valorProducto =
              producto.stockActual! * producto.precioProducto;
          valorTotal += valorProducto;

          data.add([
            "${data.length + 1}",
            producto.codigoProducto ?? producto.idProducto.toString(),
            producto.nombreProducto,
            producto.stockActual!.toStringAsFixed(2),
            lotesActivos.toString(),
            producto.precioProducto.toStringAsFixed(2),
            valorProducto.toStringAsFixed(2),
          ]);
        }}
      }
    } catch (e) {
      debugPrint("Error al obtener datos del inventario: $e");
    }

    return {"data": data, "valorTotal": valorTotal};
  }
}
