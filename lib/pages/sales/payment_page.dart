// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';

class PaymentPage extends StatefulWidget {
  final List<DetalleVenta> detallesVenta;
  const PaymentPage({super.key, required this.detallesVenta});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool esAlContado = true;
  bool crearCliente = true;

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> clientesFiltrados = [];
  String nombreClienteBuscado = "";
  Cliente? clienteSeleccionado;

  double cantidadRecibida = 0.0;
  Venta? venta;

  void _buscarClientesPorNombre(String nombre) async {
    if (nombre.isEmpty) {
      setState(() {
        clientesFiltrados = [];
      });
      return;
    }

    List<Cliente> clientes = await Cliente.obtenerClientesPorNombre(nombre);

    setState(() {
      clientesFiltrados = clientes;
    });
  }

  double _calcularTotalVenta() {
    return widget.detallesVenta
        .fold(0.0, (total, detalle) => total + detalle.subtotalProducto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pago",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 40, top: 12, right: 40, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cliente:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF493D9E)),
              ),
              const SizedBox(height: 8),

              /// Botón para alternar entre "Crear Cliente" y "Buscar Cliente"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      child:
                          _buildClienteButton("Crear Cliente", crearCliente)),
                  const SizedBox(width: 10),
                  Flexible(
                      child:
                          _buildClienteButton("Buscar Cliente", !crearCliente)),
                ],
              ),
              const SizedBox(height: 8),

              /// Alternar entre Crear Cliente o Buscar Cliente
              if (crearCliente) ...[
                CustomTextField(
                  label: "Nombre",
                  controller: _nombreController,
                  keyboardType: TextInputType.text,
                  isRequired: true,
                ),
                CustomTextField(
                  label: "DNI",
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: "Correo Electrónico",
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ] else ...[
                SizedBox(
                  height: 150,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Buscar cliente...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                nombreClienteBuscado = "";
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                const BorderSide(color: Color(0xFF493D9e)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            nombreClienteBuscado = value;
                          });
                          _buscarClientesPorNombre(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: clientesFiltrados.isEmpty
                            ? const Center(
                                child: Text("No hay clientes encontrados"))
                            : ListView.builder(
                                itemCount: clientesFiltrados.length,
                                itemBuilder: (context, index) {
                                  final cliente = clientesFiltrados[index];
                                  return ListTile(
                                    title: Text(cliente.nombreCliente),
                                    subtitle: Text(
                                        "DNI: ${cliente.dniCliente ?? "---"}"),
                                    onTap: () {
                                      setState(() {
                                        _searchController.text =
                                            cliente.nombreCliente;
                                        clienteSeleccionado = cliente;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text("Cliente: ${clienteSeleccionado?.nombreCliente ?? "---"}"),
                const SizedBox(height: 15),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(child: _buildPagoButton("Al contado", esAlContado)),
                  const SizedBox(width: 10),
                  Flexible(child: _buildPagoButton("Crédito", !esAlContado)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Monto total: ${_calcularTotalVenta().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF493D9E)),
              ),
              _buildTipoPago(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClienteButton(String text, bool isSelected) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF493D9E) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Color(0xFF493D9E),
        side: const BorderSide(color: Color(0xFF493D9E)),
      ),
      onPressed: () {
        setState(() {
          crearCliente = (text == "Crear Cliente");
          _searchController.clear();
          clientesFiltrados.clear();
        });
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPagoButton(String text, bool isSelected) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF493D9E) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Color(0xFF493D9E),
        side: const BorderSide(color: Color(0xFF493D9E)),
      ),
      onPressed: () {
        setState(() {
          esAlContado = (text == "Al contado");
        });
      },
      child: Text(text),
    );
  }

  Widget _buildTipoPago() {
    // Calcular la diferencia entre el monto total y la cantidad recibida
    double diferencia = _calcularTotalVenta() - cantidadRecibida;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Cantidad recibida",
          controller: _cantidadController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isPrice: true,
          onChanged: (value) {
            setState(() {
              cantidadRecibida =
                  (value.isEmpty ? null : double.tryParse(value)) ?? 0.0;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          esAlContado
              ? (cantidadRecibida == 0.0)
                  ? 'Vuelto: ---'
                  : (cantidadRecibida - _calcularTotalVenta()) < 0
                      ? 'Vuelto: Monto Insuficiente'
                      : 'Vuelto: S/${(cantidadRecibida - _calcularTotalVenta()).toStringAsFixed(2)}'
              : (cantidadRecibida >= 0.0)
                  ? 'Por cancelar: S/${_calcularTotalVenta().toStringAsFixed(2)}'
                  : 'Por cancelar: S/${diferencia.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF493D9E)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () async {
              FocusScope.of(context).unfocus();

              if (crearCliente) {
                if (_nombreController.text.isEmpty) {
                  ErrorDialog(
                    context: context,
                    errorMessage:
                        "Por favor, complete todos los campos obligatorios.",
                  );
                  return;
                }

                if (esAlContado &&
                    (cantidadRecibida - _calcularTotalVenta()) < 0) {
                  ErrorDialog(
                    context: context,
                    errorMessage:
                        "Monto insuficiente. \nSi desea continuar con este monto, considere cambiarlo a una venta a crédito.",
                  );
                  return;
                }

                clienteSeleccionado = Cliente(
                  nombreCliente: _nombreController.text,
                  dniCliente: _dniController.text,
                  correoCliente: _correoController.text.isNotEmpty
                      ? _correoController.text
                      : null,
                  esDeudor: !esAlContado,
                );

                int? idCliente =
                    await Cliente.crearCliente(clienteSeleccionado!);

                if (idCliente == null) {
                  ErrorDialog(
                    context: context,
                    errorMessage: "Hubo un error al crear el cliente.",
                  );
                  return;
                }

                clienteSeleccionado!.idCliente = idCliente;
              }

              // Asegurar que idCliente no es nulo
              if (clienteSeleccionado?.idCliente == null) {
                ErrorDialog(
                  context: context,
                  errorMessage: "No se pudo obtener el ID del cliente.",
                );
                return;
              }

              venta = Venta(
                idCliente: clienteSeleccionado!.idCliente!,
                montoTotal: _calcularTotalVenta(),
                montoCancelado: cantidadRecibida,
                esAlContado: esAlContado,
              );

              bool ventaCreada =
                  await Venta.crearVenta(venta!, widget.detallesVenta);

              if (!ventaCreada) {
                ErrorDialog(
                  context: context,
                  errorMessage: "Hubo un error al crear la venta.",
                );
                return;
              }

              ConfirmDialog(
                context: context,
                title: "Confirmación",
                message: "¿Estás seguro de realizar la venta?",
                btnOkOnPress: () {
                  SuccessDialog(
                    context: context,
                    successMessage: "¡La venta se ha realizado exitosamente!",
                    btnOkOnPress: () {
                      context.go('/sales');
                    },
                  );
                },
              );
            },
            child: const Text(
              "Confirmar",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
