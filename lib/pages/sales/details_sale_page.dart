// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';

class DetailsSalePage extends StatefulWidget {
  final int idVenta;

  const DetailsSalePage({super.key, required this.idVenta});

  @override
  State<DetailsSalePage> createState() => _DetailsSalePageState();
}

class _DetailsSalePageState extends State<DetailsSalePage> {
  List<DetalleVenta> detallesVenta = [];
  Venta? venta;
  Cliente? cliente;

  @override
  void initState() {
    super.initState();
    _obtenerDatosVenta();
  }

  Future<void> _obtenerDatosVenta() async {
    try {
      Venta? ventaDetails = await Venta.obtenerVentaPorID(widget.idVenta);
      if (ventaDetails != null) {
        setState(() {
          venta = ventaDetails;
        });

        List<DetalleVenta> detalles =
            await DetalleVenta.obtenerDetallesPorVenta(widget.idVenta);
        setState(() {
          detallesVenta = detalles;
        });

        Cliente? clienteDetails =
            await Cliente.obtenerClientePorId(venta!.idCliente);
        setState(() {
          cliente = clienteDetails;
        });
      } else {
        ErrorDialog(
            context: context, errorMessage: "No se pudo encontrar la venta.");
      }
    } catch (e) {
      ErrorDialog(
          context: context,
          errorMessage:
              "Hubo un error al obtener los detalles de la venta: ${e.toString()}");
    }
  }

  void showCancelarDialog() {
    TextEditingController montoACancelarController = TextEditingController();

    double montoTotal = venta!.montoTotal;
    double montoCancelado = venta!.montoCancelado ?? 0.0;
    double montoPendiente = montoTotal - montoCancelado;
    double montoFaltante = montoPendiente; // Inicialmente igual a pendiente

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFF493D9E), width: 2),
              ),
              title: const Text(
                'Cancelar deuda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF493D9E), // Morado
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMontoText('Monto total', montoTotal),
                  _buildMontoText('Monto cancelado', montoCancelado),
                  _buildMontoText('Monto pendiente', montoPendiente),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Monto a cancelar',
                    controller: montoACancelarController,
                    keyboardType: TextInputType.number,
                    isPrice: true,
                    onChanged: (value) {
                      double montoIngresado = double.tryParse(value) ?? 0.0;
                      setState(() {
                        montoFaltante = (montoPendiente - montoIngresado)
                            .clamp(0.0, montoPendiente);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMontoText('Monto faltante', montoFaltante, true),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BBF55), // Verde
                      foregroundColor: Colors.white, // Texto blanco
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      double montoACancelar =
                          double.tryParse(montoACancelarController.text) ?? 0.0;

                      if (montoACancelar <= 0 ||
                          montoACancelar > montoPendiente) {
                        ErrorDialog(
                          context: context,
                          errorMessage: 'Monto inválido',
                        );
                        return;
                      }

                      bool actualizado = await Venta.actualizarMontoCancelado(
                          venta!.idVenta!, montoACancelar);

                      if (actualizado) {
                        bool esDeudor = await Cliente.verificarEstadoDeudor(
                            venta!.idCliente);

                        SuccessDialog(
                          context: context,
                          successMessage: 'Monto actualizado correctamente!',
                          btnOkOnPress: () async {
                            await _obtenerDatosVenta();
                            setState(() {});
                            context.pop();

                            if (!esDeudor) {
                              context.go("/clients");
                            }
                          },
                        );
                      } else {
                        ErrorDialog(
                          context: context,
                          errorMessage: 'Error al actualizar el monto',
                        );
                      }
                    },
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMontoText(String label, double amount,
      [bool isDynamic = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDynamic ? Color(0xFFE63946) : Color(0xFF493D9E),
            ),
          ),
          Text(
            'S/${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: isDynamic ? Color(0xFFE63946) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (venta != null) ...[
            IconButton(
              icon: Icon(
                Icons.attach_money,
                color: !(venta!.esAlContado!) &&
                        (venta!.montoCancelado! < venta!.montoTotal)
                    ? Colors.black
                    : Colors.grey,
              ),
              onPressed: !(venta!.esAlContado!) &&
                      (venta!.montoCancelado! < venta!.montoTotal)
                  ? () => showCancelarDialog()
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.print,
                color: venta!.montoTotal > 5 ? Colors.black : Colors.grey,
              ),
              onPressed:
                  venta!.montoTotal > 5 ? () => generateBoletaVenta() : null,
            ),
          ],
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: venta == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Código de la venta",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                venta?.codigoBoleta ?? "-" * 13,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente: ${cliente?.nombreCliente ?? '-----'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'DNI: ${(cliente?.dniCliente?.isNotEmpty ?? false) ? cliente!.dniCliente as String : '-------'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Fecha: ${venta?.fechaVenta?.toIso8601String().split('T')[0] ?? "---"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Hora: ${venta?.fechaVenta?.toIso8601String().split('T')[1].split('.')[0] ?? "---"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Monto total: ${venta!.montoTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Monto cancelado: ${venta!.montoCancelado!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Tipo de pago: ${venta?.esAlContado == true ? "Al contado" : "Crédito"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF493D9E),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Tabla con los encabezados y los registros
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color(0xFF493D9E), width: 1.5),
                        ),
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(
                                width: 1.5, color: Color(0xFF493D9E)),
                            verticalInside: BorderSide(
                                width: 1.5, color: Color(0xFF493D9E)),
                          ),
                          columnWidths: {
                            0: FlexColumnWidth(0.5),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(0.6),
                            3: FlexColumnWidth(0.6),
                          },
                          children: [
                            // Encabezado de la tabla
                            TableRow(
                              children: [
                                _buildTableCellHeader('Ud'),
                                _buildTableCellHeader('Descripción'),
                                _buildTableCellHeader('Precio'),
                                _buildTableCellHeader('Subtotal'),
                              ],
                            ),
                            // Filas de los registros
                            ...detallesVenta.map((detalle) {
                              return TableRow(
                                children: [
                                  _buildTableCell(
                                      "${detalle.cantidadProducto} kg"),
                                  FutureBuilder<Producto?>(
                                    future: Producto.obtenerProductoPorID(
                                        detalle.idProducto),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildTableCell("Cargando...");
                                      } else if (snapshot.hasError) {
                                        return _buildTableCell("Error");
                                      } else if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return _buildTableCell(
                                            snapshot.data!.nombreProducto);
                                      } else {
                                        return _buildTableCell("No encontrado");
                                      }
                                    },
                                  ),
                                  _buildTableCell(detalle.precioUnidadProducto
                                      .toStringAsFixed(2)),
                                  _buildTableCell(detalle.subtotalProducto
                                      .toStringAsFixed(2)),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTableCellHeader(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF493D9E),
            fontSize: 13),
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13),
      ),
    );
  }

//metodo para generar la boleta
  Future<void> generateBoletaVenta() async {
    final pdf = pw.Document();
    final ReportController report = ReportController();
    final datos = await obtenerDatosTabla();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      children: [
                        pw.Text("Multiservicios Emma",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#0e5087'),
                              width: 1,
                            ),
                          ),
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Column(
                              children: [pw.Text('De: Emma Belido Melendez')]),
                        ),
                        pw.Text(
                            "VENTA DE ABARROTES, ARTÍCULOS DE \n FERRETERIA, LIBRERÍA Y OTROS",
                            textAlign: pw.TextAlign.center,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            "Av. José Carlos Mariátegui N°200 Quinuapata Ayacucho - Huamanga - Ayacucho",
                            textAlign: pw.TextAlign.center,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Cel.: #999616681"),
                        pw.SizedBox(height: 10),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      children: [
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#0e5087'),
                              width: 2,
                            ),
                          ),
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'R.U.C N° 10282899618',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0e5087'),
                                  fontSize: 18,
                                ),
                              ),
                              pw.Text(
                                'BOLETA DE VENTA',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0e5087'),
                                  fontSize: 18,
                                ),
                              ),
                              pw.Text(
                                '002 - ${venta?.codigoBoleta ?? "---"}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0e5087'),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#0e5087'),
                              width: 2,
                            ),
                          ),
                          child: pw.Column(children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Container(
                                    color: PdfColor.fromHex('#0e5087'),
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      "DÍA",
                                      style: pw.TextStyle(
                                        color: PdfColors.white, // Texto blanco
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 2, // Línea divisoria
                                  color: PdfColor.fromHex('#0e5087'),
                                ),
                                pw.Expanded(
                                  child: pw.Container(
                                    color: PdfColor.fromHex('#0e5087'),
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      "MES",
                                      style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 2,
                                  color: PdfColor.fromHex('#0e5087'),
                                ),
                                pw.Expanded(
                                  child: pw.Container(
                                    color: PdfColor.fromHex('#0e5087'),
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      "AÑO",
                                      style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Container(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      venta?.fechaVenta?.day
                                              .toString()
                                              .padLeft(2, '0') ??
                                          "--",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 2, // Línea divisoria
                                  color: PdfColor.fromHex('#0e5087'),
                                ),
                                pw.Expanded(
                                  child: pw.Container(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      venta?.fechaVenta?.month
                                              .toString()
                                              .padLeft(2, '0') ??
                                          "--",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 2,
                                  color: PdfColor.fromHex('#0e5087'),
                                ),
                                pw.Expanded(
                                  child: pw.Container(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 5),
                                    alignment: pw.Alignment.center,
                                    child: pw.Text(
                                      venta?.fechaVenta?.year.toString() ??
                                          "---",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                        pw.SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Text("Cliente: ${cliente?.nombreCliente ?? '--'}",
                  textAlign: pw.TextAlign.left),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Dni: ${cliente?.dniCliente ?? '--'}')]),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(50),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(80),
                  3: pw.FixedColumnWidth(80),
                },
                headers: [
                  pw.Text("CANT.", textAlign: pw.TextAlign.center),
                  pw.Text("DESCRIPCIÓN", textAlign: pw.TextAlign.center),
                  pw.Text("P. UNIT.", textAlign: pw.TextAlign.center),
                  pw.Text("TOTAL", textAlign: pw.TextAlign.center),
                ],
                data: datos,
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("TOTAL S/ ${venta?.montoTotal}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    //metodos de report_controller.dart

    //generar pdf
    final path = await report.generarPDF(pdf, "boleta.pdf");
    //mostrar pdf
    report.mostrarPDF(context, path);
  }

  //extraer los datos para la tabla
  Future<List<List<String>>> obtenerDatosTabla() async {
    List<List<String>> data = [];
    List<DetalleVenta> detalles = [];
    try {
      if (venta?.idVenta != null) {
        detalles =
            await DetalleVenta.obtenerDetallesPorVenta(venta!.idVenta as int);
        for (int i = 0; i < detalles.length; i++) {
          Producto? producto =
              await Producto.obtenerProductoPorID(detalles[i].idProducto);
          String nombreProducto =
              producto != null ? producto.nombreProducto : "Desconocido";
          data.add([
            "${detallesVenta[i].cantidadProducto}",
            nombreProducto,
            "${detallesVenta[i].precioUnidadProducto}",
            "${detallesVenta[i].subtotalProducto}"
          ]);
        }
      }
    } catch (e) {
      debugPrint("error: ${e.toString()}");
      return [];
    }
    return data;
  }
}
