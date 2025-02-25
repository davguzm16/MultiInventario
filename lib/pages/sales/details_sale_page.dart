// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/widgets/error_dialog.dart';

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
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(
                Icons.print,
                size: 35,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
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
                          'DNI: ${cliente?.dniCliente ?? "---"}',
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
                    border: Border.all(color: Color(0xFF493D9E), width: 1.5),
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside:
                          BorderSide(width: 1.5, color: Color(0xFF493D9E)),
                      verticalInside:
                          BorderSide(width: 1.5, color: Color(0xFF493D9E)),
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
                            _buildTableCell("${detalle.cantidadProducto} kg"),
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
                            _buildTableCell(
                                detalle.subtotalProducto.toStringAsFixed(2)),
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
}
