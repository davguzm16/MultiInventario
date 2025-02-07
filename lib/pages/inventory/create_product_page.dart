// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/unidad.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  // Controladores de texto
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController maxStockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Producto? producto;
  late Future<List<Categoria>> categoriasDisponibles;
  late Future<List<Unidad>> unidadesDisponibles;

  Unidad? unidadSeleccionada;
  List<Categoria> categoriasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    categoriasDisponibles = Categoria.obtenerCategorias();
    unidadesDisponibles = Unidad.obtenerUnidades();

    productCodeController.text = producto?.codigoProducto ?? "-" * 13;
  }

  @override
  void dispose() {
    // Liberar recursos
    productCodeController.dispose();
    productNameController.dispose();
    stockController.dispose();
    minStockController.dispose();
    maxStockController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        FutureBuilder<List<Categoria>>(
          future: categoriasDisponibles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No hay categorías disponibles.');
            }

            List<Categoria> categorias = snapshot.data!;
            debugPrint("Categorías recibidas: ${categorias.length}");

            // Convertir la lista de categorías en un Map<int, String>
            Map<int, String> categoriasMap = {
              for (var categoria in categorias)
                categoria.idCategoria!: categoria.nombreCategoria
            };

            return Wrap(
              spacing: 8.0,
              children: categoriasMap.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: categoriasSeleccionadas
                      .any((c) => c.idCategoria == entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        categoriasSeleccionadas.add(Categoria(
                            idCategoria: entry.key,
                            nombreCategoria: entry.value));
                      } else {
                        categoriasSeleccionadas
                            .removeWhere((c) => c.idCategoria == entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        TextButton(
          onPressed: _showAddCategoryDialog,
          child: Text('Agregar nueva categoría'),
        ),
      ],
    );
  }

  Widget _buildComboBox() {
    return FutureBuilder<List<Unidad>>(
      future: unidadesDisponibles,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<Unidad> unidades = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<int>(
            value: unidadSeleccionada?.idUnidad,
            items: unidades.map((unidad) {
              return DropdownMenuItem<int>(
                value: unidad.idUnidad,
                child: Text(unidad.tipoUnidad),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                unidadSeleccionada =
                    unidades.firstWhere((unidad) => unidad.idUnidad == value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Unidad de medida',
              border: OutlineInputBorder(),
            ),
            isDense: true,
            isExpanded: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Image.asset('lib/assets/iconos/iconoImagen.png',
                    height: 80),
              ),
              const SizedBox(height: 10),
              const Text('Código del producto',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(productCodeController.text,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      final result = await context.push('/barcode-scanner');

                      // Asegúrate de que el resultado es de tipo String?
                      if (result is String?) {
                        setState(() {
                          producto?.codigoProducto = result;
                          productCodeController.text =
                              producto?.codigoProducto ?? "-" * 13;
                        });
                      }
                    },
                    icon: Image.asset('lib/assets/iconos/iconoBarras.png',
                        height: 40),
                  )
                ],
              ),
              const SizedBox(height: 10),
              _buildCategorySelection(),
              _buildTextField('Nombre del producto', productNameController,
                  TextInputType.text),
              _buildComboBox(),
              _buildTextField(
                  'Stock actual', stockController, TextInputType.number),
              _buildTextField(
                  'Stock mínimo', minStockController, TextInputType.number),
              _buildTextField(
                  'Stock máximo', maxStockController, TextInputType.number),
              _buildTextField('Precio por medida', priceController,
                  const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: _showConfirmationDialog,
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
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

                  if (creada) {
                    setState(() {
                      categoriasDisponibles = Categoria.obtenerCategorias();
                    });
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

  bool _validateInputs() {
    // Verificamos que los campos no estén vacíos
    if (productNameController.text.isEmpty ||
        stockController.text.isEmpty ||
        minStockController.text.isEmpty ||
        maxStockController.text.isEmpty ||
        priceController.text.isEmpty ||
        unidadSeleccionada == null) {
      _showErrorDialog('Por favor, complete todos los campos');
      return false;
    }

    // Asignamos los valores a la variable 'producto' solo cuando sea necesario
    double stockActual = double.tryParse(stockController.text) ?? 0.0;
    double stockMinimo = double.tryParse(minStockController.text) ?? 0.0;
    double stockMaximo = double.tryParse(maxStockController.text) ?? 0.0;
    double precio = double.tryParse(priceController.text) ?? 0.0;

    producto = Producto(
      idUnidad: unidadSeleccionada!.idUnidad,
      nombreProducto: productNameController.text,
      precioProducto: precio,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      stockMaximo: stockMaximo,
    );

    // Verificamos si el código de producto es válido
    if (productCodeController.text != "-" * 13) {
      producto?.codigoProducto = productCodeController.text;
    }

    // Verificamos si los valores numéricos son correctos
    if (stockActual < 0 || stockMinimo < 0 || stockMaximo < 0 || precio < 0) {
      _showErrorDialog('Ingrese valores numéricos válidos en stock y precio.');
      return false;
    }

    // Verificamos que el stock mínimo no sea mayor que el máximo
    if (stockMinimo > stockMaximo) {
      _showErrorDialog('El stock mínimo no puede ser mayor que el máximo.');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showConfirmationDialog() {
    if (_validateInputs()) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.topSlide,
        title: 'Confirmación',
        desc: '¿Está seguro de que desea crear el producto?',
        btnOkOnPress: () async {
          bool creado =
              await Producto.crearProducto(producto!, categoriasSeleccionadas);

          if (creado) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              title: 'Producto creado',
              desc: 'El producto se ha creado con éxito.',
              btnOkOnPress: () => context.pop(),
            ).show();
          } else {
            _showErrorDialog('Hubo un problema al crear el producto.');
          }
        },
        btnCancelOnPress: () {},
      ).show();
    }
  }
}
