class Lote {
  late int idLote;
  late int idProducto;
  late int cantidadAsignada;
  late double precioCompra;
  late DateTime fechaCaducidad;

  // Constructor
  Lote({
    required this.idLote,
    required this.idProducto,
    required this.cantidadAsignada,
    required this.precioCompra,
    required this.fechaCaducidad,
  });

  // Getters
  int get getIdLote => idLote;
  int get getIdProducto => idProducto;
  int get getCantidadAsignada => cantidadAsignada;
  double get getPrecioCompra => precioCompra;
  DateTime get getFechaCaducidad => fechaCaducidad;

  // Setters
  set setIdLote(int id) => idLote = id;
  set setIdProducto(int id) => idProducto = id;
  set setCantidadAsignada(int cantidad) => cantidadAsignada = cantidad;
  set setPrecioCompra(double precio) => precioCompra = precio;
  set setFechaCaducidad(DateTime fecha) => fechaCaducidad = fecha;
}
