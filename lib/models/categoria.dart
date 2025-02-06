import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Categoria {
  int? idCategoria;
  String nombreCategoria;
  String? rutaImagen;

  // Constructor
  Categoria({
    this.idCategoria,
    required this.nombreCategoria,
    this.rutaImagen,
  });

  static Future<bool> crearCategoria(Categoria categoria) async {
    late int result;

    try {
      final db = await DatabaseController().database;
      result = await db.rawInsert(
        'INSERT INTO Categorias (nombreCategoria, rutaImagen) VALUES (?, ?)',
        [categoria.nombreCategoria, categoria.rutaImagen],
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result > 0;
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
      final db = await DatabaseController().database;
      for (Categoria categoria in categorias) {
        await db.rawInsert(
          'INSERT INTO Categorias (nombreCategoria, rutaImagen) VALUES (?, ?)',
          [categoria.nombreCategoria, categoria.rutaImagen],
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<Categoria>> obtenerCategorias() async {
    List<Categoria> categorias = [];

    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
          'SELECT idCategoria, nombreCategoria, rutaImagen FROM Categorias');

      for (var map in result) {
        categorias.add(Categoria(
          idCategoria: map['idCategoria'],
          nombreCategoria: map['nombreCategoria'],
          rutaImagen: map['rutaImagen'],
        ));
      }
    } catch (e) {
      debugPrint('Error al obtener categorías: ${e.toString()}');
    }

    return categorias;
  }
}
