import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multiinventario/models/notificacion.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  List<Notificacion> notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  void _cargarNotificaciones() async {
    List<Notificacion> notificaciones =
        await Notificacion.obtenerNotificaciones();
    setState(() {
      this.notificaciones = notificaciones;
    });
  }

  void _eliminarNotificacion(int idNotificacion) async {
    await Notificacion.eliminarNotificacion(idNotificacion);
    setState(() {
      notificaciones.removeWhere((n) => n.idNotificacion == idNotificacion);
    });
  }

  void _limpiarHistorial() async {
    await Notificacion.limpiarHistorial();
    setState(() {
      notificaciones.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: _limpiarHistorial,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: notificaciones.isEmpty
            ? const Center(
                child: Text(
                  'No se encontraron notificaciones',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = notificaciones[index];

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _eliminarNotificacion(
                              notificacion.idNotificacion!),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Eliminar',
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                            color: Color(0xFF493D9E), width: 1.5),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        title: Text(
                          notificacion.titulo,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            notificacion.contenido,
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 14),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF493D9E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notificacion.fecha.split('T')[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
