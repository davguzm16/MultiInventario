// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:multiinventario/models/unidad.dart';

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
    obtenerProducto();
  }

  Future<void> obtenerProducto() async {
    producto = await Producto.obtenerProductoPorID(widget.idProducto);
    debugPrint("Producto ${producto.toString()}");

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
    unidadProducto = await Unidad.obtenerUnidadPorId(producto!.idUnidad!);
    lotesProducto = await Lote.obtenerLotesDeProducto(producto!.idProducto!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Si el producto o la unidad aún no se han cargado, muestra un indicador de carga.
    if (producto == null || unidadProducto == null) {
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
                  child: producto?.rutaImagen == null
                      ? Image.asset(
                          'lib/assets/iconos/iconoImagen.png',
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(producto!.rutaImagen!),
                          fit: BoxFit.cover,
                        ),
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
              Padding(
                padding: const EdgeInsets.all(20.0),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Table(
                      border: TableBorder.all(color: const Color(0xFF493d9e)),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(100),
                      },
                      children: [
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.purple.shade100),
                          children: [
                            _tableHeader("Lote"),
                            _tableHeader("Cantidad"),
                            _tableHeader("Pérdidas"),
                            _tableHeader("Caducidad"),
                            _tableHeader("Precio"),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: List.generate(lotesProducto.length, (index) {
                        final lote = lotesProducto[index];
                        final isSelected = selectedRowIndex == index;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedRowIndex = isSelected ? null : index;
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Table(
                                  border: TableBorder.all(color: Colors.purple),
                                  columnWidths: const {
                                    0: FixedColumnWidth(100),
                                    1: FixedColumnWidth(100),
                                    2: FixedColumnWidth(100),
                                    3: FixedColumnWidth(150),
                                    4: FixedColumnWidth(100),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        _tableCell("${lote.idLote}"),
                                        _tableCell("${lote.cantidadActual}"),
                                        _tableCell(
                                            "${lote.cantidadPerdida ?? "---"}"),
                                        _tableCell(
                                          lote.fechaCaducidad
                                                  ?.toIso8601String()
                                                  .split('T')[0] ??
                                              "---",
                                        ),
                                        _tableCell(
                                          "S/. ${lote.precioCompra.toStringAsFixed(2)}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _showEditLoteDialog(lote),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _showDeleteDialog(lote),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String title) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String content) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(child: Text(content)),
      ),
    );
  }

  void _showAddLoteDialog() {
    TextEditingController cantidadController = TextEditingController();
    TextEditingController perdidasController = TextEditingController();
    TextEditingController precioController = TextEditingController();
    TextEditingController caducidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir nuevo lote", textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(cantidadController, "Cantidad Asignada"),
                const SizedBox(height: 10),
                _customTextField(perdidasController, "Pérdidas (Opcional)"),
                const SizedBox(height: 10),
                _customTextField(precioController, "Precio de Compra"),
                const SizedBox(height: 10),
                _customTextField(
                    caducidadController, "Caducidad [YYYY-MM-DD] (Opcional)"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String cantidadText = cantidadController.text.trim();
                String precioText = precioController.text.trim();

                if (cantidadText.isEmpty || precioText.isEmpty) {
                  await AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: "Campos vacíos",
                    desc: "Debes llenar todos los campos obligatorios.",
                    btnOkOnPress: () {},
                    btnOkIcon: Icons.warning,
                    btnOkColor: Colors.orange,
                  ).show();
                  return;
                }

                int? cantidadAsignada = int.tryParse(cantidadText);
                double? precioCompra = double.tryParse(precioText);

                if (cantidadAsignada == null || precioCompra == null) {
                  await AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: "Entrada inválida",
                    desc: "Verifica que los valores ingresados sean correctos.",
                    btnOkOnPress: () {},
                    btnOkIcon: Icons.warning,
                    btnOkColor: Colors.orange,
                  ).show();
                  return;
                }

                Lote nuevoLote = Lote(
                  idProducto: widget.idProducto,
                  cantidadActual: cantidadAsignada,
                  cantidadComprada: 10,
                  cantidadPerdida:
                      int.tryParse(perdidasController.text.trim()) ?? 0,
                  precioCompra: precioCompra,
                  fechaCaducidad: caducidadController.text.isNotEmpty
                      ? DateTime.tryParse(caducidadController.text.trim())
                      : null,
                );

                bool creado = await Lote.crearLote(nuevoLote);
                if (creado) {
                  lotesProducto =
                      await Lote.obtenerLotesDeProducto(widget.idProducto);
                  setState(() {});
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

  void _showEditLoteDialog(Lote lote) {
    TextEditingController cantidadController =
        TextEditingController(text: lote.cantidadActual.toString());
    TextEditingController perdidasController =
        TextEditingController(text: (lote.cantidadPerdida ?? 0).toString());
    TextEditingController precioController =
        TextEditingController(text: lote.precioCompra.toString());
    TextEditingController caducidadController = TextEditingController(
        text: lote.fechaCaducidad != null
            ? lote.fechaCaducidad!.toIso8601String().split('T')[0]
            : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar lote", textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(cantidadController, "Cantidad Asignada"),
                const SizedBox(height: 10),
                _customTextField(perdidasController, "Pérdidas (Opcional)"),
                const SizedBox(height: 10),
                _customTextField(precioController, "Precio de Compra"),
                const SizedBox(height: 10),
                _customTextField(
                    caducidadController, "Caducidad [YYYY-MM-DD] (Opcional)"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String cantidadText = cantidadController.text.trim();
                String precioText = precioController.text.trim();

                if (cantidadText.isEmpty || precioText.isEmpty) {
                  await AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: "Campos vacíos",
                    desc: "Debes llenar todos los campos obligatorios.",
                    btnOkOnPress: () {},
                    btnOkIcon: Icons.warning,
                    btnOkColor: Colors.orange,
                  ).show();
                  return;
                }

                int? cantidadAsignada = int.tryParse(cantidadText);
                double? precioCompra = double.tryParse(precioText);

                if (cantidadAsignada == null || precioCompra == null) {
                  await AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: "Entrada inválida",
                    desc: "Verifica que los valores ingresados sean correctos.",
                    btnOkOnPress: () {},
                    btnOkIcon: Icons.warning,
                    btnOkColor: Colors.orange,
                  ).show();
                  return;
                }

                Lote loteEditado = Lote(
                  idLote: lote.idLote,
                  idProducto: lote.idProducto,
                  cantidadActual: cantidadAsignada,
                  cantidadComprada: 10,
                  cantidadPerdida:
                      int.tryParse(perdidasController.text.trim()) ?? 0,
                  precioCompra: precioCompra,
                  fechaCaducidad: caducidadController.text.isNotEmpty
                      ? DateTime.tryParse(caducidadController.text.trim())
                      : null,
                );

                bool actualizado = await Lote.actualizarLote(loteEditado);
                if (actualizado) {
                  lotesProducto =
                      await Lote.obtenerLotesDeProducto(widget.idProducto);
                  setState(() {});
                }

                context.pop();
              },
              child: const Text("Guardar cambios"),
            ),
          ],
        );
      },
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
                  lotesProducto =
                      await Lote.obtenerLotesDeProducto(widget.idProducto);
                  setState(() {});
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

  Widget _customTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
