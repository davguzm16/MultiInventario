// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multiinventario/widgets/all_custom_widgets.dart';

class ProductPage extends StatefulWidget {
  final int idProducto;

  const ProductPage({super.key, required this.idProducto});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Producto? producto;
  List<Lote> lotesProducto = [];
  Unidad? unidadProducto;
  List<Categoria> categoriasProducto = [];
  bool editandoCategorias = false;
  int? selectedRowIndex;

  @override
  void initState() {
    super.initState();
    obtenerProducto();
  }

  Future<void> obtenerProducto() async {
    producto = await Producto.obtenerProductoPorID(widget.idProducto);
    debugPrint("Resultado de la consulta: ${producto.toString()}");

    if (producto == null) {
      debugPrint("Producto ${widget.idProducto} no encontrado.");

      ErrorDialog(
        context: context,
        errorMessage:
            "El producto con id ${widget.idProducto} no fue encontrado.",
      );
      return;
    }

    categoriasProducto = await ProductoCategoria.obtenerCategoriasDeProducto(
        producto!.idProducto!);
    if (producto!.idUnidad != null) {
      unidadProducto = await Unidad.obtenerUnidadPorId(producto!.idUnidad!);
    }
    lotesProducto = await Lote.obtenerLotesDeProducto(producto!.idProducto!);

    setState(() {});
  }

  void _showAddCategoryDialog() {
    TextEditingController nuevaCategoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar nueva categoría"),
          content: TextField(
            controller: nuevaCategoriaController,
            decoration: const InputDecoration(
              labelText: "Nombre de la categoría",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String nombreCategoria = nuevaCategoriaController.text.trim();
                if (nombreCategoria.isNotEmpty) {
                  bool creada = await Categoria.crearCategoria(
                    Categoria(nombreCategoria: nombreCategoria),
                  );

                  if (!creada) {
                    ErrorDialog(
                      context: context,
                      errorMessage:
                          "Hubo un error al crear la categoria $nombreCategoria",
                    );
                  } else {
                    setState(() {});
                  }
                }
                context.pop();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog() {
    TextEditingController editCategoriaController = TextEditingController();
    Categoria? categoriaSeleccionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar categoría"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<Categoria>>(
                future: Categoria.obtenerCategorias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Text("No hay categorías disponibles.");
                  }

                  return DropdownButtonFormField<Categoria>(
                    value: categoriaSeleccionada,
                    onChanged: (newValue) {
                      setState(() {
                        categoriaSeleccionada = newValue;
                        editCategoriaController.text =
                            newValue?.nombreCategoria ?? "";
                      });
                    },
                    items: snapshot.data!.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.nombreCategoria),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "Selecciona una categoría",
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editCategoriaController,
                decoration: const InputDecoration(
                  labelText: "Nuevo nombre",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (categoriaSeleccionada != null) {
                  String nuevoNombre = editCategoriaController.text.trim();
                  if (nuevoNombre.isNotEmpty) {
                    bool editada = await Categoria.editarCategoria(
                      categoriaSeleccionada!.idCategoria!,
                      nuevoNombre,
                    );

                    if (!editada) {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "Hubo un error al editar la categoria ${categoriaSeleccionada!.nombreCategoria}",
                      );
                    } else {
                      setState(() {});
                    }
                  }
                }
                context.pop();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveCategoryDialog() {
    Categoria? categoriaSeleccionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar categoría"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<Categoria>>(
                future: Categoria.obtenerCategorias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Text("No hay categorías disponibles.");
                  }

                  return DropdownButtonFormField<Categoria>(
                    value: categoriaSeleccionada,
                    onChanged: (newValue) {
                      setState(() {
                        categoriaSeleccionada = newValue;
                      });
                    },
                    items: snapshot.data!.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.nombreCategoria),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "Selecciona una categoría",
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (categoriaSeleccionada != null) {
                  bool eliminada = await Categoria.eliminarCategoria(
                    categoriaSeleccionada!.idCategoria!,
                  );

                  if (!eliminada) {
                    ErrorDialog(
                      context: context,
                      errorMessage:
                          "Hubo un error al eliminar la categoria ${categoriaSeleccionada!.nombreCategoria}",
                    );
                  } else {
                    setState(() {});
                  }
                }
                context.pop();
              },
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProductDialog() async {
    TextEditingController productCodeController =
        TextEditingController(text: producto!.codigoProducto);
    TextEditingController productNameController =
        TextEditingController(text: producto!.nombreProducto);
    TextEditingController minStockController =
        TextEditingController(text: producto!.stockMinimo.toString());
    TextEditingController maxStockController =
        TextEditingController(text: producto!.stockMaximo?.toString() ?? "");
    TextEditingController priceController =
        TextEditingController(text: producto!.precioProducto.toString());

    String? rutaImagen = producto!.rutaImagen;
    Unidad? unidadProducto =
        await Unidad.obtenerUnidadPorId(producto!.idUnidad!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Producto"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    rutaImagen = await context.push("/image-picker") as String?;
                    setState(() {});
                  },
                  icon: SizedBox(
                    width: 80,
                    height: 80,
                    child: rutaImagen == null
                        ? Image.asset(
                            'lib/assets/iconos/iconoImagen.png',
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(rutaImagen!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Código del producto',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        final String? result =
                            await context.push('/barcode-scanner');
                        if (result != null && result.isNotEmpty) {
                          setState(() {
                            productCodeController.text = result;
                          });
                        }
                      },
                      icon: Image.asset('lib/assets/iconos/iconoBarras.png',
                          height: 40),
                    ),
                  ],
                ),
                Text(
                  productCodeController.text.isEmpty
                      ? "-" * 13
                      : productCodeController.text,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Nombre del producto',
                  controller: productNameController,
                  keyboardType: TextInputType.text,
                  isRequired: true,
                ),
                FutureBuilder<List<Unidad>>(
                  future: Unidad.obtenerUnidades(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    List<Unidad> unidades = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<int>(
                        value: unidadProducto?.idUnidad,
                        items: unidades.map((unidad) {
                          return DropdownMenuItem<int>(
                            value: unidad.idUnidad,
                            child: Text(unidad.tipoUnidad),
                          );
                        }).toList(),
                        onChanged: (value) {
                          unidadProducto = unidades
                              .firstWhere((unidad) => unidad.idUnidad == value);
                          producto!.idUnidad = unidadProducto?.idUnidad;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Unidad de medida *',
                          labelStyle: TextStyle(color: Colors.black87),
                          border: OutlineInputBorder(),
                        ),
                        isDense: true,
                        isExpanded: true,
                      ),
                    );
                  },
                ),
                CustomTextField(
                  label: 'Stock mínimo',
                  controller: minStockController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Stock máximo',
                  controller: maxStockController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Precio por medida',
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  isPrice: true,
                  isRequired: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (productNameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    minStockController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Por favor, completa los campos obligatorios."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                double? precio = double.tryParse(priceController.text);
                double? stockMin = double.tryParse(minStockController.text);
                double? stockMax = double.tryParse(maxStockController.text);

                if (precio == null ||
                    stockMin == null ||
                    (maxStockController.text.isNotEmpty && stockMax == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Los valores numéricos son inválidos."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Producto productoActualizado = Producto(
                  idProducto: producto!.idProducto,
                  idUnidad: unidadProducto?.idUnidad,
                  codigoProducto: productCodeController.text,
                  nombreProducto: productNameController.text,
                  precioProducto: precio,
                  stockMinimo: stockMin,
                  stockMaximo: stockMax,
                  rutaImagen: rutaImagen,
                  fechaModificacion: DateTime.now(),
                );

                bool actualizado =
                    await Producto.actualizarProducto(productoActualizado);

                if (actualizado) {
                  SuccessDialog(
                    context: context,
                    successMessage: "Producto actualizado correctamente.",
                    btnOkOnPress: () => Navigator.pop(context),
                  );
                  obtenerProducto();
                } else {
                  SuccessDialog(
                    context: context,
                    successMessage: "Error al actualizar el producto.",
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF493D9E),
              ),
            ),
            IconButton(
              icon: Icon(editandoCategorias ? Icons.check : Icons.edit),
              color: Colors.black,
              onPressed: () {
                if (editandoCategorias) {
                  ProductoCategoria.actualizarCategoriasProducto(
                    producto!.idProducto!,
                    categoriasProducto,
                  ).then((updated) {
                    if (updated) {
                      SuccessDialog(
                        context: context,
                        successMessage:
                            "Las categorías del producto han sido actualizadas correctamente!",
                      );
                    } else {
                      ErrorDialog(
                        context: context,
                        errorMessage:
                            "Hubo un error al actualizar las categorías",
                      );
                    }
                  });
                }
                setState(() {
                  editandoCategorias = !editandoCategorias;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Categoria>>(
          future: Categoria.obtenerCategorias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No hay categorías disponibles.');
            }

            List<Categoria> categorias = snapshot.data!;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categorias.map((categoria) {
                final estaSeleccionada = categoriasProducto
                    .any((c) => c.idCategoria == categoria.idCategoria);

                return FilterChip(
                  label: Text(categoria.nombreCategoria),
                  selected: estaSeleccionada,
                  selectedColor: const Color(0xFF493D9E),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: estaSeleccionada
                        ? Colors.white
                        : const Color(0xFF493D9E),
                  ),
                  onSelected: editandoCategorias
                      ? (bool selected) {
                          setState(() {
                            if (selected) {
                              categoriasProducto.add(categoria);
                            } else {
                              categoriasProducto.removeWhere((c) =>
                                  c.idCategoria == categoria.idCategoria);
                            }
                          });
                        }
                      : null,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 30),
        editandoCategorias
            ? Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: _showAddCategoryDialog,
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF493D9E)),
                    child: const Text('Agregar categoría'),
                  ),
                  TextButton(
                    onPressed: _showEditCategoryDialog,
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF493D9E)),
                    child: const Text('Editar categoría'),
                  ),
                  TextButton(
                    onPressed: _showRemoveCategoryDialog,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Eliminar categoría'),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          producto?.nombreProducto ?? "Cargando...",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _showEditProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _showLoteDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.black,
            onPressed: () {
              ConfirmDialog(
                context: context,
                title: "Eliminar producto",
                message: "Está seguro de eliminar el producto?",
                btnOkOnPress: () async {
                  if (await Producto.eliminarProducto(producto!.idProducto!)) {
                    SuccessDialog(
                      context: context,
                      successMessage:
                          "El producto ${producto!.nombreProducto} fue eliminado con exito!",
                      btnOkOnPress: () => context.pop(),
                    );
                  } else {
                    ErrorDialog(
                      context: context,
                      errorMessage:
                          "Hubo un error al eliminar el producto ${producto!.nombreProducto}",
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: FutureBuilder<Producto?>(
          future: Producto.obtenerProductoPorID(widget.idProducto),
          builder: (BuildContext context, AsyncSnapshot<Producto?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Producto no encontrado.'));
            }

            Producto productoData = snapshot.data!;

            return ListView(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: screenWidth * 0.2,
                      width: screenWidth * 0.2,
                      child: productoData.rutaImagen == null
                          ? Image.asset(
                              'lib/assets/iconos/iconoImagen.png',
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(productoData.rutaImagen!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Código del producto",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              productoData.codigoProducto ?? "-" * 13,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Card(
                  elevation: 0,
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stock actual: ${productoData.stockActual} ${unidadProducto?.tipoUnidad ?? ''}",
                          style: TextStyle(
                              color: Color(0xFF493d9e),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          "Stock mínimo: ${productoData.stockMinimo} ${unidadProducto?.tipoUnidad ?? ''}",
                          style: TextStyle(
                              color: Color(0xFF493d9e),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          "Stock máximo: ${productoData.stockMaximo ?? "---"} ${unidadProducto?.tipoUnidad ?? ''}",
                          style: TextStyle(
                              color: Color(0xFF493d9e),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Divider(),
                        Text(
                          "Unidad del producto: ${unidadProducto?.tipoUnidad ?? 'No definida'}",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Precio por unidad: S/ ${productoData.precioProducto.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Fecha de creación: ${productoData.fechaCreacion?.toLocal().toString().split(' ')[0] ?? "---"}",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Fecha de modificación: ${productoData.fechaModificacion?.toLocal().toString().split(' ')[0] ?? "---"}",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCategorySelection(),
                const SizedBox(height: 20),
                const Text(
                  "Lotes del producto",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                if (lotesProducto.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "Aún no hay lotes creados para este producto.",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: lotesProducto.length,
                    itemBuilder: (context, index) {
                      final lote = lotesProducto[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  _showLoteDialog(lote: lote, editarLote: true),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Editar',
                            ),
                            SlidableAction(
                              onPressed: (context) => _showDeleteDialog(lote),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Eliminar',
                            ),
                          ],
                        ),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF493d9e),
                              foregroundColor: Colors.white,
                              child: Text('${lote.idLote}'),
                            ),
                            title: Text(
                                'Cantidad Actual: ${lote.cantidadActual} ${unidadProducto?.tipoUnidad ?? ''}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Cantidad Comprada: ${lote.cantidadComprada} ${unidadProducto?.tipoUnidad ?? ''}'),
                                Text(
                                    'Pérdidas: ${lote.cantidadPerdida} ${unidadProducto?.tipoUnidad ?? ''}'),
                                Text(
                                    'Precio de Compra: S/ ${lote.precioCompra.toStringAsPrecision(2)}'),
                                Text(
                                    'Precio de Compra Unitario: S/ ${lote.precioCompraUnidad.toStringAsFixed(2)}'),
                                Text(
                                    'Fecha Compra: ${lote.fechaCompra?.toLocal().toString().split(' ')[0] ?? "---"}'),
                                Text(
                                    'Fecha Caducidad: ${lote.fechaCaducidad?.toLocal().toString().split(' ')[0] ?? "---"}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLoteDialog({
    Lote? lote,
    bool editarLote = false,
  }) {
    final cantidadCompradaController = TextEditingController(
      text: editarLote ? lote!.cantidadComprada.toString() : '',
    );
    final precioController = TextEditingController(
      text: editarLote ? lote!.precioCompra.toString() : '',
    );
    final fechaCaducidadController = TextEditingController(
      text: editarLote && lote!.fechaCaducidad != null
          ? lote.fechaCaducidad!.toIso8601String().split('T')[0]
          : '',
    );
    final fechaCompraController = TextEditingController(
      text: editarLote && lote!.fechaCompra != null
          ? lote.fechaCompra!.toIso8601String().split('T')[0]
          : DateTime.now().toIso8601String().split('T')[0],
    );

    final ValueNotifier<int> cantidadPerdida =
        ValueNotifier<int>(editarLote ? (lote!.cantidadPerdida ?? 0) : 0);
    final ValueNotifier<int> cantidadComprada =
        ValueNotifier<int>(editarLote ? lote!.cantidadActual : 0);

    DateTime selectedFechaCompra = editarLote && lote!.fechaCompra != null
        ? lote.fechaCompra!
        : DateTime.now();
    DateTime? selectedDate =
        editarLote && lote!.fechaCaducidad != null ? lote.fechaCaducidad : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editarLote ? 'Editar Lote' : 'Nuevo Lote'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fechaCompraController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Compra',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedFechaCompra,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedFechaCompra = picked;
                    fechaCompraController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                label: "Cantidad Comprada",
                controller: cantidadCompradaController,
                keyboardType: TextInputType.number,
                unidad: unidadProducto,
                isRequired: true,
                onChanged: (value) {
                  cantidadComprada.value = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "Cantidad de pérdida",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (cantidadPerdida.value > 0) {
                        cantidadPerdida.value--;
                      }
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: cantidadPerdida,
                    builder: (context, value, child) {
                      return Text(value.toString());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cantidadPerdida.value++;
                    },
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomTextField(
                label: "Precio Compra Total",
                controller: precioController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                unidad: unidadProducto,
                isPrice: true,
              ),
              SizedBox(height: 15),
              TextField(
                controller: fechaCaducidadController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Caducidad',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    fechaCaducidadController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              SizedBox(height: 30),
              ValueListenableBuilder<int>(
                valueListenable: cantidadComprada,
                builder: (context, cantidadValue, child) {
                  return ValueListenableBuilder<int>(
                    valueListenable: cantidadPerdida,
                    builder: (context, cantidadPerdidaValue, child) {
                      int cantidadDisponible =
                          cantidadValue - cantidadPerdidaValue;
                      return Text(
                        "Cantidad Actual: ${cantidadDisponible < 0 ? "Cantidad inválida!" : cantidadDisponible}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cantidadDisponible < 0
                              ? Colors.red
                              : Color(0xFF493d9e),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              if (cantidadCompradaController.text.isEmpty ||
                  precioController.text.isEmpty) {
                ErrorDialog(
                  context: context,
                  errorMessage: "Por favor completar los campos obligatorios",
                );
                return;
              }

              if (cantidadPerdida.value >
                  int.parse(cantidadCompradaController.text)) {
                ErrorDialog(
                  context: context,
                  errorMessage:
                      "La cantidad comprada no puede ser menor que la cantidad perdida",
                );
                return;
              }

              if (fechaCaducidadController.text.isNotEmpty &&
                  (selectedDate != null &&
                      selectedDate!.isBefore(selectedFechaCompra))) {
                ErrorDialog(
                  context: context,
                  errorMessage:
                      "La fecha de compra no puede ser después que la fecha de caducidad",
                );
                return;
              }

              if (editarLote) {
                if (int.parse(cantidadCompradaController.text) <
                    (lote!.cantidadComprada - lote.cantidadActual)) {
                  ErrorDialog(
                    context: context,
                    errorMessage:
                        "La cantidad insertada no debe ser menor a la cantidad de venta y la cantidad pérdida",
                  );
                  return;
                }

                final loteEditado = Lote(
                  idProducto: widget.idProducto,
                  idLote: lote.idLote,
                  cantidadActual: int.parse(cantidadCompradaController.text) -
                      cantidadPerdida.value,
                  cantidadComprada: int.parse(cantidadCompradaController.text),
                  cantidadPerdida: cantidadPerdida.value,
                  precioCompra: double.parse(precioController.text),
                  precioCompraUnidad: double.parse(precioController.text) /
                      int.parse(cantidadCompradaController.text),
                  fechaCaducidad: selectedDate,
                  fechaCompra: selectedFechaCompra,
                  estaDisponible: lote.estaDisponible,
                );

                final actualizado = await Lote.actualizarLote(loteEditado);

                if (actualizado) {
                  obtenerProducto();
                  SuccessDialog(
                    context: context,
                    successMessage: "Lote actualizado exitosamente!",
                    btnOkOnPress: () => context.pop(),
                  );
                }
              } else {
                final nuevoLote = Lote(
                  idProducto: widget.idProducto,
                  cantidadActual: int.parse(cantidadCompradaController.text) -
                      cantidadPerdida.value,
                  cantidadComprada: int.parse(cantidadCompradaController.text),
                  cantidadPerdida: cantidadPerdida.value,
                  precioCompra: double.parse(precioController.text),
                  precioCompraUnidad: double.parse(precioController.text) /
                      int.parse(cantidadCompradaController.text),
                  fechaCaducidad: selectedDate,
                  fechaCompra: selectedFechaCompra,
                );

                final creado = await Lote.crearLote(nuevoLote);
                if (creado) {
                  obtenerProducto();
                  SuccessDialog(
                    context: context,
                    successMessage: "Lote creado exitosamente!",
                    btnOkOnPress: () => context.pop(),
                  );
                }
              }
            },
            child: Text(editarLote ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Lote lote) {
    ConfirmDialog(
      context: context,
      title: "Eliminar Lote",
      message: "¿Estás seguro de que deseas eliminar este lote?",
      btnOkOnPress: () async {
        bool eliminado = await Lote.eliminarLote(lote);
        debugPrint("Eliminado: $eliminado");
        if (eliminado) {
          obtenerProducto();
          SuccessDialog(
            context: context,
            successMessage: "Lote eliminado exitosamente!",
          );
        }
      },
    );
  }
}
