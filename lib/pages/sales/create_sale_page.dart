// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/widgets/custom_text_field.dart';
import 'package:multiinventario/widgets/error_dialog.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de la venta
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

  Future<void> _showAddProductDialog(
      {bool editarProducto = false, int? index}) async {
    ValueNotifier<int> cantidad = ValueNotifier(
        editarProducto ? detallesVenta[index!].cantidadProducto : 1);
    ValueNotifier<double> descuento = ValueNotifier(
        (editarProducto ? detallesVenta[index!].descuentoProducto : 0.0) ??
            0.0);
    TextEditingController descuentoController = editarProducto
        ? TextEditingController(text: descuento.value.toString())
        : TextEditingController();

    Producto? productoSeleccionado;
    List<Lote> lotesProducto = [];
    Unidad? unidadProducto;
    Lote? loteSeleccionado;

    if (editarProducto) {
      productoSeleccionado = productosVenta[index!];
      loteSeleccionado =
          await Lote.obtenerLotePorId(detallesVenta[index].idLote);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              editarProducto ? "Editar producto" : "Agregar producto",
              style: const TextStyle(
                color: Color(0xFF493d9e),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(color: Color(0xFF493d9e)),
                        ),
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
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();

                                      setDialogState(() {
                                        _searchController.text = producto.nombreProducto;
                                        productoSeleccionado = producto;
                                      });

                                      Unidad? unidad = await Unidad.obtenerUnidadPorId(producto.idUnidad!);
                                      List<Lote> lotesDisponibles = await Lote.obtenerLotesDeProducto(producto.idProducto!);

                                      setDialogState(() {
                                        unidadProducto = unidad;
                                        lotesProducto = lotesDisponibles;
                                        loteSeleccionado = lotesDisponibles.isNotEmpty ? lotesDisponibles.first : null;
                                      });

                                      debugPrint("Tipo de unidad: ${unidad!.tipoUnidad}");
                                    }
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
                            "Precio: S/ ${productoSeleccionado?.precioProducto.toStringAsFixed(2) ?? '---'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<Lote>(
                              isExpanded: true,
                              value: lotesProducto.isNotEmpty ? loteSeleccionado : null,
                              hint: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(lotesProducto.isEmpty ? "No hay lotes disponibles" : "Seleccione un lote"),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onChanged: lotesProducto.isNotEmpty
                                  ? (Lote? newValue) {
                                      setDialogState(() {
                                        loteSeleccionado = newValue;
                                      });
                                    }
                                  : null,
                              items: lotesProducto.map((Lote lote) {
                                return DropdownMenuItem<Lote>(
                                  value: lote,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Lote ${lote.idLote}: ${lote.cantidadActual} ${unidadProducto?.tipoUnidad ?? '---'}",
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (cantidad.value > 1) {
                              cantidad.value--;
                            }
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: cantidad,
                          builder: (context, value, child) {
                            return Text(value.toString());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            cantidad.value++;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Descuento",
                      controller: descuentoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      isPrice: true,
                      unidad: unidadProducto,
                      onChanged: (value) {
                        descuento.value = double.tryParse(value) ?? 0.00;
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: cantidad,
                      builder: (context, cantidadValue, child) {
                        return ValueListenableBuilder(
                          valueListenable: descuento,
                          builder: (context, descuentoValue, child) {
                            double total =
                                _calcularTotal(cantidadValue, descuentoValue);
                            return Text(
                              "Total: S/ ${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF493d9e),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    DetalleVenta nuevoDetalle;

                    if (productoSeleccionado != null &&
                        loteSeleccionado != null) {
                      nuevoDetalle = DetalleVenta(
                        idProducto: productoSeleccionado!.idProducto!,
                        idLote: loteSeleccionado!.idLote!,
                        cantidadProducto: cantidad.value,
                        descuentoProducto: descuento.value,
                        subtotalProducto:
                            _calcularTotal(cantidad.value, descuento.value),
                        precioUnidadProducto:
                            productoSeleccionado!.precioProducto,
                        gananciaProducto:
                            _calcularTotal(cantidad.value, descuento.value) -
                                (productoSeleccionado!.precioProducto *
                                    cantidad.value),
                      );
                    } else {
                      ErrorDialog(
                        context: context,
                        errorMessage: productoSeleccionado == null
                            ? "No se ha seleccionado ningun producto para agregar en la venta."
                            : "No se ha seleccionado ningun lote del producto seleccionado.",
                      );
                      return;
                    }

                    if (editarProducto) {
                      setState(() {
                        detallesVenta[index!] = nuevoDetalle;
                      });
                    } else {
                      setState(() {
                        productosVenta.add(productoSeleccionado!);
                        detallesVenta.add(nuevoDetalle);
                      });
                    }

                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2bbf55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Color.fromARGB(255, 124, 33, 243),
                                  width: 2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Imagen del producto
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child:
                                      productosVenta[index].rutaImagen == null
                                          ? Image.asset(
                                              'lib/assets/iconos/iconoImagen.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(productosVenta[index]
                                                  .rutaImagen!),
                                              fit: BoxFit.cover,
                                            ),
                                ),
                                const SizedBox(width: 10),
                                // Información del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productosVenta[index].nombreProducto,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          "Precio: S/ ${productosVenta[index].precioProducto}"),
                                      FutureBuilder<Unidad?>(
                                        future: Unidad.obtenerUnidadPorId(
                                            productosVenta[index].idUnidad!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text("Cargando...");
                                          }
                                          if (snapshot.hasError ||
                                              snapshot.data == null) {
                                            return const Text(
                                                "Error al obtener unidad");
                                          }
                                          return Text(
                                              "Cantidad: ${detallesVenta[index].cantidadProducto} ${snapshot.data!.tipoUnidad}");
                                        },
                                      ),
                                      Text(
                                          "Lote: ${detallesVenta[index].idLote}"),
                                      Text(
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
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
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
                    border: Border.all(
                        color: Color.fromARGB(255, 124, 33, 243), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _showAddProductDialog, // Funcionalidad de agregar producto
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Botón transparente para el diseño
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        _calcularTotalVenta()
                            .toStringAsFixed(2), // Calculando el total
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
                  onPressed: () {
                    if (productosVenta.isEmpty) {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "No se ha seleccionado ningun producto en la venta",
                      );
                      return;
                    }

                    context.push('/sales/create-sale/payment-page',
                        extra: detallesVenta);
                  }, // Aquí iría la funcionalidad de confirmar
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
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
