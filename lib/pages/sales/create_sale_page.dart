// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/lote.dart';

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

    Producto? productoSeleccionado;
    //Lote? loteSeleccionado; // Variable para el lote seleccionado
    String? loteSeleccionado; // Cambiado a String? si estás trabajando con opciones como "A" y "B"

    if (editarProducto) {
      productoSeleccionado = productosVenta[index!];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(editarProducto ? "Editar producto" : "Agregar producto"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  if (!editarProducto)
                    SizedBox(
                      height: 150,
                      child: productosFiltrados.isEmpty
                          ? const Center(child: Text("No hay productos encontrados"))
                          : ListView.builder(
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];
                          return ListTile(
                            title: Text(producto.nombreProducto),
                            subtitle: Text(
                                "S/ ${producto.precioProducto.toStringAsFixed(2)}"),
                            onTap: () {
                              _searchController.text = producto.nombreProducto;
                              setDialogState(() {});
                              productoSeleccionado = producto;
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (productoSeleccionado != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Precio: S/ ${productoSeleccionado?.precioProducto.toStringAsFixed(2) ?? '---'}"),
                        const SizedBox(height: 10),

                        // Mostrar lotes disponibles para el producto
                        FutureBuilder<List<String>>(
                          future: Future.delayed(Duration(seconds: 1), () => ["A", "B"]), // Simula la carga de opciones "A" y "B"
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }

                            final opciones = snapshot.data ?? [];
                            if (opciones.isEmpty) {
                              return const Text("No hay opciones disponibles");
                            }

                            return Column(
                              children: opciones.map((opcion) {
                                return RadioListTile<String>(
                                  title: Text("Opción: $opcion"),
                                  value: opcion,
                                  groupValue: loteSeleccionado, // Aquí usamos String? en vez de Lote?
                                  onChanged: (String? value) {
                                    setDialogState(() {
                                      loteSeleccionado = value; // Aquí actualizamos con el valor de String?
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        )

                        /*FutureBuilder<List<Lote>>(
                          future: Lote.obtenerLotesDeProducto(productoSeleccionado!.idProducto!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }

                            final lotes = snapshot.data ?? [];
                            if (lotes.isEmpty) {
                              return const Text("No hay lotes disponibles");
                            }

                            return Column(
                              children: lotes.map((lote) {
                                return RadioListTile<Lote>(
                                  title: Text("Lote: ${lote.idLote}"),
                                  subtitle: Text(
                                    "Cantidad: ${lote.cantidadActual} | Precio: S/ ${lote.precioCompra.toStringAsFixed(2)}",
                                  ),
                                  value: lote,
                                  groupValue: loteSeleccionado,
                                  onChanged: (Lote? value) {
                                    setDialogState(() {
                                      loteSeleccionado = value;
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),*/
                      ],
                    ),
                  const SizedBox(height: 10),
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
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Descuento (S/)"),
                    keyboardType: TextInputType.number,
                    controller: descuentoController,
                    onChanged: (value) {
                      setDialogState(() {
                        descuento = double.tryParse(value) ?? 0.00;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
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
                  if (productoSeleccionado == null || loteSeleccionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Producto o lote no válidos")),
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
                      if (productoSeleccionado != null) {
                        productosVenta.add(productoSeleccionado!); // The '!' operator tells Dart that productoSeleccionado is not null here
                      } else {
                        // Handle the case when productoSeleccionado is null, e.g., show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Producto no seleccionado")),
                        );
                      }
                      detallesVenta.add(nuevoDetalle);
                    });
                  }

                  // Aquí es donde puedes almacenar el lote seleccionado en una variable auxiliar
                  // sin modificar la clase DetalleVenta, por ejemplo:
                  // loteSeleccionado puede usarse para otro propósito en la lógica del sistema,
                  // o simplemente ser usado visualmente para mostrarlo.

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
