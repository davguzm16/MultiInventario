import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}
//para agregar una pantalla de carga
class _ReportsPageState extends State<ReportsPage> {
  bool _isLoading = false;
  final ReportController report = ReportController();
  void _generateReport() async {
    setState(() {
      _isLoading = true;
    });
    await generarVentasContado(context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Reportes")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            //boton de ejemplo
            : ElevatedButton(
                onPressed: _generateReport,
                child: const Text("Ver Reporte Ventas Contado (ejemplo)"),
              ),
      ),
    );
  }
  //ejemplo de reporte
    Future<void> generarVentasContado(BuildContext context) async {

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text("Reporte de ventas al contado",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Fecha: 01/01/2025 - 31/01/2025"),
            pw.Text("Total: S/ 1000.00"),
            pw.Text("Ganancias estimadas: S/ 300.00"),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                "Fecha y hora", "Código de venta", "Cliente", "Subtotal (S/)", "Descuento (S/)", "Monto total (S/)", "Ganancias (S/)"
              ],
              data: List.generate(12, (index) => ["01/01/2023 07:35", "", "~~", "6.00", "0.10", "5.90", "0.50"]),
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColors.black, borderRadius: pw.BorderRadius.circular(2)),
              headerAlignments: {0: pw.Alignment.center, 1: pw.Alignment.center, 2: pw.Alignment.centerLeft, 3: pw.Alignment.center, 4: pw.Alignment.center, 5: pw.Alignment.center, 6: pw.Alignment.center},
            ),
          ];
        },
      ),
    );
    //metodos de report_controller.dart
    
    //generar pdf
    final path = await report.generarPDF(pdf, "ventas_contado.pdf");
    //mostrar pdf
    report.mostrarPDF(context, path);
  }
}

