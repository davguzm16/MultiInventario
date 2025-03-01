// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';

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
    bool esDeudor = await Cliente.verificarEstadoDeudor(cliente!.idCliente!);
    List<Venta> ventasCliente =
        await Venta.obtenerVentasDeCliente(cliente.idCliente!);

    setState(() {
      this.cliente = cliente;
      this.cliente!.esDeudor = esDeudor;
      this.ventasCliente = ventasCliente;
    });
  }

  void actualizarMontoCanceladoDialog() async {
    TextEditingController montoACancelarController = TextEditingController();

    List<Venta> ventasPendientes =
        await Venta.obtenerVentasDeCliente(cliente!.idCliente!);

    if (ventasPendientes.isEmpty) {
      ErrorDialog(context: context, errorMessage: 'No hay ventas pendientes.');
      return;
    }

    double sumaMontosTotales =
        ventasPendientes.fold(0.0, (sum, v) => sum + v.montoTotal);
    double sumaMontosCancelados =
        ventasPendientes.fold(0.0, (sum, v) => sum + (v.montoCancelado ?? 0.0));
    double montoPendiente = sumaMontosTotales - sumaMontosCancelados;
    double montoFaltante = montoPendiente;

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
                  color: Color(0xFF493D9E),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Suma de montos totales:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('S/ ${sumaMontosTotales.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Suma de montos cancelados:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('S/ ${sumaMontosCancelados.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto pendiente:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF493D9E)),
                      ),
                      Text('S/ ${montoPendiente.toStringAsFixed(2)}'),
                    ],
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto faltante:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFE63946)),
                      ),
                      Text(
                        'S/ ${montoFaltante.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFFE63946)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BBF55),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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
                            context: context, errorMessage: 'Monto inválido');
                        return;
                      }

                      bool actualizado =
                          await Venta.actualizarMontoCanceladoVentas(
                              cliente!.idCliente!, montoACancelar);

                      if (actualizado) {
                        SuccessDialog(
                          context: context,
                          successMessage: 'Monto actualizado correctamente!',
                          btnOkOnPress: () async {
                            _cargarDatosCliente();
                            context.pop();
                          },
                        );
                      } else {
                        ErrorDialog(
                            context: context,
                            errorMessage: 'Error al actualizar el monto');
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.attach_money,
              color: cliente!.esDeudor ? Colors.black : Colors.grey,
            ),
            onPressed: cliente!.esDeudor
                ? () => actualizarMontoCanceladoDialog()
                : null,
          ),
        ],
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

                        return FutureBuilder<Cliente?>(
                          future: Cliente.obtenerClientePorId(venta.idCliente),
                          builder: (context, snapshot) {
                            final Cliente? cliente = snapshot.data;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF493D9E), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Venta ${venta.idVenta}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFF493D9E),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Cliente: ${cliente?.nombreCliente ?? "-----"}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "Fecha: ${venta.fechaVenta!.toIso8601String().split('T')[0]}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "Monto: S/ ${venta.montoTotal.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "Tipo de pago: ${venta.esAlContado! ? "Al contado" : (venta.montoCancelado == venta.montoTotal ? "Crédito (Cancelado)" : "Crédito")}",
                                            style: TextStyle(
                                              color: venta.esAlContado!
                                                  ? Colors.black
                                                  : venta.montoCancelado ==
                                                          venta.montoTotal
                                                      ? const Color(0xFF2BBF55)
                                                      : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2BBF55),
                                            foregroundColor: Colors.white,
                                            elevation: 6,
                                            shadowColor:
                                                Colors.black.withOpacity(0.3),
                                          ),
                                          onPressed: () async {
                                            await context.push(
                                                '/sales/details-sale/${venta.idVenta}');

                                            _cargarDatosCliente();
                                          },
                                          child: const Text("Detalles"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
