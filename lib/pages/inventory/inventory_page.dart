// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/models/producto.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _paginaActual = 1;
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _obtenerProductos();
  }

  // Método para obtener los productos con paginación
  Future<List<Producto>> _obtenerProductos() async {
    try {
      List<Producto> productos =
          await Producto.obtenerProductosPorPagina(_paginaActual);
      print('Productos obtenidos: $productos');
      return productos;
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  // Método para refrescar la lista de productos manualmente
  Future<void> _refrescarProductos() async {
    setState(() {
      _productosFuture = _obtenerProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis productos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.inventoryCreateProduct);
                _refrescarProductos();
              }),
          IconButton(
              icon: Image.asset(
                "lib/assets/iconos/iconoFiltro.png",
                width: 30,
                height: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.inventoryFilterProduct);
              }),
          IconButton(
              icon: Image.asset(
                "lib/assets/iconos/iconoBusqueda.png",
                width: 23,
                height: 23,
              ),
              onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: _refrescarProductos,
          child: FutureBuilder<List<Producto>>(
            future: _productosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar productos'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay productos disponibles'));
              }

              List<Producto> productos = snapshot.data!;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final product = productos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.inventoryProduct);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            product.rutaImagen ??
                                'lib/assets/iconos/iconoImagen.png',
                            height: 60,
                            alignment: Alignment.center,
                          ),
                          Text(
                            product.nombreProducto,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Precio: S/. ${product.precioProducto.toStringAsFixed(2)}",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Stock actual: \n ${product.stockActual} ud",
                            style: TextStyle(
                              color: product.stockActual <
                                      (product.stockMinimo ?? 0)
                                  ? Colors.red
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}
