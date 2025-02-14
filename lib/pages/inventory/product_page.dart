// ignore_for_file: use_build_context_synchronously//

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  int? selectedRowIndex;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => obtenerProducto());
  }

  Future<void> obtenerProducto() async {
    producto = await Producto.obtenerProductoPorID(widget.idProducto);
    debugPrint("Resultado de la consulta: ${producto.toString()}");

    if (producto == null) {
      debugPrint("Producto ${widget.idProducto} no encontrado.");
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: "Error",
        desc: "El producto con id ${widget.idProducto} no fue encontrado.",
        btnOkOnPress: () => context.pop(),
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Si el producto o la unidad aún no se han cargado, muestra un indicador de carga.
    if (producto == null || unidadProducto == null) {
      debugPrint("Producto: $producto, unidadProducto: $unidadProducto");
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cargando..."),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          producto!.nombreProducto,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _showAddLoteDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: ListView(
          children: [
            Row(
              children: [
                SizedBox(
                  height: screenWidth * 0.2,
                  width: screenWidth * 0.2,
                  child: producto?.rutaImagen != null
                      ? Image.asset(
                          producto!.rutaImagen!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported,
                                size: 50);
                          },
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Código del producto",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    Text(
                      producto?.codigoProducto ?? "-" * 13,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stock actual: ${producto!.stockActual} ${unidadProducto!.tipoUnidad}",
                      style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      "Stock mínimo: ${producto!.stockMinimo} ${unidadProducto!.tipoUnidad}",
                      style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      "Stock máximo: ${producto!.stockMaximo ?? "---"} ${unidadProducto!.tipoUnidad}",
                      style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Divider(),
                    Text(
                      "Unidad del producto: ${unidadProducto!.tipoUnidad}",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      "Precio por unidad del producto: S/. ${producto!.precioProducto}",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Categorías del producto",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriasProducto.map((categoria) {
                return Chip(
                  label: Text(categoria.nombreCategoria),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: Color(0xFF493d9e),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            const Text(
              "Lotes del producto",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),

            // Sección de tabla desplazable
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
                          onPressed: (context) => _showEditLoteDialog(lote),
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
                          backgroundColor: Colors.purple,
                          child: Text('${lote.idLote}'),
                        ),
                        title: Text(
                            'Cantidad: ${lote.cantidadActual} ${unidadProducto!.tipoUnidad}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Precio de compra: S/. ${lote.precioCompra}'),
                            if (lote.fechaCaducidad != null)
                              Text(
                                  'Caducidad: ${lote.fechaCaducidad!.toIso8601String().split('T')[0]}'),
                          ],
                        ),
                        trailing: lote.cantidadPerdida != null &&
                                lote.cantidadPerdida! > 0
                            ? Chip(
                                label:
                                    Text('Pérdidas: ${lote.cantidadPerdida}'),
                                backgroundColor: Colors.red[100],
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLoteDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showAddLoteDialog() {
    final cantidadController = TextEditingController();
    final precioController = TextEditingController();
    final fechaCaducidadController = TextEditingController();
    final fechaCompraController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    DateTime selectedFechaCompra = DateTime.now();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Lote'),
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
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    selectedFechaCompra = picked;
                    fechaCompraController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Asignada',
                  suffixText: 'unidades',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Compra Total',
                  prefixText: 'S/. ',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fechaCaducidadController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Caducidad',
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (cantidadController.text.isEmpty ||
                  precioController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, complete todos los campos')),
                );
                return;
              }

              final nuevoLote = Lote(
                idProducto: widget.idProducto,
                cantidadActual: int.parse(cantidadController.text),
                cantidadComprada: int.parse(cantidadController.text),
                precioCompra: double.parse(precioController.text),
                precioCompraUnidad: double.parse(precioController.text) /
                    int.parse(cantidadController
                        .text), // Calculamos el precio unitario
                fechaCaducidad: selectedDate,
                fechaCompra: selectedFechaCompra,
              );

              final creado = await Lote.crearLote(nuevoLote);
              if (creado) {
                final nuevosLotes =
                    await Lote.obtenerLotesDeProducto(widget.idProducto);
                setState(() {
                  lotesProducto = nuevosLotes;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lote creado exitosamente')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditLoteDialog(Lote lote) {
    final cantidadController =
        TextEditingController(text: lote.cantidadActual.toString());
    final precioController =
        TextEditingController(text: lote.precioCompra.toString());
    final fechaCaducidadController = TextEditingController(
      text: lote.fechaCaducidad?.toIso8601String().split('T')[0] ?? '',
    );
    final fechaCompraController = TextEditingController(
      text: lote.fechaCompra?.toIso8601String().split('T')[0] ??
          DateTime.now().toIso8601String().split('T')[0],
    );
    DateTime selectedFechaCompra = lote.fechaCompra ?? DateTime.now();
    DateTime? selectedDate = lote.fechaCaducidad;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Lote'),
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
                    lastDate:
                        DateTime(2100), // Permite seleccionar cualquier fecha
                  );
                  if (picked != null) {
                    selectedFechaCompra = picked;
                    fechaCompraController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Asignada',
                  suffixText: 'unidades',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Compra Total',
                  prefixText: 'S/. ',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fechaCaducidadController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Caducidad',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (cantidadController.text.isEmpty ||
                  precioController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, complete todos los campos')),
                );
                return;
              }

              final loteEditado = Lote(
                idLote: lote.idLote,
                idProducto: lote.idProducto,
                cantidadActual: int.parse(cantidadController.text),
                cantidadComprada: lote.cantidadComprada,
                precioCompra: double.parse(precioController.text),
                precioCompraUnidad: double.parse(precioController.text) /
                    lote.cantidadComprada, // Calculamos el precio unitario
                fechaCaducidad: selectedDate,
                fechaCompra: selectedFechaCompra,
              );

              final actualizado = await Lote.actualizarLote(loteEditado);
              if (actualizado) {
                final nuevosLotes =
                    await Lote.obtenerLotesDeProducto(widget.idProducto);
                setState(() {
                  lotesProducto = nuevosLotes;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lote actualizado exitosamente')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Lote lote) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Lote", textAlign: TextAlign.center),
          content:
              const Text("¿Estás seguro de que deseas eliminar este lote?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                bool eliminado = await Lote.eliminarLote(lote.idLote!);
                if (eliminado) {
                  final nuevosLotes =
                      await Lote.obtenerLotesDeProducto(widget.idProducto);
                  setState(() {
                    lotesProducto = nuevosLotes;
                  });
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
}
