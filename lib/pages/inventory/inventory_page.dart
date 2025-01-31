import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorias"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Inventory Page"),
            ElevatedButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.inventoryCreateProduct);
              },
            )
          ],
        ),
      ),
    );
  }
}
