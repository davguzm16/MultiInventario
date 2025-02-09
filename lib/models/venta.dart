class Venta {
  int? idVenta;
  int idCliente;
  String codigoVenta;
  DateTime? fechaVenta;
  double montoTotal;
  double? montoCancelado;
  bool? esAlContado;

  // Constructor
  Venta({
    this.idVenta,
    required this.idCliente,
    required this.codigoVenta,
    this.fechaVenta,
    required this.montoTotal,
    this.montoCancelado,
    this.esAlContado,
  });
}
