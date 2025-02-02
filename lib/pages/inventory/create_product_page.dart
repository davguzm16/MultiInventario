import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
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

  String selectedUnit = 'kilogramo (kg)';
  List<String> categories = [
    'Abarrotes',
    'Ferretería',
    'Útiles escolares',
    'Bebidas',
    'Enlatados'
  ];
  List<String> selectedCategories = [];

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
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      setState(() {
        categories.add(newCategory);
        categoryController.clear();
      });
    }
    Navigator.of(context).pop();
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
              onPressed: () => Navigator.of(context).pop(),
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSuccessDialog();
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
    if (productNameController.text.isEmpty ||
        stockController.text.isEmpty ||
        minStockController.text.isEmpty ||
        maxStockController.text.isEmpty ||
        priceController.text.isEmpty) {
      _showErrorDialog('Todos los campos son obligatorios.');
      return false;
    }

    int? stock = int.tryParse(stockController.text);
    int? minStock = int.tryParse(minStockController.text);
    int? maxStock = int.tryParse(maxStockController.text);
    double? price = double.tryParse(priceController.text);

    if (stock == null ||
        minStock == null ||
        maxStock == null ||
        price == null) {
      _showErrorDialog('Ingrese valores numéricos válidos en stock y precio.');
      return false;
    }

    if (minStock > maxStock) {
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
          children: categories.map((category) {
            return ChoiceChip(
              label: Text(category),
              selected: selectedCategories.contains(category),
              onSelected: (selected) {
                setState(() {
                  selected
                      ? selectedCategories.add(category)
                      : selectedCategories.remove(category);
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
      child: DropdownButtonFormField<String>(
        value: selectedUnit,
        items: ['kilogramo (kg)', 'litro (l)', 'unidad (u)']
            .map((unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedUnit = value!;
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
              Image.asset('lib/assets/iconos/iconoImagen.png', height: 30),
              SizedBox(height: 10),
              Text('Código del producto',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(productCodeController.text,
                      style: TextStyle(fontSize: 24)),
                  SizedBox(width: 10),
                  Image.asset('lib/assets/iconos/iconoBarras.png', height: 30),
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
