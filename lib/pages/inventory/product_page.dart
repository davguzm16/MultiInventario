import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del producto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Leche Gloria',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Código del producto
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Icon(Icons.image), // Icono de imagen
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Código del Producto:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('775642343'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock actual, mínimo y máximo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Stock actual: 10 ud'),
                    Text('Stock mínimo: 3 ud'),
                    Text('Stock máximo: 40 ud'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Unidad del producto:'),
                    Text('unidad (ud)'),
                    Text('Precio por unidad del producto: S/. 3.50'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categorías del producto
            const Text('Categorías del producto',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(
                    onPressed: () {}, child: const Text('Abarrotes')),
                ElevatedButton(
                    onPressed: () {}, child: const Text('Enlatados')),
              ],
            ),
            const SizedBox(height: 16),

            // Lotes del producto
            const Text('Lotes del producto',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DataTable(
              columns: const [
                DataColumn(label: Text('Lote')),
                DataColumn(label: Text('Cantidad')),
                DataColumn(label: Text('Pérdidas')),
                DataColumn(label: Text('Fecha de caducidad')),
                DataColumn(label: Text('Precio de compra')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('L001')),
                  DataCell(Text('8')),
                  DataCell(Text('2')),
                  DataCell(Text('23/02/25')),
                  DataCell(Text('X')),
                ]),
                DataRow(cells: [
                  DataCell(Text('L002')),
                  DataCell(Text('30')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ]),
                DataRow(cells: [
                  DataCell(Text('L003')),
                  DataCell(Text('20')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
