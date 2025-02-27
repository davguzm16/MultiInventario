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
  bool habilitarFiltro = false;

  @override
  void initState() {
    super.initState();
    categoriasSeleccionadas = List.from(widget.categoriasSeleccionadas);
    stockBajo = widget.stockBajo;
    habilitarFiltro = stockBajo != null;
    debugPrint("Habilitar filtro: $habilitarFiltro, stockBajo: $stockBajo");
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
      'categoriasSeleccionadas': categoriasSeleccionadas,
      'stockBajo': stockBajo,
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
                color: Color(0xFF493D9E), // Morado
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriasObtenidas.map((categoria) {
                final estaSeleccionada = categoriasSeleccionadas
                    .any((c) => c.idCategoria == categoria.idCategoria);

                return FilterChip(
                  label: Text(categoria.nombreCategoria),
                  selected: estaSeleccionada,
                  selectedColor: const Color(0xFF493D9E), // Morado
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
                            (c) => c.idCategoria == categoria.idCategoria);
                      }
                    });
                  },
                );
              }).toList(),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: const Text(
                        "Activa esta opción para elegir si mostrar productos con stock bajo o normal.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      value: habilitarFiltro,
                      activeColor: const Color(0xFF2BBF55), // Verde
                      onChanged: (bool value) {
                        setState(() {
                          habilitarFiltro = value;
                          stockBajo = value
                              ? true
                              : null; // Si se desactiva, stockBajo es null
                        });
                      },
                    ),
                    if (habilitarFiltro)
                      Column(
                        children: [
                          const Text(
                            "¿Qué productos quieres ver?",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                      ? const Color(0xFF2BBF55)
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
                                      ? Colors.red
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

            const Spacer(),

            // Botón de aplicar filtro
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF493D9E), // Morado
                ),
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: const Text(
                  "Aplicar Filtros",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: aplicarFiltros,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
