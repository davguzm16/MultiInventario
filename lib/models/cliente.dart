class Cliente {
  late int idCliente;
  late String nombreCliente;
  late String dniCliente;

  // Constructor
  Cliente({
    required this.idCliente,
    required this.nombreCliente,
    required this.dniCliente,
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
