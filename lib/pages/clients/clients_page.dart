// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _searchTimer;

  // Clientes
  List<Cliente> clientes = [];
  String nombreClienteBuscado = "";
  bool? esDeudor;

  // Variables de carga dinámica
  int cantidadCargas = 0;
  bool hayMasCargas = true;
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    _scrollController.addListener(_detectarScrollFinal);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).refresh();
    });
  }

  void _detectarScrollFinal() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hayMasCargas &&
        nombreClienteBuscado.isEmpty) {
      _cargarClientes();
    }
  }

  Future<void> _cargarClientes({bool reiniciarListaCliente = false}) async {
    if (!hayMasCargas && !reiniciarListaCliente) return;

    if (reiniciarListaCliente) {
      setState(() {
        clientes.clear();
        cantidadCargas = 0;
        hayMasCargas = true;
      });
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    List<Cliente> nuevosClientes = await Cliente.obtenerClientesPorCarga(
      numeroCarga: cantidadCargas,
      esDeudor: esDeudor,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (reiniciarListaCliente) {
        clientes = nuevosClientes;
      } else {
        clientes.addAll(nuevosClientes);
      }
      cantidadCargas++;

      if (nuevosClientes.length < 8) {
        hayMasCargas = false;
      }

      isLoading = false;
    });
  }

  void _buscarClientes(String nombreCliente) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      if (nombreCliente.isEmpty) {
        _cargarClientes(reiniciarListaCliente: true);
        return;
      }

      List<Cliente> clientesFiltrados =
          await Cliente.obtenerClientesPorNombre(nombreCliente);

      setState(() {
        clientes = clientesFiltrados;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isSearching ? MediaQuery.of(context).size.width - 32 : 150,
          child: isSearching
              ? TextField(
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
                          isSearching = false;
                          nombreClienteBuscado = "";
                        });
                        _animationController.reverse();
                        _cargarClientes(reiniciarListaCliente: true);
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                  ),
                  onChanged: (value) {
                    setState(() => nombreClienteBuscado = value);
                    _buscarClientes(value);
                  },
                )
              : const Text(
                  "Mis clientes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSearching ? 0 : 48,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => isSearching = true);
                _animationController.forward();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: clientes.isEmpty
                ? const Center(
                    child: Text(
                      "No hay clientes",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFF493D9E), width: 2),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cliente.nombreCliente,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF493D9E),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    FutureBuilder<DateTime?>(
                                      future: cliente.obtenerFechaUltimaVenta(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text("Cargando...");
                                        }

                                        if (snapshot.hasError) {
                                          return Text(
                                              "Error: ${snapshot.error}");
                                        }

                                        final fechaUltimaVenta = snapshot.data
                                                ?.toIso8601String()
                                                .split('T')[0] ??
                                            '---';
                                        return Text(
                                          "Última compra: $fechaUltimaVenta",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        );
                                      },
                                    ),
                                    FutureBuilder<double?>(
                                      future: cliente.obtenerTotalDeVentas(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text("Cargando...");
                                        }

                                        if (snapshot.hasError) {
                                          return Text(
                                              "Error: ${snapshot.error}");
                                        }

                                        final totalVentas =
                                            snapshot.data?.toStringAsFixed(2) ??
                                                '---';
                                        return Text(
                                          "Monto total: S/ $totalVentas",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        );
                                      },
                                    ),
                                    Text(
                                      "Estado: ${cliente.esDeudor}",
                                      style: TextStyle(
                                        color: cliente.esDeudor
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2BBF55),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      context.push(
                                          '/clients/details-client/${cliente.idCliente}');
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
                  ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
