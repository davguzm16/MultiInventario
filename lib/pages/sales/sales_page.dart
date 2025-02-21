// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/venta.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _searchTimer;

  // Listado de ventas
  List<Venta> ventas = [];

  // Variables de filtrado
  String codigoVentaBuscado = "";
  bool esAlContado = true;

  // Manejo de carga de datos dinamica
  int cantidadCargas = 0;
  bool hayMasCargas = true;
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
    _scrollController.addListener(_detectarScrollFinal);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  void _detectarScrollFinal() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hayMasCargas &&
        codigoVentaBuscado.isEmpty) {
      _cargarVentas();
    }
  }

  Future<void> _cargarVentas({bool reiniciarListaVentas = false}) async {
    if (!hayMasCargas && !reiniciarListaVentas) return;

    if (reiniciarListaVentas) {
      setState(() {
        ventas.clear();
        cantidadCargas = 0;
        hayMasCargas = true;
      });
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    debugPrint("Ventas antes de cargar: ${ventas.length}");

    List<Venta> nuevasVentas = await Venta.obtenerVentasPorCargaFiltradas(
      numeroCarga: cantidadCargas,
      esAlContado: esAlContado,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (reiniciarListaVentas) {
        ventas = nuevasVentas;
      } else {
        ventas.addAll(nuevasVentas);
      }
      cantidadCargas++;

      if (nuevasVentas.length < 8) {
        hayMasCargas = false;
      }

      // Finalizamos la carga
      isLoading = false;
    });

    debugPrint("Ventas después de cargar: ${nuevasVentas.length}");
  }

  void _buscarVentasPorCodigo(String codigoVenta) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      if (codigoVenta.isEmpty) {
        _cargarVentas(reiniciarListaVentas: true);
        return;
      }

      List<Venta> ventasFiltradas =
          await Venta.obtenerVentasPorCodigo(codigoVenta);

      setState(() {
        ventas = ventasFiltradas;
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
                    hintText: "Buscar venta...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          isSearching = false;
                          codigoVentaBuscado = "";
                        });
                        _animationController.reverse();
                        _cargarVentas(reiniciarListaVentas: true);
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
                    setState(() {
                      codigoVentaBuscado = value;
                    });
                    _buscarVentasPorCodigo(value);
                  },
                )
              : const Text(
                  "Mis ventas",
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
                setState(() {
                  isSearching = true;
                });
                _animationController.forward();
              },
            ),
          ),
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await context.push('/sales/create-sale');
                setState(() {
                  ventas.clear();
                  cantidadCargas = 0;
                  hayMasCargas = true;
                });
                Future.delayed(
                    const Duration(milliseconds: 300), _cargarVentas);
              },
            ),
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () async {
                final filtros = await context.push<Map<String, dynamic>>(
                  '/sales/filter-sales',
                  extra: {
                    'esAlContado': esAlContado,
                  },
                );

                if (filtros != null) {
                  setState(() {
                    esAlContado = (filtros['esAlContado'] as bool?)!;
                  });
                }

                _cargarVentas(reiniciarListaVentas: true);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ventas.isEmpty
                ? const Center(
                    child: Text(
                      "No se encontraron ventas",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventas[index];

                      return FutureBuilder<Cliente?>(
                        future: Cliente.obtenerClientePorId(venta.idCliente),
                        builder: (context, snapshot) {
                          final Cliente? cliente = snapshot.data;

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
                                  // Columna de información de la venta
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          venta.codigoVenta,
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
                                          "Tipo de pago: ${venta.esAlContado! ? "Al contado" : "Crédito"}",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2BBF55),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          context.push(
                                              '/sales/details-sale/${venta.idVenta}');
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
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 6,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
