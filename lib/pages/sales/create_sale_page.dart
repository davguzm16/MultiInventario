// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de la venta
  Venta? venta;
  List<DetalleVenta> detallesVenta = [];
  List<Producto> productosVenta = [];

  // Datos de los productos para agregar
  List<Producto> productosFiltrados = [];
  String nombreProductoBuscado = "";

  void _buscarProductosPorNombre(String nombre) async {
    if (nombre.isEmpty) {
      setState(() {
        productosFiltrados = [];
      });
      return;
    }

    List<Producto> productos = await Producto.obtenerProductosPorNombre(nombre);

    setState(() {
      productosFiltrados = productos;
      debugPrint("Productos encontrados: ${productosFiltrados.length}");
    });
  }

  Producto? _obtenerProductoSeleccionado() {
    try {
      return productosFiltrados.firstWhere(
        (p) => p.nombreProducto == _searchController.text,
      );
    } catch (e) {
      return null;
    }
  }

  double _calcularTotal(int cantidad, double? descuento) {
    Producto? productoSeleccionado = _obtenerProductoSeleccionado();
    if (productoSeleccionado == null) return 0.0;
    return (productoSeleccionado.precioProducto * cantidad -
        (descuento ?? 0.0));
  }

  double _calcularTotalVenta() {
    return detallesVenta.fold(
        0.0, (total, detalle) => total + detalle.subtotalProducto);
  }

  void _showAddProductDialog({bool editarProducto = false, int? index}) {
    int cantidad = editarProducto ? detallesVenta[index!].cantidadProducto : 1;
    double? descuento =
        editarProducto ? detallesVenta[index!].descuentoProducto : 0.0;
    TextEditingController descuentoController =
        TextEditingController(text: descuento.toString());

    if (editarProducto) {
      _searchController.text = productosVenta[index!].nombreProducto;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title:
                Text(editarProducto ? "Editar producto" : "Agregar producto"),
            content: SizedBox(
              width: double
                  .maxFinite, // Hace que el dialogo use todo el ancho disponible
              child: Column(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                children: [
                  // Buscador animado
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Buscar producto...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setDialogState(() {
                            nombreProductoBuscado = "";
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        nombreProductoBuscado = value;
                      });
                      _buscarProductosPorNombre(value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Lista de productos filtrados
                  if (!editarProducto)
                    SizedBox(
                      height:
                          150, // Define una altura fija para evitar conflictos
                      child: productosFiltrados.isEmpty
                          ? const Center(
                              child: Text("No hay productos encontrados"))
                          : ListView.builder(
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) {
                                final producto = productosFiltrados[index];
                                return ListTile(
                                  title: Text(producto.nombreProducto),
                                  subtitle: Text(
                                      "S/ ${producto.precioProducto.toStringAsFixed(2)}"),
                                  onTap: () {
                                    _searchController.text =
                                        producto.nombreProducto;
                                    setDialogState(() {});
                                  },
                                );
                              },
                            ),
                    ),
                  const SizedBox(height: 10),

                  // Información del producto seleccionado
                  Text(
                      "Precio: S/ ${_obtenerProductoSeleccionado()?.precioProducto.toStringAsFixed(2) ?? '---'}"),

                  // Controles de cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (cantidad > 1) {
                            setDialogState(() => cantidad--);
                          }
                        },
                      ),
                      Text(cantidad.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() => cantidad++);
                        },
                      ),
                    ],
                  ),

                  // Descuento
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: "Descuento (S/)"),
                    keyboardType: TextInputType.number,
                    controller: descuentoController,
                    onChanged: (value) {
                      setDialogState(() {
                        descuento = double.tryParse(value) ?? 0.00;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Total
                  Text(
                    "Total: S/ ${_calcularTotal(cantidad, descuento).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Producto? productoSeleccionado =
                      _obtenerProductoSeleccionado();
                  if (productoSeleccionado == null && !editarProducto) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Producto no válido")),
                    );
                    return;
                  }

                  if (editarProducto) {
                    detallesVenta[index!].cantidadProducto = cantidad;
                    detallesVenta[index].descuentoProducto = descuento;
                    detallesVenta[index].subtotalProducto =
                        _calcularTotal(cantidad, descuento);
                  } else {
                    DetalleVenta nuevoDetalle = DetalleVenta(
                      idProducto: productoSeleccionado!.idProducto!,
                      idVenta: venta?.idVenta ?? 0,
                      cantidadProducto: cantidad,
                      subtotalProducto: _calcularTotal(cantidad, descuento),
                      descuentoProducto: descuento,
                    );

                    setState(() {
                      productosVenta.add(productoSeleccionado);
                      detallesVenta.add(nuevoDetalle);
                    });
                  }

                  context.pop();
                },
                child: const Text("Confirmar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Venta")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: productosVenta.isEmpty
                  ? const Center(child: Text("No hay productos agregados"))
                  : ListView.builder(
                      shrinkWrap: true, // Ajusta el tamaño según el contenido
                      physics:
                          const BouncingScrollPhysics(), // Mejora el scroll
                      itemCount: productosVenta.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          key: ValueKey(productosVenta[index].idProducto),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  setState(() {
                                    productosVenta.removeAt(index);
                                    detallesVenta.removeAt(index);
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Eliminar',
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  _showAddProductDialog(
                                      editarProducto: true, index: index);
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Editar',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: SizedBox(
                              width:
                                  50, // Asegura un tamaño fijo para la imagen
                              height: 50,
                              child: productosVenta[index].rutaImagen == null
                                  ? Image.asset(
                                      'lib/assets/iconos/iconoImagen.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(productosVenta[index].rutaImagen!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(
                              productosVenta[index].nombreProducto,
                              overflow:
                                  TextOverflow.ellipsis, // Evita desbordes
                            ),
                            subtitle: Text(
                              "Precio: S/ ${productosVenta[index].precioProducto} \n"
                              "Cantidad: ${detallesVenta[index].cantidadProducto} \n"
                              "Descuento: S/ ${detallesVenta[index].descuentoProducto}",
                            ),
                            trailing: Text(
                              "Subtotal: \nS/ ${detallesVenta[index].subtotalProducto.toStringAsFixed(2)}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Contenedor para centrar los elementos
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Total: S/ ${_calcularTotalVenta().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showAddProductDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Agregar Producto"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Confirmar",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
