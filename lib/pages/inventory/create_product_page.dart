import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  // Controladores para los campos de texto
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();

  // Form key para validar el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo de nombre del producto
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Campo de precio del producto
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Campo de cantidad
              TextFormField(
                controller: _productQuantityController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.plus_one),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad de productos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Botón para guardar el producto
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Si el formulario es válido, muestra un mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Producto agregado')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
