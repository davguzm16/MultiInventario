// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/unidad.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _searchTimer;

  // Listado de productos
  List<Producto> productos = [];

  // Variables de filtrado
  List<Categoria> categoriasSeleccionadas = [];
  bool? stockBajo;
  String nombreProductoBuscado = "";

  // Manejo de resultados por carga
  int cantidadCargas = 0;
  bool hayMasCargas = true;
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
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
        nombreProductoBuscado.isEmpty) {
      _cargarProductos();
    }
  }

  Future<void> _cargarProductos({bool reiniciarListaProductos = false}) async {
    if (!hayMasCargas && !reiniciarListaProductos) return;

    if (reiniciarListaProductos) {
      setState(() {
        productos.clear();
        cantidadCargas = 0;
        hayMasCargas = true;
      });
    }

    // Evita que se llame nuevamente si ya está cargando
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    debugPrint("Productos antes de cargar: ${productos.length}");

    List<Producto> nuevosProductos =
        await ProductoCategoria.obtenerProductosPorCargaFiltrados(
      numeroCarga: cantidadCargas,
      categorias: categoriasSeleccionadas,
      stockBajo: stockBajo,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (reiniciarListaProductos) {
        productos = nuevosProductos;
      } else {
        productos.addAll(nuevosProductos);
      }
      cantidadCargas++;

      if (nuevosProductos.length < 8) {
        hayMasCargas = false;
      }

      // Finalizamos la carga
      isLoading = false;
    });

    debugPrint("Productos después de cargar: ${productos.length}");
  }

  void _buscarProductosPorNombre(String nombre) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      if (nombre.isEmpty) {
        _cargarProductos(reiniciarListaProductos: true);
        return;
      }

      List<Producto> productosFiltrados =
          await Producto.obtenerProductosPorNombre(nombre);

      setState(() {
        productos = productosFiltrados;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    _animationController.dispose();
    super.dispose();
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
                          nombreProductoBuscado = "";
                        });
                        _animationController.reverse();
                        _cargarProductos(reiniciarListaProductos: true);
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
                      nombreProductoBuscado = value;
                    });
                    _buscarProductosPorNombre(value);
                  },
                )
              : const Text(
                  "Mis productos",
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
                await context.push('/inventory/create-product');
                setState(() {
                  productos.clear();
                  cantidadCargas = 0;
                  hayMasCargas = true;
                });
                _cargarProductos(reiniciarListaProductos: true);
              },
            ),
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () async {
                final filtros = await context.push<Map<String, dynamic>>(
                  '/inventory/filter-products',
                  extra: {
                    'categoriasSeleccionadas': categoriasSeleccionadas
                        .map((c) => {
                              'idCategoria': c.idCategoria,
                              'nombreCategoria': c.nombreCategoria
                            })
                        .toList(),
                    'stockBajo': stockBajo,
                  },
                );

                if (filtros != null) {
                  setState(() {
                    categoriasSeleccionadas =
                        filtros['categoriasSeleccionadas'] as List<Categoria>;
                    stockBajo = filtros['isStockBajo'] as bool?;
                  });
                }

                _cargarProductos(reiniciarListaProductos: true);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: productos.isEmpty
                    ? const Center(
                        child: Text(
                          "No se encontraron productos",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];

                          return GestureDetector(
                            onTap: () {
                              context.push(
                                  '/inventory/product/${producto.idProducto}');
                              _cargarProductos(reiniciarListaProductos: true);
                              isSearching = false;
                            },
                            child: Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.purple),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: producto.rutaImagen == null
                                          ? Image.asset(
                                              'lib/assets/iconos/iconoImagen.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(producto.rutaImagen!),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Flexible(
                                    child: Text(
                                      producto.nombreProducto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                    "Precio: S/. ${producto.precioProducto.toStringAsFixed(2)}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  FutureBuilder<Unidad?>(
                                    future: Unidad.obtenerUnidadPorId(
                                        producto.idUnidad!),
                                    builder: (context, snapshot) {
                                      return Text(
                                        "Stock: ${producto.stockActual} ${snapshot.data?.tipoUnidad ?? "---"}",
                                        style: TextStyle(
                                          color: producto.stockActual! <
                                                  producto.stockMinimo
                                              ? Colors.red
                                              : Colors.black,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
