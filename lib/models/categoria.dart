import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Categoria {
  int? idCategoria;
  String nombreCategoria;

  // Constructor
  Categoria({
    this.idCategoria,
    required this.nombreCategoria,
  });

  static Future<bool> crearCategoria(Categoria categoria) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert(
        'INSERT INTO Categorias (nombreCategoria) VALUES (?)',
        [categoria.nombreCategoria],
      );

      return result > 0;
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }

  static Future<void> crearCategoriasPorDefecto() async {
    if (await DatabaseController.tableHasData("Categorias")) return;

    List<Categoria> categorias = [
      Categoria(nombreCategoria: "Abarrotes"),
      Categoria(nombreCategoria: "Ferretería"),
      Categoria(nombreCategoria: "Útiles escolares"),
      Categoria(nombreCategoria: "Bebidas"),
      Categoria(nombreCategoria: "Enlatados"),
    ];

    try {
      for (Categoria categoria in categorias) {
        crearCategoria(categoria);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<Categoria>> obtenerCategorias() async {
    List<Categoria> categorias = [];

    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db
          .rawQuery('SELECT idCategoria, nombreCategoria FROM Categorias');

      for (var map in result) {
        categorias.add(Categoria(
          idCategoria: map['idCategoria'],
          nombreCategoria: map['nombreCategoria'],
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener categorías: ${e.toString()}');
    }

    return categorias;
  }
}
