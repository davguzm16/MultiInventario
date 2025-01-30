import 'package:flutter/material.dart';
import 'package:multiinventario/pages/inventory_page.dart';
import 'package:multiinventario/pages/sales_page.dart';
import 'package:multiinventario/pages/reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectIndex = 0;

  final List<Widget> pages = [
    InventoryPage(),
    SalesPage(),
    ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectIndex,
        onTap: (index) {
          setState(() {
            selectIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "lib/assets/iconos/iconoInventario.png",
              width: 30,
              height: 30,
            ),
            label: "Inventario",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "lib/assets/iconos/iconoVentas.png",
              width: 30,
              height: 30,
            ),
            label: "Ventas",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "lib/assets/iconos/iconoReportes.png",
              width: 30,
              height: 30,
            ),
            label: "Reportes",
          ),
        ],
      ),
    );
  }
}
