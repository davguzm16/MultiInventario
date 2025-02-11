class Cliente {
  int idCliente;
  String nombreCliente;
  String dniCliente;
  String? correoCliente;

  // Constructor
  Cliente({
    required this.idCliente,
    required this.nombreCliente,
    required this.dniCliente,
    required this.correoCliente,
  });

  // Getters
  int get getIdCliente => idCliente;
  String get getNombreCliente => nombreCliente;
  String get getDniCliente => dniCliente;

  // Setters
  set setIdCliente(int id) => idCliente = id;
  set setNombreCliente(String nombre) => nombreCliente = nombre;
  set setDniCliente(String dni) => dniCliente = dni;
}
