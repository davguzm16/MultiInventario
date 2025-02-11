import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();
  List<Producto> productos = [];
  List<Categoria> categoriasSeleccionadas = [];
  bool isStockBajo = false;
  int cantidadCargas = 0;
  bool hayMasCargas = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _scrollController.addListener(_detectarScrollFinal);
  }

  void _detectarScrollFinal() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hayMasCargas) {
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

    debugPrint("Productos antes de cargar: ${productos.length}");

    List<Producto> nuevosProductos =
        await ProductoCategoria.obtenerProductosPorCargaFiltrados(
      numeroCarga: cantidadCargas,
      categorias: categoriasSeleccionadas,
      stockBajo: isStockBajo,
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        if (reiniciarListaProductos) {
          productos = nuevosProductos;
        } else {
          productos.addAll(nuevosProductos);
        }
        cantidadCargas++;
      });

      if (nuevosProductos.length < 8) {
        hayMasCargas = false;
      }
    }
    debugPrint("Productos después de cargar: ${productos.length}");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis productos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/inventory/create-product');
              setState(() {
                productos.clear();
                cantidadCargas = 0;
                hayMasCargas = true;
              });
              Future.delayed(
                  const Duration(milliseconds: 100), _cargarProductos);
            },
          ),
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () async {
                final filtros = await context.push<Map<String, dynamic>>(
                  '/inventory/filter-products',
                  extra: {
                    'categoriasSeleccionadas': categoriasSeleccionadas,
                    'isStockBajo': isStockBajo,
                  },
                );

                if (filtros != null) {
                  setState(() {
                    categoriasSeleccionadas =
                        filtros['categoriasSeleccionadas'] as List<Categoria>;
                    isStockBajo = filtros['isStockBajo'] as bool;
                  });
                }

                _cargarProductos(reiniciarListaProductos: true);
              })
        ],
      ),
      body: productos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
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
                              Text(
                                "Stock: ${producto.stockActual} ud",
                                style: TextStyle(
                                  color: producto.stockActual <
                                          producto.stockMinimo
                                      ? Colors.red
                                      : Colors.black,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicador de carga debajo del GridView cuando se cargan más productos
                if (hayMasCargas)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
    );
  }
}
