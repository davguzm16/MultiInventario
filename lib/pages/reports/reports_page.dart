// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:multiinventario/pages/reports/report_lotes.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:go_router/go_router.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _isLoading = false;
  final ReportController report = ReportController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis reportes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08, // Más centrado en la pantalla
                  vertical: screenHeight * 0.02,
                ),
                child: GridView.count(
                  crossAxisCount: 1,
                  mainAxisSpacing: 14,
                  childAspectRatio: 4.2, // Ajustado para mejor altura
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildReportButton(
                      title: "Reporte Detallado de Ventas",
                      icon: Icons.receipt_long,
                      onPressed: () async {
                        await context.push('/reports/report-details-page');
                      },
                    ),
                    _buildReportButton(
                      title: "Reporte de Ventas",
                      icon: Icons.point_of_sale,
                      onPressed: () async {
                        await context.push('/reports/report-sales-page');
                      },
                    ),
                    _buildReportButton(
                      title: "Reporte de Productos Vendidos",
                      icon: Icons.shopping_cart,
                      onPressed: () async {
                        await context
                            .push('/reports/report-productos-vendidos');
                      },
                    ),
                    _buildReportButton(
                      title: "Reporte de Inventario",
                      icon: Icons.inventory,
                      onPressed: () async {
                        await context
                            .push('/reports/report-general-inventario');
                      },
                    ),
                    _buildReportButton(
                      title: "Reporte de Lotes",
                      icon: Icons.ballot,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportLotesPage(),
                        ),
                      ),
                    ),
                    _buildReportButton(
                      title: "Reporte de Deudores",
                      icon: Icons.account_balance,
                      onPressed: () => _generateDebtorsReport(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReportButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF493D9E), width: 2),
        ),
        color: Colors.grey[100],
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF493D9E).withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF493D9E),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Métodos para generar cada tipo de reporte
  // ignore: unused_element
  void _generateDetailedSalesReport() async {
    _showDateRangeDialog(
      'Reporte Detallado de Ventas',
      (DateTime startDate, DateTime endDate) async {
        setState(() => _isLoading = true);
        try {
          // Implementa la lógica para generar el reporte detallado de ventas
          debugPrint(
              'Generando reporte detallado de ventas desde ${startDate.toString()} hasta ${endDate.toString()}');
        } finally {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _generateDebtorsReport() async {
    _showDateRangeDialog(
      'Reporte de Deudores',
      (DateTime startDate, DateTime endDate) async {
        setState(() => _isLoading = true);
        try {
          // Implementa la lógica para generar el reporte de deudores
          debugPrint(
              'Generando reporte de deudores desde ${startDate.toString()} hasta ${endDate.toString()}');
        } finally {
          setState(() => _isLoading = false);
        }
      },
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
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Fecha: 01/01/2025 - 31/01/2025"),
            pw.Text("Total: S/ 1000.00"),
            pw.Text("Ganancias estimadas: S/ 300.00"),
            pw.SizedBox(height: 10),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: [
                "Fecha y hora",
                "Código de venta",
                "Cliente",
                "Subtotal (S/)",
                "Descuento (S/)",
                "Monto total (S/)",
                "Ganancias (S/)"
              ],
              data: List.generate(
                  12,
                  (index) => [
                        "01/01/2023 07:35",
                        "",
                        "~~",
                        "6.00",
                        "0.10",
                        "5.90",
                        "0.50"
                      ]),
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                  fontSize: 12,
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
                6: pw.Alignment.center
              },
            ),
          ];
        },
      ),
    );
    //metodos de report_controller.dart

    //generar pdf
    final path = await report.generarPDF(pdf, "ventas_contado.pdf");
    //mostrar pdf
    // ignore: use_build_context_synchronously
    report.mostrarPDF(context, path);
  }

  void _showDateRangeDialog(
      String reportTitle, Function(DateTime, DateTime) onConfirm) {
    DateTime? startDate;
    DateTime? endDate;
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha de inicio',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  startDate = picked;
                  startDateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha final',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  endDate = picked;
                  endDateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (startDate != null && endDate != null) {
                Navigator.pop(context);
                onConfirm(startDate!, endDate!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, seleccione ambas fechas'),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
