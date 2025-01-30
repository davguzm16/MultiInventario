class Categoria {
  late int idCategoria;
  late String nombreCategoria;
  late String rutaImagen;

  // Constructor
  Categoria({
    required this.idCategoria,
    required this.nombreCategoria,
    required this.rutaImagen,
  });

  // Getters
  int get getIdCategoria => idCategoria;
  String get getNombreCategoria => nombreCategoria;
  String get getRutaImagen => rutaImagen;

  // Setters
  set setIdCategoria(int id) => idCategoria = id;
  set setNombreCategoria(String nombre) => nombreCategoria = nombre;
  set setRutaImagen(String ruta) => rutaImagen = ruta;
}
