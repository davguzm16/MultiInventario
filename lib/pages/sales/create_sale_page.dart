import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateSalePage(),
    );
  }
}

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  List<Product> cart = [
    Product(name: "Leche Gloria 360 g", price: 5.00, quantity: 2, discount: 0.00),
    Product(name: "Galletas Oreo", price: 3.50, quantity: 1, discount: 0.50),
    Product(name: "Coca Cola 500ml", price: 2.50, quantity: 3, discount: 0.00),
  ];

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onAdd: (product) {
          setState(() {
            cart.add(product);
          });
        },
      ),
    );
  }

  void _showEditProductDialog(int index) {
    Product product = cart[index];

    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onAdd: (editedProduct) {
          setState(() {
            cart[index] = editedProduct;
          });
        },
        initialProduct: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + (item.price * item.quantity - item.discount));

    return Scaffold(
      appBar: AppBar(title: Text("Crear Venta")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final product = cart[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          setState(() {
                            cart.removeAt(index);
                          });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Eliminar',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          _showEditProductDialog(index);
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'lib/assets/imagenes/logoTienda.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      "Precio: S/ ${product.price} \nCantidad: ${product.quantity} \nDescuento: S/ ${product.discount}",
                    ),
                    trailing: Text("Subtotal: S/ ${(product.price * product.quantity - product.discount).toStringAsFixed(2)}"),
                  ),
                );
              },
            ),
          ),
          Text("Total: S/ ${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddProductDialog,
              child: Text("Agregar Producto"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Confirmar", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Function(Product) onAdd;
  final Product? initialProduct;

  AddProductDialog({required this.onAdd, this.initialProduct});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late String selectedProduct;
  late double price;
  late int quantity;
  late double discount;

  @override
  void initState() {
    super.initState();
    selectedProduct = widget.initialProduct?.name ?? "Leche Gloria 360 g";
    price = widget.initialProduct?.price ?? 4.50;
    quantity = widget.initialProduct?.quantity ?? 1;
    discount = widget.initialProduct?.discount ?? 0.00;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialProduct == null ? "Agregar producto" : "Editar producto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedProduct, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Precio: S/ $price"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
              ),
              Text(quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(labelText: "Descuento (S/)"),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: discount.toString()),
            onChanged: (value) {
              setState(() {
                discount = double.tryParse(value) ?? 0.00;
              });
            },
          ),
          SizedBox(height: 10),
          Text("Total: S/ ${(price * quantity - discount).toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onAdd(Product(
              name: selectedProduct,
              price: price,
              quantity: quantity,
              discount: discount,
            ));
            Navigator.of(context).pop();
          },
          child: Text("Confirmar"),
        ),
      ],
    );
  }
}

class Product {
  final String name;
  final double price;
  final int quantity;
  final double discount;

  Product({
    required this.name,
    required this.price,
    required this.quantity,
    required this.discount,
  });
}