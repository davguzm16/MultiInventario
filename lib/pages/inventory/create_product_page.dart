// ignore_for_file: library_private_types_in_public_api, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:multiinventario/models/producto.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController productCodeController =
      TextEditingController(text: '7756432343');
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController maxStockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  late Producto producto;

  Map<int, String> unidades = {
    1: 'kilogramo (kg)',
    2: 'litro (l)',
    3: 'unidad (u)'
  };

  Map<int, String> categorias = {
    1: 'Abarrotes',
    2: 'Ferretería',
    3: 'Útiles escolares',
    4: 'Bebidas',
    5: 'Enlatados'
  };

  int _idUnidadSeleccionada = -1;
  List<int> _idCategoriasSeleccionadas = [];

  @override
  void dispose() {
    productCodeController.dispose();
    productNameController.dispose();
    stockController.dispose();
    minStockController.dispose();
    maxStockController.dispose();
    priceController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    String newCategory = categoryController.text.trim();
    if (newCategory.isNotEmpty && !categorias.containsValue(newCategory)) {
      setState(() {
        int newId = categorias.keys.isNotEmpty ? categorias.keys.last + 1 : 1;
        categorias[newId] = newCategory;
        categoryController.clear();
      });
    }
    Navigator.pop(context, 'producto_creado');
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nueva categoría'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(labelText: 'Nombre de la categoría'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _addCategory,
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Text('El producto ha sido registrado con éxito.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Cierra el Dialog
                Navigator.pop(context);

                // Actualiza la pantalla de inventario
                Navigator.pop(context,
                    'producto_creado'); // Esto será recibido en la pantalla de inventario
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    if (_validateInputs()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmar Registro'),
            content:
                Text('¿Estás seguro de que deseas confirmar este producto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Insertamos el producto en la BD
                  if (await Producto.crearProducto(producto)) {
                    _showSuccessDialog();
                  } else {
                    _showErrorDialog(
                        "Hubo un problema al crear el producto en la base de datos");
                  }
                },
                child: Text('Confirmar'),
              ),
            ],
          );
        },
      );
    }
  }

  bool _validateInputs() {
    // Asignamos los valores a la variable global 'producto'
    producto = Producto(
      idUnidad: _idUnidadSeleccionada,
      codigoProducto: productCodeController.text,
      nombreProducto: productNameController.text,
      precioProducto: double.tryParse(priceController.text) ?? 0.0,
      stockActual: double.tryParse(stockController.text) ?? 0.0,
      stockMinimo: double.tryParse(minStockController.text) ?? 0.0,
      stockMaximo: double.tryParse(maxStockController.text) ?? 0.0,
    );

    // Verificamos si los valores numéricos son correctos
    if (producto.stockActual < 0 ||
        (producto.stockMinimo != null && producto.stockMinimo! < 0) ||
        (producto.stockMaximo != null && producto.stockMaximo! < 0) ||
        producto.precioProducto < 0) {
      _showErrorDialog('Ingrese valores numéricos válidos en stock y precio.');
      return false;
    }

    // Verificamos que el stock mínimo no sea mayor que el máximo
    if (producto.stockMinimo != null &&
        producto.stockMaximo != null &&
        producto.stockMinimo! > producto.stockMaximo!) {
      _showErrorDialog('El stock mínimo no puede ser mayor que el máximo.');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar'),
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
        Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: categorias.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.value),
              selected: _idCategoriasSeleccionadas.contains(entry.key),
              onSelected: (selected) {
                setState(() {
                  selected
                      ? _idCategoriasSeleccionadas.add(entry.key)
                      : _idCategoriasSeleccionadas.remove(entry.key);
                });
              },
            );
          }).toList(),
        ),
        TextButton(
          onPressed: _showAddCategoryDialog,
          child: Text('Agregar nueva categoría'),
        ),
      ],
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
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: _idUnidadSeleccionada != -1 ? _idUnidadSeleccionada : null,
        items: unidades.entries
            .map((entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _idUnidadSeleccionada = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Unidad de medida',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Producto')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('lib/assets/iconos/iconoImagen.png', height: 80),
              SizedBox(height: 10),
              Text('Código del producto',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(productCodeController.text,
                      style: TextStyle(fontSize: 24)),
                  SizedBox(width: 10),
                  Image.asset('lib/assets/iconos/iconoBarras.png', height: 40),
                ],
              ),
              SizedBox(height: 10),
              _buildCategorySelection(),
              _buildTextField('Nombre del producto', productNameController,
                  TextInputType.text),
              _buildDropdown(),
              _buildTextField(
                  'Stock actual', stockController, TextInputType.number),
              _buildTextField(
                  'Stock mínimo', minStockController, TextInputType.number),
              _buildTextField(
                  'Stock máximo', maxStockController, TextInputType.number),
              _buildTextField('Precio por medida', priceController,
                  TextInputType.numberWithOptions(decimal: true)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: _showConfirmationDialog,
                    child: Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
