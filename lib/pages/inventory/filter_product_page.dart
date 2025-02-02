import 'package:flutter/material.dart';

class FilterProductPage extends StatefulWidget {
  const FilterProductPage({super.key});

  @override
  State<FilterProductPage> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProductPage> {
  final List<String> categoriasProducto = [
    "Abarrotes", "Ferretería", "Útiles escolares",
    "Bebidas", "Enlatados", "Perecibles"
  ];

  final List<String> otrasCategorias = [
    "Los más vendidos", "Los menos vendidos", "Stock bajo", "Por caducar"
  ];

  List<String> selectedCategory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filtros",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Categorías del producto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            //Categorias principales
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriasProducto.map((categoria) {
                return FilterChip(
                  label: Text(categoria),
                  selected: selectedCategory.contains(categoria),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: selectedCategory.contains(categoria) ? Colors.white : Colors.purple,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if(selected){
                        selectedCategory.add(categoria);
                      }else{
                        selectedCategory.remove(categoria);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Otras categorías",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            //Otras Categorias
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: otrasCategorias.map((categoria) {
                return FilterChip(
                  label: Text(categoria),
                  selected: selectedCategory.contains(categoria),
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: selectedCategory.contains(categoria) ? Colors.white : Colors.purple,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if(selected){
                        selectedCategory.add(categoria);
                      }else{
                        selectedCategory.remove(categoria);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
