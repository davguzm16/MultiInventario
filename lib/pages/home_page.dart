import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          _goBranch(index);
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
