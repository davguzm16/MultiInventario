import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/pages/inventory/inventory_page.dart';

void main() {
  testWidgets('Muestra el título de la página', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InventoryPage(),
    ));

    expect(find.text('Mis productos'), findsOneWidget);
  });

  testWidgets('Muestra un indicador de carga mientras se obtienen productos',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: InventoryPage(),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

  testWidgets('Muestra mensaje cuando no hay productos',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: InventoryPage(),
        ));

        await tester.pumpAndSettle();

        expect(find.text('No hay productos disponibles'), findsOneWidget);
      });

  testWidgets('Renderiza productos correctamente',
          (WidgetTester tester) async {
        List<Producto> productos = [
          Producto(
            idProducto: 1,
            nombreProducto: 'Producto 1',
            precioProducto: 10.0,
            stockActual: 5,
            stockMinimo: 2,
            stockMaximo: 20,
            idUnidad: 1,
            rutaImagen: 'lib/assets/iconos/iconoImagen.png',
          ),
        ];

        await tester.pumpWidget(MaterialApp(
          home: InventoryPage(),
        ));

        await tester.pumpAndSettle();

        expect(find.text('Producto 1'), findsOneWidget);
      });
}