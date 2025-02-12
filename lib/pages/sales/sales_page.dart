// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String nombreVentaBuscado = "";
  bool? esAlContado;

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
        nombreVentaBuscado.isEmpty) {
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
                    hintText: "Buscar producto...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          isSearching = false;
                          nombreVentaBuscado = "";
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
                      nombreVentaBuscado = value;
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
              icon: const Icon(Icons.person),
              onPressed: () async {
                await context.push('/sales/debtors');
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/sales/create-sale');
              setState(() {
                ventas.clear();
                cantidadCargas = 0;
                hayMasCargas = true;
              });
              Future.delayed(const Duration(milliseconds: 300), _cargarVentas);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sales Page"),
          ],
        ),
      ),
    );
  }
}
