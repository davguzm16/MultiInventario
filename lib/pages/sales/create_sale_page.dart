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
    Lote? loteSeleccionado; // Cambiado a String? si estás trabajando con opciones como "A" y "B"

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
                        Text("Precio: S/ ${productoSeleccionado?.precioProducto.toStringAsFixed(2) ?? '---'}"),
                        const SizedBox(height: 10),

// Mostrar lotes disponibles para el producto
                        FutureBuilder<List<Lote>>(
                          future: productoSeleccionado != null
                              ? Lote.obtenerLotesDeProducto(productoSeleccionado!.idProducto!)
                              : Future.value([]),
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

                            // Asignar lote seleccionado solo si es null y hay lotes disponibles
                            if (loteSeleccionado == null && lotes.isNotEmpty) {
                              loteSeleccionado = lotes.first;
                            }

                            return DropdownButton<Lote>(
                              value: lotes.contains(loteSeleccionado) ? loteSeleccionado : null,
                              hint: Text("Seleccione un lote"), // Agregado para mejorar la UX
                              onChanged: (Lote? newValue) {
                                setDialogState(() {
                                  loteSeleccionado = newValue; // Actualiza el lote seleccionado
                                });
                              },
                              items: lotes.map<DropdownMenuItem<Lote>>((Lote lote) {
                                return DropdownMenuItem<Lote>(
                                  value: lote,
                                  child: Text("Lote: ${lote.idLote} - ${lote.cantidadActual} ud - S/ ${lote.precioCompra.toStringAsFixed(2)}"),
                                );
                              }).toList(),
                            );

                          },
                        )


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
                      idLote: loteSeleccionado?.idLote ?? 0,
                      precioUnidadProducto: productoSeleccionado!.precioProducto!,
                      gananciaProducto: 2,
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
                                  _showAddProductDialog(editarProducto: true, index: index);
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Editar',
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color.fromARGB(255, 124, 33, 243), width: 2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen del producto
                                SizedBox(
                                  width: 50,
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
                                const SizedBox(width: 10),
                                // Información del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productosVenta[index].nombreProducto,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Precio: S/ ${productosVenta[index].precioProducto}\n"
                                        "Cantidad: ${detallesVenta[index].cantidadProducto}\n"
                                        "Lote: ${detallesVenta[index].idLote}\n"
                                        "Descuento: S/ ${detallesVenta[index].descuentoProducto}",
                                      ),
                                    ],
                                  ),
                                ),
                                // Subtotal
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Subtotal",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/ ${detallesVenta[index].subtotalProducto.toStringAsFixed(2)}",
                                    ),
                                  ],
                                ),
                              ],
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 124, 33, 243), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showAddProductDialog, // Funcionalidad de agregar producto
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Botón transparente para el diseño
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Text(
                      "+",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Total: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 124, 33, 243),
                      ),
                    ),
                    Container(


                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 124, 33, 243),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        "${_calcularTotalVenta().toStringAsFixed(2)}", // Calculando el total
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {}, // Aquí iría la funcionalidad de confirmar
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
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
