// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
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
  final List<Map<String, String>> lotes = [
    {
      "lote": "L001",
      "cantidad": "8",
      "perdidas": "2",
      "caducidad": "23/02/25",
      "compra": ""
    },
    {
      "lote": "L002",
      "cantidad": "30",
      "perdidas": "",
      "caducidad": "",
      "compra": ""
    },
    {
      "lote": "L003",
      "cantidad": "20",
      "perdidas": "",
      "caducidad": "",
      "compra": ""
    },
  ];
  Unidad? unidadProducto;
  late List<Categoria> categoriasProducto;
  int? selectedRowIndex;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => obtenerProducto());
  }

  Future<void> obtenerProducto() async {
    producto = await Producto.obtenerProductoPorID(widget.idProducto);

    if(producto == null){
      await AwesomeDialog(
       context: context,
       dialogType: DialogType.error,
       animType: AnimType.topSlide,
       title: "Error",
        desc: "El producto con id ${widget.idProducto} no fue encontrado :c",
        btnOkOnPress: () {
          context.pop()
        ;},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
    }

    categoriasProducto = await ProductoCategoria.obtenerCategoriasDeProducto(producto!.idProducto as int);
    unidadProducto = await Unidad.obtenerUnidadPorId(producto!.idUnidad);
    setState(() {});

    if(categoriasProducto == []){
      debugPrint("No se encontraron categorias en el producto ${producto!.idProducto}");
      return;
    }

    if(unidadProducto == null){
      debugPrint("Unidad del producto ${producto!.idProducto} no encontrada");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          producto!.nombreProducto,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () => _showAddLoteDialog()),
          IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  height: screenWidth * 0.2,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(producto!.rutaImagen as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 50);
                    },
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
                      producto!.codigoProducto as String,
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
                    Text("Stock actual: ${producto!.stockActual} ${unidadProducto!.tipoUnidad}",
                        style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text("Stock mínimo: ${producto!.stockMinimo} ${unidadProducto!.tipoUnidad}",
                        style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text("Stock máximo: ${producto!.stockMaximo} ${unidadProducto!.tipoUnidad}",
                        style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Divider(),
                    Text("Unidad del producto: ${unidadProducto!.tipoUnidad}",
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text("Precio por unidad del producto: S/. ${producto!.precioProducto}",
                        style: TextStyle(color: Colors.black, fontSize: 16)),
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
            Table(
              border: TableBorder.all(color: Color(0xFF493d9e)),
              columnWidths: const {
                0: FractionColumnWidth(0.1),
                1: FractionColumnWidth(0.1),
                2: FractionColumnWidth(0.1),
                3: FractionColumnWidth(0.1),
                4: FractionColumnWidth(0.1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.purple.shade100),
                  children: [
                    for (var title in [
                      "Lote",
                      "Cant.",
                      "Pérd.",
                      "Caduc.",
                      "Prec."
                    ])
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              children: List.generate(lotes.length, (index) {
                final lote = lotes[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedRowIndex =
                          selectedRowIndex == index ? null : index;
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Table(
                          border: TableBorder.all(color: Colors.purple),
                          children: [
                            TableRow(
                              children: [
                                for (var key in [
                                  "lote",
                                  "cantidad",
                                  "perdidas",
                                  "caducidad",
                                  "compra"
                                ])
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text(lote[key] ?? ''),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (selectedRowIndex == index)
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.purple, size: 20),
                                onPressed: () => _showEditDialog(index)),
                            IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () => _showDeleteDialog(index)),
                          ],
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddLoteDialog() {
    TextEditingController loteController = TextEditingController();
    TextEditingController cantidadController = TextEditingController();
    TextEditingController perdidasController = TextEditingController();
    TextEditingController caducidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Añadir nuevo lote",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A148C), // Morado oscuro elegante
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color(0xFF9C27B0), // Borde morado vibrante
              width: 2.0,
            ),
          ),
          backgroundColor: Color(0xFFF8F3FB), // Fondo lila claro
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _customTextField(loteController, "Lote"),
              const SizedBox(height: 10),
              _customTextField(cantidadController, "Cantidad"),
              const SizedBox(height: 10),
              _customTextField(perdidasController, "Pérdidas"),
              const SizedBox(height: 10),
              _customTextField(caducidadController, "Caducidad"),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF7B1FA2), // Morado suave
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  lotes.add({
                    'lote': loteController.text.trim(),
                    'cantidad': cantidadController.text.trim(),
                    'perdidas': perdidasController.text.trim(),
                    'caducidad': caducidadController.text.trim(),
                    'compra': '',
                  });
                });
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF388E3C), // Verde oscuro elegante
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Guardar",
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
    );
  }

  Widget _customTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF4A148C)), // Morado oscuro
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color(0xFF9C27B0)), // Borde morado vibrante
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Color(0xFF7B1FA2),
              width: 2.0), // Borde más oscuro al enfocar
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      style: const TextStyle(color: Color(0xFF4A148C)), // Texto morado oscuro
      cursorColor: Color(0xFF7B1FA2), // Cursor morado vibrante
    );
  }

  void _showEditDialog(int index) {
    TextEditingController cantidadController =
        TextEditingController(text: lotes[index]['cantidad']);
    TextEditingController perdidasController =
        TextEditingController(text: lotes[index]['perdidas']);
    TextEditingController caducidadController =
        TextEditingController(text: lotes[index]['caducidad']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Editar lote",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A148C), // Morado oscuro elegante
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color(0xFF9C27B0), // Borde morado
              width: 2.0,
            ),
          ),
          backgroundColor: Color(0xFFF8F3FB), // Fondo lila claro
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyledTextField(cantidadController, "Cantidad"),
                const SizedBox(height: 16),
                _buildStyledTextField(perdidasController, "Pérdidas"),
                const SizedBox(height: 16),
                _buildStyledTextField(caducidadController, "Caducidad"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Color(0xFF7B1FA2), // Morado suave
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  lotes[index]['cantidad'] = cantidadController.text.trim();
                  lotes[index]['perdidas'] = perdidasController.text.trim();
                  lotes[index]['caducidad'] = caducidadController.text.trim();
                });
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF7B1FA2), // Morado vibrante para el botón
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Guardar",
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
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFF4A148C), // Texto morado oscuro
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7B1FA2)), // Morado medio
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFF9C27B0), // Borde morado vibrante
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFF9C27B0),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFF4A148C),
            width: 2.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Eliminar Lote",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A148C),
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color(0xFF9C27B0),
              width: 2.0,
            ),
          ),
          backgroundColor: Color(0xFFF8F3FB),
          content: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "¿Estás seguro de que quieres eliminar este lote?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4A148C),
                fontSize: 16.0,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF7B1FA2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  lotes.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Eliminar",
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
    );
  }
}
