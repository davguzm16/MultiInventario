import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/producto.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final int indexPaginaActual = 1;
  late Future<List<Producto>> listaProductos;

  @override
  void initState() {
    super.initState();
    listaProductos = _obtenerProductos();
  }

  Future<List<Producto>> _obtenerProductos() async {
    try {
      List<Producto> productos =
          await Producto.obtenerProductosPorPagina(indexPaginaActual);
      return productos;
    } catch (e) {
      return [];
    }
  }

  Future<void> _refrescarProductos() async {
    setState(() {
      listaProductos = _obtenerProductos();
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
            onPressed: () async {
              await context.push('/inventory/create-product');
              _refrescarProductos();
            },
          ),
          IconButton(
            icon: Image.asset(
              "lib/assets/iconos/iconoFiltro.png",
              width: 30,
              height: 30,
            ),
            onPressed: () {
              context.push('/inventory/filter-product');
            },
          ),
          IconButton(
            icon: Image.asset(
              "lib/assets/iconos/iconoBusqueda.png",
              width: 23,
              height: 23,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: _refrescarProductos,
          child: FutureBuilder<List<Producto>>(
            future: listaProductos,
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
                      context.push('/inventory/product/${producto.idProducto}');
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      padding: EdgeInsets.all(8),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            "Precio: S/. ${producto.precioProducto.toStringAsFixed(2)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Stock: ${producto.stockActual} ud",
                            style: TextStyle(
                              color: producto.stockActual <
                                      (producto.stockMinimo ?? 0)
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
              );
            },
          ),
        ),
      ),
    );
  }
}
