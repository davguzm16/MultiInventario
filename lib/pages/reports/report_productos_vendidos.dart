import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:multiinventario/controllers/db_controller.dart'; // Cambiar este import
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

class ReportProductosVendidos extends StatefulWidget {
  const ReportProductosVendidos({super.key});

  @override
  State<ReportProductosVendidos> createState() =>
      _ReportProductosVendidosState();
}

class _ReportProductosVendidosState extends State<ReportProductosVendidos> {
  late TextEditingController fechaInicio;
  late TextEditingController fechaFinal;
  DateTime selectedFechaInicio = DateTime.now();
  DateTime selectedFechaFinal = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fechaInicio = TextEditingController(
      text: DateFormat('dd/MM/yy').format(DateTime.now()),
    );
    fechaFinal = TextEditingController(
      text: DateFormat('dd/MM/yy').format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    fechaInicio.dispose();
    fechaFinal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Productos Vendidos"),
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
                  "Reporte de Productos Vendidos",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Elegir rango de fechas",
              style: TextStyle(
                  color: Color(0xFF493D9E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
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
                          fechaFinal.text =
                              DateFormat('dd/MM/yy').format(picked);
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
                onPressed: _isLoading ? null : () => _generateReport(),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Generar",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    try {
      await generarReporteProductos(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> generarReporteProductos(BuildContext context) async {
    final ReportController report = ReportController();
    final pdf = pw.Document();
    final datosTabla = await obtenerDatosTablaProductos(
        selectedFechaInicio, selectedFechaFinal);
    final datos = datosTabla["data"] as List<List<String>>;
    final totalVentas = datosTabla["totalVentas"] as double;
    final totalGanancias = datosTabla["totalGanancias"] as double;
    final totalProductos = datosTabla["totalProductos"] as int;
    final DateFormat dateFormat = DateFormat('dd/MM/yy');

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text("Reporte de Productos Vendidos",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  "Período: ${dateFormat.format(selectedFechaInicio)} - ${dateFormat.format(selectedFechaFinal)}"),
              pw.Text("Total de ventas: S/ ${totalVentas.toStringAsFixed(2)}"),
              pw.Text(
                  "Ganancias totales: S/ ${totalGanancias.toStringAsFixed(2)}"),
              pw.Text("Total de productos vendidos: $totalProductos"),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: [
                  "#",
                  "Código",
                  "Producto",
                  "Cantidad Total",
                  "Precio Unitario (S/)",
                  "Descuento Total (S/)",
                  "Total Ventas (S/)",
                  "Ganancias (S/)"
                ],
                data: datos,
                border: pw.TableBorder.all(),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(
                    color: PdfColors.black,
                    borderRadius: pw.BorderRadius.circular(2)),
                columnWidths: {
                  0: const pw.FixedColumnWidth(35), // #
                  1: const pw.FixedColumnWidth(60), // Código
                  2: const pw.FixedColumnWidth(120), // Producto
                  3: const pw.FixedColumnWidth(60), // Cantidad
                  4: const pw.FixedColumnWidth(70), // Precio
                  5: const pw.FixedColumnWidth(70), // Descuento
                  6: const pw.FixedColumnWidth(70), // Total
                  7: const pw.FixedColumnWidth(70), // Ganancias
                },
              ),
            ];
          },
        ),
      );

      final path = await report.generarPDF(pdf, "productos_vendidos.pdf");
      if (context.mounted) {
        await report.mostrarPDF(context, path);
      }
    } catch (e) {
      debugPrint("Error al generar PDF: $e");
    }
  }

  Future<Map<String, dynamic>> obtenerDatosTablaProductos(
      DateTime fechaInicio, DateTime fechaFinal) async {
    
    final db = await DatabaseController().database;
    final results = await db.rawQuery('''
      SELECT 
        p.codigoProducto as codigo,
        p.nombreProducto as producto,
        p.estaDisponible as disponible,
        SUM(dv.cantidadProducto) as cantidad_total,
        p.precioProducto as precio_unidad,
        SUM(dv.descuentoProducto) as descuento_total,
        SUM(dv.subtotalProducto) as total_ventas,
        SUM(dv.gananciaProducto) as ganancias
      FROM DetallesVentas dv
      JOIN Ventas v ON dv.idVenta = v.idVenta
      JOIN Productos p ON dv.idProducto = p.idProducto
      WHERE date(v.fechaVenta) BETWEEN ? AND ?
      GROUP BY p.idProducto, p.codigoProducto, p.nombreProducto, p.precioProducto, p.estaDisponible
      ORDER BY cantidad_total DESC
    ''', [
      fechaInicio.toIso8601String().split('T')[0],
      fechaFinal.toIso8601String().split('T')[0]
    ]);

    double totalVentas = 0;
    double totalGanancias = 0;
    int totalProductos = 0;
    final List<List<String>> data = [];

    for (var i = 0; i < results.length; i++) {
      final row = results[i];
      final disponible = (row['disponible'] as int) == 1;
      if(disponible == true){
      final cantidadTotal = row['cantidad_total'] as int;
      final totalVenta = row['total_ventas'] as double;
      final ganancia = row['ganancias'] as double;

      totalProductos += cantidadTotal;
      totalVentas += totalVenta;
      totalGanancias += ganancia;

      data.add([
        '${i + 1}',
        row['codigo']?.toString() ?? '---',
        row['producto']?.toString() ?? '---',
        cantidadTotal.toString(),
        'S/. ${(row['precio_unidad'] as double).toStringAsFixed(2)}',
        'S/. ${(row['descuento_total'] as double? ?? 0).toStringAsFixed(2)}',
        'S/. ${totalVenta.toStringAsFixed(2)}',
        'S/. ${ganancia.toStringAsFixed(2)}',
      ]);}
    }

    return {
      "data": data,
      "totalVentas": totalVentas,
      "totalGanancias": totalGanancias,
      "totalProductos": totalProductos,
    };
  }
}
