class Venta {
  late int idVenta;
  late int idCliente;
  late String codigoVenta;
  late double montoTotal;
  late DateTime fechaVenta;
  late bool estaCancelado;

  // Constructor
  Venta({
    required this.idVenta,
    required this.idCliente,
    required this.codigoVenta,
    required this.montoTotal,
    required this.fechaVenta,
    required this.estaCancelado,
  });

  // Getters
  int get getIdVenta => idVenta;
  int get getIdCliente => idCliente;
  String get getCodigoVenta => codigoVenta;
  double get getMontoTotal => montoTotal;
  DateTime get getFechaVenta => fechaVenta;
  bool get getEstaCancelado => estaCancelado;

  // Setters
  set setIdVenta(int id) => idVenta = id;
  set setIdCliente(int id) => idCliente = id;
  set setCodigoVenta(String codigo) => codigoVenta = codigo;
  set setMontoTotal(double monto) => montoTotal = monto;
  set setFechaVenta(DateTime fecha) => fechaVenta = fecha;
  set setEstaCancelado(bool cancelado) => estaCancelado = cancelado;
}
