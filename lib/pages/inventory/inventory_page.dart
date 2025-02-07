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

  // Método para obtener los productos con paginación
  Future<List<Producto>> _obtenerProductos() async {
    try {
      List<Producto> productos =
          await Producto.obtenerProductosPorPagina(indexPaginaActual);
      return productos;
    } catch (e) {
      return [];
    }
  }

  // Método para refrescar la lista de productos manualmente
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
              context.push('/home/inventory/filter-product');
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
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return GestureDetector(
                    onTap: () {
                      // Navegar a la página del producto con su ID en la URL
                      context.push(
                          '/home/inventory/product/${producto.idProducto}');
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
                            producto.rutaImagen ??
                                'lib/assets/iconos/iconoImagen.png',
                            height: 60,
                            alignment: Alignment.center,
                          ),
                          Text(
                            producto.nombreProducto,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Precio: S/. ${producto.precioProducto.toStringAsFixed(2)}",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Stock actual: \n ${producto.stockActual} ud",
                            style: TextStyle(
                              color: producto.stockActual <
                                      (producto.stockMinimo ?? 0)
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
