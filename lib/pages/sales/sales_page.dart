import 'package:flutter/material.dart';
import 'create_sale_page.dart'; // Importa la vista de creación de venta

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Ventas"),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Pequeña cruz para ir a CreateSalePage
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSalePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sales Page"),
          ],
        ),
      ),
    );
  }
}

