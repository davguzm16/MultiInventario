import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final List<Map<String, dynamic>> products = List.generate(
    8,
    (index) => {
      'name': 'Leche Gloria',
      'price': 4.50,
      'stock': index % 3 == 0 ? 2 : 10,
      'image' : 'lib/assets/iconos/iconoImagen.png'
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {
            Navigator.pushNamed(context, AppRoutes.inventoryCreateProduct);
          }),
          IconButton(icon: Image.asset(
            "lib/assets/iconos/iconoFiltro.png",
            width: 30,
            height: 30,
            ),
             onPressed: () {
            Navigator.pushNamed(context, AppRoutes.inventoryFilterProduct);
          }),
          IconButton(icon: Image.asset(
            "lib/assets/iconos/iconoBusqueda.png",
            width: 23,
            height: 23,
          ), 
          onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.inventoryProduct); // Asegúrate de que la ruta esté definida en AppRoutes
              },
              //Productos
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(product['image'] ?? 'lib/assets/iconos/iconoImagen.png', 
                    height: 60,
                    alignment: Alignment.center,
                    ),
                    Text(product['name'], 
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    Text("Precio: S/. ${product['price'].toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    ),
                    Text(
                      "Stock actual: \n ${product['stock']} ud",
                      style: TextStyle(
                        color: product['stock'] <= 2 ? Colors.red : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}