class Producto {
  late int idProducto;
  late int idUnidad;
  late String codigoProducto;
  late String nombreProducto;
  late double precioProducto;
  late double stockActual;
  late double stockMinimo;
  late double stockMaximo;
  late bool estaDisponible;
  late String rutaImagen;
  late DateTime fechaCreacion;
  late DateTime fechaModificacion;

  // Constructor
  Producto({
    required this.idProducto,
    required this.idUnidad,
    required this.codigoProducto,
    required this.nombreProducto,
    required this.precioProducto,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockMaximo,
    required this.estaDisponible,
    required this.rutaImagen,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  // Getters
  int get getIdProducto => idProducto;
  int get getIdUnidad => idUnidad;
  String get getCodigoProducto => codigoProducto;
  String get getNombreProducto => nombreProducto;
  double get getPrecioProducto => precioProducto;
  double get getStockActual => stockActual;
  double get getStockMinimo => stockMinimo;
  double get getStockMaximo => stockMaximo;
  bool get getEstaDisponible => estaDisponible;
  String get getRutaImagen => rutaImagen;
  DateTime get getFechaCreacion => fechaCreacion;
  DateTime get getFechaModificacion => fechaModificacion;

  // Setters
  set setIdProducto(int id) => idProducto = id;
  set setIdUnidad(int id) => idUnidad = id;
  set setCodigoProducto(String codigo) => codigoProducto = codigo;
  set setNombreProducto(String nombre) => nombreProducto = nombre;
  set setPrecioProducto(double precio) => precioProducto = precio;
  set setStockActual(double stock) => stockActual = stock;
  set setStockMinimo(double stock) => stockMinimo = stock;
  set setStockMaximo(double stock) => stockMaximo = stock;
  set setEstaDisponible(bool disponible) => estaDisponible = disponible;
  set setRutaImagen(String ruta) => rutaImagen = ruta;
  set setFechaCreacion(DateTime fecha) => fechaCreacion = fecha;
  set setFechaModificacion(DateTime fecha) => fechaModificacion = fecha;
}
