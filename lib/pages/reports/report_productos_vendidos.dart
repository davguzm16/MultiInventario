// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes de Productos Vendidos"),
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
                  "Reporte de productos vendidos",
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
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Color(0xFF493D9e)),
                        )),
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
                              picked.toIso8601String().split('T')[0];
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
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Color(0xFF493D9e)),
                        )),
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
                              picked.toIso8601String().split('T')[0];
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
      await generarReporteProductosVendidos(
          context, selectedFechaInicio, selectedFechaFinal);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> obtenerDatosProductosVendidos(
      DateTime fechaInicio, DateTime fechaFinal) async {
    List<List<String>> data = [];
    double totalVentas = 0;
    int totalProductos = 0;

    try {
      List<DetalleVenta> detalles =
          await DetalleVenta.obtenerDetallesPorFechas(fechaInicio, fechaFinal);

      // Agrupar por producto
      Map<int, Map<String, dynamic>> productosAgrupados = {};

      for (var detalle in detalles) {
        Producto? producto =
            await Producto.obtenerProductoPorID(detalle.idProducto);
        if (producto != null) {
          if (!productosAgrupados.containsKey(producto.idProducto)) {
            productosAgrupados[producto.idProducto!] = {
              'producto': producto,
              'cantidadTotal': 0,
              'totalVentas': 0.0,
              'gananciaTotal': 0.0,
            };
          }

          productosAgrupados[producto.idProducto!]?['cantidadTotal'] +=
              detalle.cantidadProducto;
          productosAgrupados[producto.idProducto!]?['totalVentas'] +=
              detalle.subtotalProducto;
          productosAgrupados[producto.idProducto!]?['gananciaTotal'] +=
              detalle.gananciaProducto;
          totalProductos += detalle.cantidadProducto;
          totalVentas += detalle.subtotalProducto;
        }
      }

      // Convertir a lista y ordenar por cantidad vendida
      var productosOrdenados = productosAgrupados.values.toList()
        ..sort((a, b) =>
            (b['cantidadTotal'] as int).compareTo(a['cantidadTotal'] as int));

      // Generar datos para la tabla
      for (var i = 0; i < productosOrdenados.length; i++) {
        var item = productosOrdenados[i];
        var producto = item['producto'] as Producto;
        var cantidadTotal = item['cantidadTotal'] as int;
        var totalVentasProducto = item['totalVentas'] as double;
        var gananciaTotal = item['gananciaTotal'] as double;

        data.add([
          "${i + 1}",
          producto.codigoProducto ?? producto.idProducto.toString(),
          producto.nombreProducto,
          cantidadTotal.toString(),
          producto.precioProducto.toStringAsFixed(2),
          totalVentasProducto.toStringAsFixed(2),
          gananciaTotal.toStringAsFixed(2),
          ((totalVentasProducto / totalVentas) * 100).toStringAsFixed(2)
        ]);
      }
    } catch (e) {
      debugPrint("Error al obtener datos de productos vendidos: $e");
    }

    return {
      "data": data,
      "totalVentas": totalVentas,
      "totalProductos": totalProductos
    };
  }

  Future<void> generarReporteProductosVendidos(
      BuildContext context, DateTime fechaInicio, DateTime fechaFinal) async {
    final ReportController report = ReportController();
    final pdf = pw.Document();
    final datosTablaGeneral =
        await obtenerDatosProductosVendidos(fechaInicio, fechaFinal);
    final datosTabla = datosTablaGeneral["data"] as List<List<String>>;
    final totalVentas = datosTablaGeneral["totalVentas"] as double;
    final totalProductos = datosTablaGeneral["totalProductos"] as int;

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
                  "Periodo: ${fechaInicio.toString().split(' ')[0]} - ${fechaFinal.toString().split(' ')[0]}"),
              pw.Text("Total de ventas: S/ ${totalVentas.toStringAsFixed(2)}"),
              pw.Text("Total de productos vendidos: $totalProductos"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#",
                  "Código",
                  "Producto",
                  "Cantidad Vendida",
                  "Precio Unitario (S/)",
                  "Total Ventas (S/)",
                  "Ganancia (S/)",
                  "% del Total"
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
                  3: pw.FixedColumnWidth(70), // Cantidad
                  4: pw.FixedColumnWidth(70), // Precio
                  5: pw.FixedColumnWidth(70), // Total Ventas
                  6: pw.FixedColumnWidth(70), // Ganancia
                  7: pw.FixedColumnWidth(60), // Porcentaje
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el reporte: $e')),
        );
      }
    }
  }
}
