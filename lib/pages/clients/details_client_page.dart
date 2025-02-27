// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/venta.dart';

class DetailsClientPage extends StatefulWidget {
  final int idCliente;

  const DetailsClientPage({super.key, required this.idCliente});

  @override
  State<DetailsClientPage> createState() => _DetailsClientPageState();
}

class _DetailsClientPageState extends State<DetailsClientPage> {
  Cliente? cliente;
  List<Venta> ventasCliente = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    Cliente? cliente = await Cliente.obtenerClientePorId(widget.idCliente);

    setState(() {
      this.cliente = cliente;
    });

    List<Venta> ventasCliente =
        await Venta.obtenerVentasDeCliente(cliente!.idCliente!);
    setState(() {
      this.ventasCliente = ventasCliente;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cliente?.nombreCliente ?? "---",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        "DNI",
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
                          (cliente?.dniCliente?.isNotEmpty ?? false)
                              ? cliente!.dniCliente as String
                              : '-------',
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
                          'ID Cliente: ${cliente?.idCliente ?? '---'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF493D9E),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                            'Correo electrónico: ${(cliente?.dniCliente?.isNotEmpty ?? false) ? cliente!.dniCliente : '---'}'),
                        FutureBuilder<DateTime?>(
                          future: cliente?.obtenerFechaUltimaVenta(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Cargando...");
                            }

                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }

                            final fechaUltimaVenta = snapshot.data
                                    ?.toIso8601String()
                                    .split('T')[0] ??
                                '---';
                            return Text(
                              "Última compra: $fechaUltimaVenta",
                              style: const TextStyle(color: Colors.black),
                            );
                          },
                        ),
                        FutureBuilder<double?>(
                          future: cliente?.obtenerTotalDeVentas(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Cargando...");
                            }

                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }

                            final totalVentas =
                                snapshot.data?.toStringAsFixed(2) ?? '---';
                            return Text(
                              "Monto total: S/ $totalVentas",
                              style: const TextStyle(color: Colors.black),
                            );
                          },
                        ),
                        Text(
                          "Estado: ${cliente?.esDeudor == true ? "Deudor" : "Regular"}",
                          style: TextStyle(
                            color: cliente?.esDeudor == true
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Ventas del cliente:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ventasCliente.isEmpty
                  ? const Center(
                      child: Text(
                        "No se encontraron ventas",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: ventasCliente.length,
                      itemBuilder: (context, index) {
                        final venta = ventasCliente[index];

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Color(0xFF493D9E), width: 2),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venta.codigoBoleta ?? "---",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF493D9E),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Fecha: ${venta.fechaVenta?.toIso8601String().split('T')[0] ?? '---'}",
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        "Monto: S/ ${venta.montoTotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                      Text(
                                        "Tipo de pago: ${venta.esAlContado! ? "Al contado" : "Crédito"}",
                                        style: TextStyle(
                                          color: venta.esAlContado!
                                              ? Colors.black
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2BBF55),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.push(
                                          '/sales/details-sale/${venta.idVenta}');
                                    },
                                    child: const Text("Detalles",
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
