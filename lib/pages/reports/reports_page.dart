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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reportes"),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1, // Aumentado para centrar mejor
                vertical: screenHeight * 0.02,
              ),
              child: GridView.count(
                crossAxisCount: 1, // Cambiado a 1 columna
                mainAxisSpacing: 10, // Espaciado fijo entre botones
                childAspectRatio:
                    4.0, // Ajustado para botones más anchos que altos
                children: [
                  _buildReportButton(
                    title: "Reporte Detallado de Ventas",
                    icon: Icons.receipt_long,
                    onPressed: () => _generateDetailedSalesReport(),
                  ),
                  _buildReportButton(
                    title: "Reporte de Ventas",
                    icon: Icons.point_of_sale,
                    onPressed: () => _generateSalesReport(),
                  ),
                  _buildReportButton(
                    title: "Reporte de Productos Vendidos",
                    icon: Icons.shopping_cart,
                    onPressed: () => _generateSoldProductsReport(),
                  ),
                  _buildReportButton(
                    title: "Reporte de Inventario",
                    icon: Icons.inventory,
                    onPressed: () => _generateInventoryReport(),
                  ),
                  _buildReportButton(
                    title: "Reporte de Lotes",
                    icon: Icons.ballot,
                    onPressed: () => _generateLotsReport(),
                  ),
                  _buildReportButton(
                    title: "Reporte de Deudores",
                    icon: Icons.account_balance,
                    onPressed: () => _generateDebtorsReport(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReportButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            // Cambiado a Row para layout horizontal
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.purple,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos para generar cada tipo de reporte
  void _generateDetailedSalesReport() async {
    setState(() => _isLoading = true);
    try {
      await generarVentasContado(context); // Modifica esto según necesites
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateSalesReport() async {
    // Implementa la lógica para el reporte de ventas
  }

  void _generateSoldProductsReport() async {
    _showDateRangeDialog(
      'Reporte de Productos Vendidos',
      (DateTime startDate, DateTime endDate) async {
        setState(() => _isLoading = true);
        try {
          // Aquí implementa la lógica para generar el reporte
          // usando startDate y endDate
          debugPrint('Generando reporte desde ${startDate.toString()} '
              'hasta ${endDate.toString()}');
        } finally {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _generateInventoryReport() async {
    // Implementa la lógica para el reporte de inventario
  }

  void _generateLotsReport() async {
    // Implementa la lógica para el reporte de lotes
  }

  void _generateDebtorsReport() async {
    // Implementa la lógica para el reporte de deudores
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
