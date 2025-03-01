import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:multiinventario/models/lote.dart'; // Importa tu modelo de lotes
import 'package:multiinventario/models/detalle_venta.dart'; // Importa tu modelo de detalles de venta
import 'package:multiinventario/models/producto.dart'; // Importa tu modelo de productos

class ReportLotesPage extends StatefulWidget {
  const ReportLotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportLotesPageState createState() => _ReportLotesPageState();
}

class _ReportLotesPageState extends State<ReportLotesPage> {
  late TextEditingController fechaInicio;
  late TextEditingController fechaFinal;
  late TextEditingController _diasController;
  DateTime selectedFechaInicio = DateTime.now();
  DateTime selectedFechaFinal = DateTime.now();
  String _selectedReport = "Reporte general de lotes";
  // ignore: unused_field
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
    _diasController = TextEditingController();
  }

  @override
  void dispose() {
    fechaInicio.dispose();
    fechaFinal.dispose();
    _diasController.dispose();
    super.dispose();
  }

  Future<void> _generateReport(DateTime selectedFechaInicio,
      DateTime selectedFechaFinal, int diasAntesVencimiento) async {
    setState(() {
      _isLoading = true;
    });
    if(_selectedReport == "Reporte general de lotes"){
          await _generarPDFGeneral(
        selectedFechaInicio, selectedFechaFinal, diasAntesVencimiento);
    } else if(_selectedReport == "Reporte de lotes actuales"){
          await _generarPDFActual(
        selectedFechaInicio, selectedFechaFinal, diasAntesVencimiento);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _seleccionarFecha(
      BuildContext context,
      TextEditingController controller,
      DateTime initialDate,
      DateTime firstDate,
      DateTime lastDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _generarPDFGeneral(DateTime fechaInicio, DateTime fechaFinal,
      int diasAntesVencimiento) async {
    final pdf = pw.Document();

    // Obtener datos de los lotes desde los modelos
    final datosTablaLotes = await obtenerDatosTablaLotes(
        fechaInicio, fechaFinal, diasAntesVencimiento);
    final datos = datosTablaLotes["data"] as List<List<String>>;
    final totalLotes = datosTablaLotes["totalLotes"] as int;
    final totalValorCompra = datosTablaLotes["totalValorCompra"] as double;
    final lotesActuales = datosTablaLotes["lotesActuales"] as int;
    final lotesAcabados = datosTablaLotes["lotesAcabados"] as int;
    final lotesProximosAVencer = datosTablaLotes["lotesProximosAVencer"] as int;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text("Reporte General de Lotes",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${fechaInicio.toIso8601String().split('T')[0]} - ${fechaFinal.toIso8601String().split('T')[0]}"),
            pw.SizedBox(height: 10),
            pw.Text("Lotes Totales: $totalLotes"),
            pw.Text("Lotes Actuales: $lotesActuales"),
            pw.Text("Lotes Acabados: $lotesAcabados"),
            pw.Text("Lotes Próximos a Vencer: $lotesProximosAVencer"),
            pw.Text(
                "Valor de Compra Total: \$${totalValorCompra.toStringAsFixed(2)}"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha de Compra",
                "ID Lote",
                "Código Producto",
                "Descripción Producto",
                "Fecha de Vencimiento",
                "Cantidad Comprada",
                "Cantidad Actual",
                "Cantidad Perdida",
                "Cantidad Vendida",
                "Precio Total Compra",
                "Precio Unidad"
              ],
              data: datos,
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(2)),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FixedColumnWidth(40),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(80),
                5: const pw.FixedColumnWidth(60),
                6: const pw.FixedColumnWidth(60),
                7: const pw.FixedColumnWidth(60),
                8: const pw.FixedColumnWidth(60),
                9: const pw.FixedColumnWidth(60),
                10: const pw.FixedColumnWidth(60),
                11: const pw.FixedColumnWidth(60),
              },
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
                9: pw.Alignment.center,
                10: pw.Alignment.center,
                11: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reporte_general_lotes.pdf");
    await file.writeAsBytes(await pdf.save());

    // Navegar a la pantalla de visualización del PDF
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(path: file.path),
      ),
    );
  }

  Future<Map<String, dynamic>> obtenerDatosTablaLotes(DateTime fechaInicio,
      DateTime fechaFinal, int diasAntesVencimiento) async {
    List<Lote> lotes = [];
    List<List<String>> data = [];
    double totalValorCompra = 0.0;
    int lotesActuales = 0;
    int lotesAcabados = 0;
    int lotesProximosAVencer = 0;

    // Obtener lotes según el rango de fechas y días antes de vencimiento
    if (diasAntesVencimiento > 0) {
      lotes = await Lote.obtenerLotesPorRangoDeFechasYDias(
          fechaInicio, fechaFinal, diasAntesVencimiento);
    } else {
      lotes = await Lote.obtenerLotesporFecha(fechaInicio, fechaFinal);
    }

    int totalLotes = lotes.length;

    for (int i = 0; i < lotes.length; i++) {
      int cantidadVendida =
          await DetalleVenta.obtenerCantidadVendidaPorLote(lotes[i].idLote!);
      Producto? producto =
          await Producto.obtenerProductoPorID(lotes[i].idProducto);
      if (producto?.estaDisponible == true && producto?.estaDisponible != null) {
        totalValorCompra += lotes[i].precioCompra;

        if (lotes[i].cantidadActual > 0) {
          lotesActuales++;
        } else {
          lotesAcabados++;
        }

        if (diasAntesVencimiento > 0 &&
            lotes[i].fechaCaducidad != null &&
            lotes[i].fechaCaducidad!.isBefore(
                DateTime.now().add(Duration(days: diasAntesVencimiento)))) {
          lotesProximosAVencer++;
        }

        data.add([
          (i + 1).toString(), // Índice
          lotes[i].fechaCompra?.toIso8601String().split('T')[0] ?? '',
          lotes[i].idLote.toString(),
          lotes[i].idProducto.toString(),
          producto?.descripcion ?? '',
          lotes[i].fechaCaducidad?.toIso8601String().split('T')[0] ?? '',
          lotes[i].cantidadComprada.toString(),
          lotes[i].cantidadActual.toString(),
          lotes[i].cantidadPerdida?.toString() ?? '0',
          cantidadVendida.toString(),
          lotes[i].precioCompra.toString(),
          lotes[i].precioCompraUnidad.toStringAsFixed(1),
        ]);
      }
    }

    // Agregar mensajes de depuración
    debugPrint("Total de lotes: $totalLotes");
    debugPrint("Datos de la tabla: $data");

    return {
      "data": data,
      "totalLotes": totalLotes,
      "totalValorCompra": totalValorCompra,
      "lotesActuales": lotesActuales,
      "lotesAcabados": lotesAcabados,
      "lotesProximosAVencer": lotesProximosAVencer,
    };
  }

  Future<void> _generarPDFActual(DateTime fechaInicio, DateTime fechaFinal, int diasAntesVencimiento) async {
    final pdf = pw.Document();

    // Obtener datos de los lotes desde los modelos
    final datosTablaLotes = await obtenerDatosTablaLotesActual(
        fechaInicio, fechaFinal, diasAntesVencimiento);
    final datos = datosTablaLotes["data"] as List<List<String>>;
    final totalLotes = datosTablaLotes["totalLotes"] as int;
    final totalValorCompra = datosTablaLotes["totalValorCompra"] as double;
    final lotesActuales = datosTablaLotes["lotesActuales"] as int;
    final lotesAcabados = datosTablaLotes["lotesAcabados"] as int;
    final lotesProximosAVencer = datosTablaLotes["lotesProximosAVencer"] as int;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text("Reporte de Lotes Actuales",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Fecha: ${fechaInicio.toIso8601String().split('T')[0]} - ${fechaFinal.toIso8601String().split('T')[0]}"),
            pw.SizedBox(height: 10),
            pw.Text("Lotes Totales: $totalLotes"),
            pw.Text("Lotes Actuales: $lotesActuales"),
            pw.Text("Lotes Acabados: $lotesAcabados"),
            pw.Text("Lotes Próximos a Vencer: $lotesProximosAVencer"),
            pw.Text(
                "Valor de Compra Total: \$${totalValorCompra.toStringAsFixed(2)}"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "#",
                "Fecha de Compra",
                "ID Lote",
                "Código Producto",
                "Descripción Producto",
                "Fecha de Vencimiento",
                "Cantidad Comprada",
                "Cantidad Actual",
                "Cantidad Perdida",
                "Cantidad Vendida",
                "Precio Total Compra",
                "Precio Unidad",
                "Precio de Venta por unidad"
              ],
              data: datos,
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(2)),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FixedColumnWidth(40),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(80),
                5: const pw.FixedColumnWidth(60),
                6: const pw.FixedColumnWidth(60),
                7: const pw.FixedColumnWidth(60),
                8: const pw.FixedColumnWidth(60),
                9: const pw.FixedColumnWidth(60),
                10: const pw.FixedColumnWidth(60),
                11: const pw.FixedColumnWidth(60),
                12: const pw.FixedColumnWidth(60),
              },
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
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
              },
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reporte_lotes_actuales.pdf");
    await file.writeAsBytes(await pdf.save());

    // Navegar a la pantalla de visualización del PDF
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(path: file.path),
      ),
    );
  }

  Future<Map<String, dynamic>> obtenerDatosTablaLotesActual(DateTime fechaInicio,
      DateTime fechaFinal, int diasAntesVencimiento) async {
    List<Lote> lotes = [];
    List<List<String>> data = [];
    double totalValorCompra = 0.0;
    int lotesActuales = 0;
    int lotesAcabados = 0;
    int lotesProximosAVencer = 0;

    // Obtener lotes según el rango de fechas y días antes de vencimiento
    lotes = await Lote.obtenerLotesporFecha(fechaInicio, fechaFinal);
    int totalLotes = lotes.length;

    for (int i = 0; i < lotes.length; i++) {
      int cantidadVendida =
          await DetalleVenta.obtenerCantidadVendidaPorLote(lotes[i].idLote!);
      Producto? producto =
          await Producto.obtenerProductoPorID(lotes[i].idProducto);
      totalValorCompra += lotes[i].precioCompra;
      if (producto?.estaDisponible == true && producto?.estaDisponible != null) {
        if (lotes[i].cantidadActual > 0) {
          lotesActuales++;
        } else {
          lotesAcabados++;
        }

        if (lotes[i].fechaCaducidad != null &&
            lotes[i].fechaCaducidad!.isBefore(
                DateTime.now().add(Duration(days: diasAntesVencimiento)))) {
          lotesProximosAVencer++;
        }

        data.add([
          (i + 1).toString(), // Índice
          lotes[i].fechaCompra?.toIso8601String().split('T')[0] ?? '',
          lotes[i].idLote.toString(),
          lotes[i].idProducto.toString(),
          producto?.descripcion ?? '',
          lotes[i].fechaCaducidad?.toIso8601String().split('T')[0] ?? '',
          lotes[i].cantidadComprada.toString(),
          lotes[i].cantidadActual.toString(),
          lotes[i].cantidadPerdida?.toString() ?? '0',
          cantidadVendida.toString(),
          lotes[i].precioCompra.toString(),
          lotes[i].precioCompraUnidad.toStringAsFixed(1),
          '${producto?.precioProducto ?? '--'}'
        ]);
      }
    }

    // Agregar mensajes de depuración
    debugPrint("Total de lotes: $totalLotes");
    debugPrint("Datos de la tabla: $data");

    return {
      "data": data,
      "totalLotes": totalLotes,
      "totalValorCompra": totalValorCompra,
      "lotesActuales": lotesActuales,
      "lotesAcabados": lotesAcabados,
      "lotesProximosAVencer": lotesProximosAVencer,
    };
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Reporte General de Lotes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reporte de lotes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Elegir tipo',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(73, 61, 158, 1)),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      _buildButton(
                          'Reporte general de lotes', _selectedReport, context,
                          (selected) {
                        setState(() {
                          _selectedReport = selected;
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildButton(
                          'Reporte de lotes actuales', _selectedReport, context,
                          (selected) {
                        setState(() {
                          _selectedReport = selected;
                        });
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rango de fechas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(73, 61, 158, 1)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fechaInicio,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Inicio',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _seleccionarFecha(
                            context,
                            fechaInicio,
                            selectedFechaInicio,
                            DateTime(2000),
                            selectedFechaFinal),
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Espacio entre los cuadros de fecha
                    Expanded(
                      child: TextField(
                        controller: fechaFinal,
                        decoration: const InputDecoration(
                          labelText: 'Fecha Final',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _seleccionarFecha(
                            context,
                            fechaFinal,
                            selectedFechaFinal,
                            selectedFechaInicio,
                            DateTime.now()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Días antes que venza',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(73, 61, 158, 1)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 100, // Ajusta el ancho del cuadro de texto aquí
                  child: TextField(
                    controller: _diasController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '# Días',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(73, 61, 158, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final fechaInicioParsed =
                          DateTime.parse(fechaInicio.text);
                      final fechaFinalParsed = DateTime.parse(fechaFinal.text);
                      final diasAntesVencimiento =
                          int.tryParse(_diasController.text) ?? 0;
                      _generateReport(fechaInicioParsed, fechaFinalParsed,
                          diasAntesVencimiento);
                    },
                    child: const Text('Generar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, String selectedReport, BuildContext context,
      Function(String) onSelect) {
    bool isSelected = text == selectedReport;

    return SizedBox(
      width: 300, // Ajusta el ancho de los botones aquí
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color.fromRGBO(73, 61, 158, 1) : Colors.white,
          foregroundColor:
              isSelected ? Colors.white : const Color.fromRGBO(73, 61, 158, 1),
          side: const BorderSide(color: Color.fromRGBO(73, 61, 158, 1)),
        ),
        onPressed: () {
          onSelect(text);
        },
        child: Text(text),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String path;

  const PDFViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualizador de PDF"),
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
