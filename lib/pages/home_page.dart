// ignore_for_file: use_build_context_synchronously

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
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomNavigationBar(
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(color: Colors.black),
          unselectedLabelStyle: const TextStyle(color: Colors.black),
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.black,
          backgroundColor: const Color(0xFF493D9E),
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _goBranch,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset("lib/assets/iconos/iconoInventario.png",
                  width: 30, height: 30),
              label: "Inventario",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("lib/assets/iconos/iconoVentas.png",
                  width: 30, height: 30),
              label: "Ventas",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("lib/assets/iconos/iconoClientes.png",
                  width: 30, height: 30),
              label: "Clientes",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("lib/assets/iconos/iconoReportes.png",
                  width: 30, height: 30),
              label: "Reportes",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("lib/assets/iconos/iconoConfiguraciones.png",
                  width: 30, height: 30),
              label: "Configuraciones",
            ),
          ],
        ),
      ),
    );
  }
}
