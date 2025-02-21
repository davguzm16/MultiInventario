import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';

class FilterProductPage extends StatefulWidget {
  final List<Categoria> categoriasSeleccionadas;
  final bool? isStockBajo;

  const FilterProductPage({
    super.key,
    required this.categoriasSeleccionadas,
    required this.isStockBajo,
  });

  @override
  State<FilterProductPage> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProductPage> {
  List<Categoria> categoriasObtenidas = [];
  List<Categoria> categoriasSeleccionadas = [];
  bool? isStockBajo;
  bool habilitarFiltro = false;

  @override
  void initState() {
    super.initState();
    categoriasSeleccionadas = List.from(widget.categoriasSeleccionadas);
    isStockBajo = widget.isStockBajo;
    habilitarFiltro = isStockBajo != null;
    obtenerCategorias();
  }

  Future<void> obtenerCategorias() async {
    final categorias = await Categoria.obtenerCategorias();

    setState(() {
      categoriasObtenidas = categorias;
    });

    debugPrint("Categorias obtenidas: ");
    for (var categoria in categoriasObtenidas) {
      debugPrint(categoria.toString());
    }

    debugPrint("Categorias seleccionadas: ");
    for (var categoria in categoriasSeleccionadas) {
      debugPrint(categoria.toString());
    }

    debugPrint("isStockBajo: $isStockBajo");
  }

  void aplicarFiltros() {
    debugPrint("Categorias seleccionadas nuevas: ");
    for (var categoria in categoriasSeleccionadas) {
      debugPrint(categoria.toString());
    }

    debugPrint("isStockBajo nuevo: $isStockBajo");

    context.pop({
      'categoriasSeleccionadas': categoriasSeleccionadas,
      'isStockBajo': isStockBajo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filtros",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: aplicarFiltros,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Categorías del producto",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriasObtenidas.map((categoria) {
                final estaSeleccionada = categoriasSeleccionadas
                    .any((c) => c.idCategoria == categoria.idCategoria);

                return FilterChip(
                  label: Text(categoria.nombreCategoria),
                  selected: estaSeleccionada,
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: estaSeleccionada ? Colors.white : Colors.purple,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        categoriasSeleccionadas.add(categoria);
                      } else {
                        categoriasSeleccionadas.removeWhere(
                            (c) => c.idCategoria == categoria.idCategoria);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Filtrar por Stock Bajo"),
              value: habilitarFiltro,
              onChanged: (bool value) {
                setState(() {
                  habilitarFiltro = value;
                  if (!habilitarFiltro) {
                    isStockBajo = null;
                  }
                });
              },
            ),
            if (habilitarFiltro)
              CheckboxListTile(
                title: const Text("Stock Bajo"),
                value: isStockBajo ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    isStockBajo = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
