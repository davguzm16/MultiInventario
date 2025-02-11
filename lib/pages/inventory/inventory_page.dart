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
  final ScrollController _scrollController = ScrollController();
  final List<Producto> _productos = [];
  int _cantidadCargas = 0;
  bool _cargando = false;
  bool _hayMasProductos = true;
  bool _inicializado = false; // Nuevo flag para manejar la carga inicial

  @override
  void initState() {
    super.initState();
    _cargarProductos(inicial: true);
    _scrollController.addListener(_detectarScrollFinal);
  }

  void _detectarScrollFinal() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_cargando &&
        _hayMasProductos) {
      _cargarProductos();
    }
  }

  Future<void> _cargarProductos({bool inicial = false}) async {
    if (_cargando || (!_hayMasProductos && !inicial)) return;

    setState(() => _cargando = true);

    debugPrint("Productos antes de cargar: ${_productos.length}");

    try {
      List<Producto> nuevosProductos =
          await Producto.obtenerProductosPorCarga(_cantidadCargas);

      // Simulamos un tiempo de carga para visualizar el indicador
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _productos.addAll(nuevosProductos);
        _cantidadCargas++;
        _hayMasProductos = nuevosProductos.length == 8;

        if (inicial) {
          _inicializado = true; // Marcamos que la carga inicial está completa
        }
      });

      debugPrint("Productos después de cargar: ${_productos.length}");
    } catch (e) {
      debugPrint("Error al cargar productos: $e");
    }

    setState(() => _cargando = false);
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
            icon: Icon(Icons.add),
            onPressed: () async {
              await context.push('/inventory/create-product');
              setState(() {
                _productos.clear();
                _cantidadCargas = 0;
                _hayMasProductos = true;
                _inicializado = false;
              });
              Future.delayed(Duration(milliseconds: 100),
                  () => _cargarProductos(inicial: true));
            },
          ),
        ],
      ),
      body: _inicializado
          ? Column(
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
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];

                      return GestureDetector(
                        onTap: () {
                          context.push(
                              '/inventory/product/${producto.idProducto}');
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
                  ),
                ),

                // Indicador de carga debajo del GridView cuando se cargan más productos
                if (_cargando)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(), // Pantalla de carga inicial
            ),
    );
  }
}
