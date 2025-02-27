import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/categoria.dart';

class FilterProductPage extends StatefulWidget {
  final List<Categoria> categoriasSeleccionadas;
  final bool? stockBajo;

  const FilterProductPage({
    super.key,
    required this.categoriasSeleccionadas,
    required this.stockBajo,
  });

  @override
  State<FilterProductPage> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProductPage> {
  List<Categoria> categoriasObtenidas = [];
  List<Categoria> categoriasSeleccionadas = [];
  bool? stockBajo;
  bool habilitarStock = false;
  bool habilitarCategorias = false;

  @override
  void initState() {
    super.initState();
    categoriasSeleccionadas = List.from(widget.categoriasSeleccionadas);
    stockBajo = widget.stockBajo;
    habilitarStock = stockBajo != null;
    habilitarCategorias = categoriasSeleccionadas.isNotEmpty;
    obtenerCategorias();
  }

  Future<void> obtenerCategorias() async {
    final categorias = await Categoria.obtenerCategorias();
    setState(() {
      categoriasObtenidas = categorias;
    });
  }

  void aplicarFiltros() {
    context.pop({
      'categoriasSeleccionadas':
          habilitarCategorias ? categoriasSeleccionadas : [],
      'stockBajo': habilitarStock ? stockBajo : null,
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro de Categorías
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: const Text(
                              "Filtrar por Categorías",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Activa esta opción para seleccionar categorías específicas.",
                              style: TextStyle(color: Colors.black54),
                            ),
                            value: habilitarCategorias,
                            activeColor: const Color(0xFF2BBF55),
                            onChanged: (bool value) {
                              setState(() {
                                habilitarCategorias = value;
                                if (!value) {
                                  categoriasSeleccionadas.clear();
                                }
                              });
                            },
                          ),
                          if (habilitarCategorias)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categoriasObtenidas.map((categoria) {
                                final estaSeleccionada =
                                    categoriasSeleccionadas.any((c) =>
                                        c.idCategoria == categoria.idCategoria);

                                return FilterChip(
                                  label: Text(categoria.nombreCategoria),
                                  selected: estaSeleccionada,
                                  selectedColor: const Color(0xFF493D9E),
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: estaSeleccionada
                                        ? Colors.white
                                        : const Color(0xFF493D9E),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        categoriasSeleccionadas.add(categoria);
                                      } else {
                                        categoriasSeleccionadas.removeWhere(
                                            (c) =>
                                                c.idCategoria ==
                                                categoria.idCategoria);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filtro de stock bajo
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: const Text(
                              "Filtrar por Stock Bajo",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Activa esta opción para elegir si mostrar productos con stock bajo o normal.",
                              style: TextStyle(color: Colors.black54),
                            ),
                            value: habilitarStock,
                            activeColor: const Color(0xFF2BBF55),
                            onChanged: (bool value) {
                              setState(() {
                                habilitarStock = value;
                                stockBajo = value ? true : null;
                              });
                            },
                          ),
                          if (habilitarStock)
                            Column(
                              children: [
                                const Text(
                                  "¿Qué productos quieres ver?",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          stockBajo = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: stockBajo == true
                                            ? Colors.red
                                            : Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: Text(
                                        "Stock Bajo",
                                        style: TextStyle(
                                          color: stockBajo == true
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          stockBajo = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: stockBajo == false
                                            ? const Color(0xFF2BBF55)
                                            : Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: Text(
                                        "Stock Normal",
                                        style: TextStyle(
                                          color: stockBajo == false
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de aplicar filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF493D9E),
                ),
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: const Text(
                  "Aplicar Filtros",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: aplicarFiltros,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
