import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/lote.dart';

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
  // ignore: unused_field
  bool _isLoading = false;

  //pantalla de carga
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

  // ignore: non_constant_identifier_names
  bool Selected = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Reportes"),
        ),
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 16), // Ajusta el espacio según necesites
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
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 16), // Ajusta el espacio según necesites
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
                SizedBox(height: 16),
                _buildButton("Reporte general detallado de ventas",
                    _selectedReport, context, (selected) {
                  setState(() {
                    _selectedReport = selected;
                  });
                }),
                SizedBox(height: 16),
                _buildButton("Reporte detallado de ventas al contado",
                    _selectedReport, context, (selected) {
                  setState(() {
                    _selectedReport = selected;
                  });
                }),
                SizedBox(height: 16),
                _buildButton("Reporte detallado de ventas al crédito",
                    _selectedReport, context, (selected) {
                  setState(() {
                    _selectedReport = selected;
                  });
                }),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Elegir rango",
                  style: TextStyle(color: Color(0xFF493D9E)),
                ),
                SizedBox(
                  height: 16,
                ),
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
                                borderSide: BorderSide(
                                  color: Color(0xFF493D9e),
                                ))),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedFechaInicio.isAfter(selectedFechaFinal)
                                    ? selectedFechaFinal
                                    : selectedFechaInicio,
                            firstDate: DateTime(2000),
                            lastDate:
                                selectedFechaFinal.isBefore(DateTime(2000))
                                    ? DateTime(2000)
                                    : selectedFechaFinal,
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
                                borderSide: BorderSide(
                                  color: Color(0xFF493D9e),
                                ))),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedFechaFinal.isBefore(selectedFechaInicio)
                                    ? selectedFechaInicio
                                    : selectedFechaFinal,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedFechaFinal = picked;
                              fechaFinal.text =
                                  picked.toIso8601String().split('T')[0];
                              if (selectedFechaInicio
                                  .isAfter(selectedFechaFinal)) {
                                selectedFechaInicio = selectedFechaFinal;
                                fechaInicio.text = selectedFechaFinal
                                    .toIso8601String()
                                    .split('T')[0];
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF493D9e),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _generateReport(
                            selectedFechaInicio, selectedFechaFinal);
                      },
                      child: const Text("Generar",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          )),
                    ))
              ],
            )));
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
        backgroundColor: isSelected ? Color(0xFF493D9E) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Color(0xFF493D9E),
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
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text("Reporte general detallado de ventas",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${selectedFechaInicio.toString().split(" ")[0]} - ${selectedFechaFinal.toString().split(" ")[0]}"),
            pw.Text("Total: S/ $total"),
            pw.Text("Ganancias estimadas: S/ $ganancia"),
            pw.SizedBox(height: 10),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha y hora",
                "Codigo de venta",
                "Tipo",
                "Cliente",
                "Codigo del producto",
                "Descripcion del producto",
                "Cantidad",
                "Precio de compra por unidad (S/)",
                "Precio de ventar por unidad (S/)",
                "Descuento (S/)",
                "Subtotal (S/)",
                "Ganancia estimada (S/)",
                "Estado"
              ],
              //generar filas
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
              //Ajustar tamaño
              columnWidths: {
                0: pw.FixedColumnWidth(35), // Índice
                1: pw.FixedColumnWidth(60), // Fecha y hora
                2: pw.FixedColumnWidth(50), // Código de venta
                3: pw.FixedColumnWidth(50), // Tipos
                4: pw.FixedColumnWidth(80), // Cliente
                5: pw.FixedColumnWidth(60), // Codigo del producto
                6: pw.FixedColumnWidth(80), // Descripcion
                7: pw.FixedColumnWidth(35), // Cantidad
                8: pw.FixedColumnWidth(55), // Precio de compra
                9: pw.FixedColumnWidth(55), // Precio de venta
                10: pw.FixedColumnWidth(60), // Descuento
                11: pw.FixedColumnWidth(60), // Subtotal
                12: pw.FixedColumnWidth(60), // ganancia
                13: pw.FixedColumnWidth(60) //estado
              },
            ),
          ];
        },
      ),
    );
  } catch (e) {
    debugPrint("Error $e");
  }
  //metodos de report_controller.dart

  //generar pdf
  final path = await report.generarPDF(pdf, "reporte_detalles_general.pdf");
  //mostrar pdf
  // ignore: use_build_context_synchronously
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
      "${i + 1}", //indice
      "${ventas?.fechaVenta}", //fecha y hora
      "${ventas?.idVenta}", //codigo de venta
      ((ventas?.esAlContado == true) ? "Contado" : "Crédito"), //tipo
      nombreCliente, //cliente
      "${detalles[i].idProducto}", //codigo del producto
      nombreProducto, //nombre del produvto (descripcion del producto)
      "${detalles[i].cantidadProducto}", //cantidad
      "$precioCompraUnidad", //precio compra unidad
      "${detalles[i].precioUnidadProducto}", //precio venta por unidad
      "${detalles[i].descuentoProducto}", //descuento
      "${detalles[i].subtotalProducto}", //subtotal
      "${detalles[i].gananciaProducto}", //ganancia
      estado
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
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text(
                "Reporte detallado de ventas al ${(tipo == true) ? "contado" : "crédito"}",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${selectedFechaInicio.toString().split(" ")[0]} - ${selectedFechaFinal.toString().split(" ")[0]}"),
            pw.Text("Total: S/ $total"),
            pw.Text("Ganancias estimadas: S/ $ganancia"),
            pw.SizedBox(height: 10),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha y hora",
                "Codigo de venta",
                "Tipo",
                "Cliente",
                "Codigo del producto",
                "Descripcion del producto",
                "Cantidad",
                "Precio de compra por unidad (S/)",
                "Precio de ventar por unidad (S/)",
                "Descuento (S/)",
                "Subtotal (S/)",
                "Ganancia estimada (S/)",
                "Estado"
              ],
              //generar filas
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
              //Ajustar tamaño
              columnWidths: {
                0: pw.FixedColumnWidth(35), // Índice
                1: pw.FixedColumnWidth(60), // Fecha y hora
                2: pw.FixedColumnWidth(50), // Código de venta
                3: pw.FixedColumnWidth(50), // Tipos
                4: pw.FixedColumnWidth(80), // Cliente
                5: pw.FixedColumnWidth(60), // Codigo del producto
                6: pw.FixedColumnWidth(80), // Descripcion
                7: pw.FixedColumnWidth(35), // Cantidad
                8: pw.FixedColumnWidth(55), // Precio de compra
                9: pw.FixedColumnWidth(55), // Precio de venta
                10: pw.FixedColumnWidth(60), // Descuento
                11: pw.FixedColumnWidth(60), // Subtotal
                12: pw.FixedColumnWidth(60), // ganancia
                13: pw.FixedColumnWidth(60) //estado
              },
            ),
          ];
        },
      ),
    );
  } catch (e) {
    debugPrint("Error $e");
  }
  //metodos de report_controller.dart

  //generar pdf
  final path = await report.generarPDF(
      pdf, "reporte_detalles_${(tipo == true) ? 'contado' : 'credito'}.pdf");
  //mostrar pdf
  // ignore: use_build_context_synchronously
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
        "${i + 1}", //indice
        "${ventas?.fechaVenta}", //fecha y hora
        "${ventas?.idVenta}", //codigo de venta
        ((ventas?.esAlContado == true) ? "Contado" : "Crédito"), //tipo
        nombreCliente, //cliente
        "${detalles[i].idProducto}", //codigo del producto
        nombreProducto, //nombre del produvto (descripcion del producto)
        "${detalles[i].cantidadProducto}", //cantidad
        "$precioCompraUnidad", //precio compra unidad
        "${detalles[i].precioUnidadProducto}", //precio venta por unidad
        "${detalles[i].descuentoProducto}", //descuento
        "${detalles[i].subtotalProducto}", //subtotal
        "${detalles[i].gananciaProducto}", //ganancia
        estado
      ]);
    }
  }
  return {"data": data, "ganancia": ganancia, "total": total};
}
