import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:multiinventario/models/categoria.dart';

class ProductoCategoria{
  int idProducto;
  int idCategoria;

  ProductoCategoria({
    required this.idProducto,
    required this.idCategoria,
  });

  static Future<void> asignarRelacion(int idProducto, int idCategoria) async {
    try{
      final db = await DatabaseController().database;


      int result = await db.rawInsert(
        '''
          INSERT INTO ProductosCategorias (idProducto, idCategoria) VALUES (?,?)
        ''',[idProducto, idCategoria]);
        
      if (result > 0){
        debugPrint("Categoria $idCategoria relacionada con producto $idProducto");
      }

    }catch (e){
      debugPrint("Error al relacionar el producto $idProducto con sus categorias: ${e.toString()}");
    }
  }

  static Future<List<Categoria>> obtenerCategoriasDeProducto(int idProducto) async {
    List<Categoria> categorias = [];

    try {
      final db = await DatabaseController().database;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT c.idCategoria, c.nombre 
        FROM Categorias c
        INNER JOIN ProductosCategorias pc ON c.idCategoria = pc.idCategoria
        WHERE pc.idProducto = ?
        ''',
        [idProducto]
      );

      if (result.isNotEmpty) {
        for (var item in result) {
          categorias.add(Categoria(
            idCategoria: item['idCategoria']! as int,
            nombreCategoria: item['nombre']! as String,
          ));
        }
      } else {
        debugPrint('No se encontraron categorías para el producto $idProducto');
      }
    } catch (e) {
      debugPrint("Error al obtener las categorías del producto $idProducto: ${e.toString()}");
    }

    return categorias;
  }

}