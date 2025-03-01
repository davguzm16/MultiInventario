// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:multiinventario/widgets/custom_text_field.dart';
import 'package:multiinventario/widgets/error_dialog.dart';

//10/02/2025
class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  // Controladores de texto
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController maxStockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Producto? producto;
  late Future<List<Categoria>> categoriasDisponibles;
  late Future<List<Unidad>> unidadesDisponibles;
  String? rutaImagen;

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
    minStockController.dispose();
    maxStockController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF493D9E), // Morado
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Categoria>>(
          future: categoriasDisponibles,
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
                final estaSeleccionada = categoriasSeleccionadas
                    .any((c) => c.idCategoria == categoria.idCategoria);

                return FilterChip(
                  label: Text(categoria.nombreCategoria),
                  selected: estaSeleccionada,
                  selectedColor: const Color(0xFF493D9E), // Morado
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: estaSeleccionada
                        ? Colors.white
                        : const Color(0xFF493D9E),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        categoriasSeleccionadas.add(categoria);
                      } else {
                        categoriasSeleccionadas.removeWhere(
                            (c) => c.idCategoria == categoria.idCategoria);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 30),
        Wrap(
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
              labelText: 'Unidad de medida *',
              labelStyle: TextStyle(color: Colors.black87),
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
                          )),
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
                      final String? result =
                          await context.push('/barcode-scanner');

                      debugPrint("Codigo Scaneado: $result");
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          productCodeController.text = result;
                        });
                      }
                    },
                    icon: Image.asset('lib/assets/iconos/iconoBarras.png',
                        height: 40),
                  )
                ],
              ),
              const SizedBox(height: 30),
              _buildCategorySelection(),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Nombre del producto',
                controller: productNameController,
                keyboardType: TextInputType.text,
                isRequired: true,
              ),
              _buildComboBox(),
              CustomTextField(
                label: 'Stock mínimo',
                controller: minStockController,
                keyboardType: TextInputType.number,
                unidad: unidadSeleccionada,
                isRequired: true,
              ),
              CustomTextField(
                label: 'Stock máximo',
                controller: maxStockController,
                keyboardType: TextInputType.number,
                unidad: unidadSeleccionada,
              ),
              CustomTextField(
                label: 'Precio por medida',
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                isPrice: true,
                isRequired: true,
                unidad: unidadSeleccionada,
              ),
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
                future: categoriasDisponibles,
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

                    if (editada) {
                      setState(() {
                        categoriasDisponibles = Categoria.obtenerCategorias();
                      });
                    }
                  }
                }
                Navigator.pop(context);
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
                future: categoriasDisponibles,
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

                  if (eliminada) {
                    setState(() {
                      categoriasDisponibles = Categoria.obtenerCategorias();
                    });
                  }
                }
                Navigator.pop(context);
              },
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    // Verificamos que los campos requeridos no estén vacíos
    if (productNameController.text.isEmpty ||
        minStockController.text.isEmpty ||
        priceController.text.isEmpty ||
        unidadSeleccionada == null) {
      ErrorDialog(
        context: context,
        errorMessage: 'Por favor, complete todos los campos obligatorios.',
      );
      return false;
    }

    // Convertimos los valores de los campos numéricos
    double stockMinimo = double.tryParse(minStockController.text) ?? 0.0;
    double? stockMaximo = maxStockController.text.isNotEmpty
        ? double.tryParse(maxStockController.text)
        : null;
    double precio = double.tryParse(priceController.text) ?? 0.0;

    // Creamos el objeto producto con valores validados
    producto = Producto(
      idUnidad: unidadSeleccionada!.idUnidad,
      nombreProducto: productNameController.text,
      precioProducto: precio,
      stockMinimo: stockMinimo,
      stockMaximo: stockMaximo,
      rutaImagen: rutaImagen,
    );

    // Validamos el código del producto
    if (productCodeController.text != "-" * 13) {
      producto?.codigoProducto = productCodeController.text;
    }

    // Validamos que los valores numéricos sean correctos
    if (stockMinimo < 0 ||
        (stockMaximo != null && stockMaximo < 0) ||
        precio < 0) {
      ErrorDialog(
        context: context,
        errorMessage: 'Ingrese valores numéricos válidos en stock y precio.',
      );
      return false;
    }

    // Verificamos que el stock mínimo no sea mayor que el máximo si stockMaximo no es nulo
    if (stockMaximo != null && stockMinimo > stockMaximo) {
      ErrorDialog(
        context: context,
        errorMessage: 'El stock mínimo no puede ser mayor que el máximo.',
      );
      return false;
    }

    return true;
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
            ErrorDialog(
              context: context,
              errorMessage: 'Hubo un problema al crear el producto.',
            );
          }
        },
        btnCancelOnPress: () {},
      ).show();
    }
  }
}
