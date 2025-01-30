class Unidad {
  late int idUnidad;
  late String tipoUnidad;

  // Constructor
  Unidad({
    required this.idUnidad,
    required this.tipoUnidad,
  });

  // Getters
  int get getIdUnidad => idUnidad;
  String get getTipoUnidad => tipoUnidad;

  // Setters
  set setIdUnidad(int id) => idUnidad = id;
  set setTipoUnidad(String tipo) => tipoUnidad = tipo;
}
