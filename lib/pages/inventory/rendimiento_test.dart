import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/lote.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:multiinventario/models/producto_categoria.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Para obtener información del dispositivo

class RendimientoTestPage extends StatefulWidget {
  const RendimientoTestPage({super.key});

  @override
  State<RendimientoTestPage> createState() => _RendimientoTestPageState();
}

final Random random = Random();

class _RendimientoTestPageState extends State<RendimientoTestPage> {
  bool isLoading = false;
  String mensaje = "Esperando prueba...";
  int cantidadProductos = 1000;
  double progreso = 0.0;
  TextEditingController cantidadController = TextEditingController();
  Map<String, dynamic> resultadosTest = {};

  Future<void> _probarCargaMasiva() async {
    setState(() {
      isLoading = true;
      mensaje = "Insertando $cantidadProductos productos y lotes...\n";
      progreso = 0.0;
    });

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      print("Obteniendo categorías...");
      List<Categoria> categorias = await Categoria.obtenerCategorias();
      if (categorias.isEmpty) {
        print("No hay categorías, creando categorías por defecto...");
        await Categoria.crearCategoriasPorDefecto();
        categorias = await Categoria.obtenerCategorias();
      }

      print("Obteniendo unidades...");
      List<Unidad> unidades = await Unidad.obtenerUnidades();

      for (int i = 0; i < cantidadProductos; i++) {
        String nombreUnico = "Producto Test $i";
        print("Procesando producto $nombreUnico...");

        try {
          List<Producto> productosExistentes = await Producto.obtenerProductosPorNombre(nombreUnico);
          if (productosExistentes.isNotEmpty) {
            print("Producto $nombreUnico ya existe, omitiendo...");
            continue;
          }

          Unidad unidadSeleccionada = unidades.isNotEmpty
              ? unidades[random.nextInt(unidades.length)]
              : Unidad(idUnidad: 1, tipoUnidad: "Unidad");

          Categoria categoriaSeleccionada = categorias[random.nextInt(categorias.length)];

          double stockMinimo = (random.nextInt(10) + 1).toDouble();
          double stockMaximo = (random.nextInt(50) + 10).toDouble();
          double precio = (random.nextDouble() * 100).toDouble();

          Producto producto = Producto(
            idUnidad: unidadSeleccionada.idUnidad,
            nombreProducto: nombreUnico,
            precioProducto: precio,
            stockMinimo: stockMinimo,
            stockMaximo: stockMaximo,
            rutaImagen: 'lib/assets/iconos/iconoImagen.png',
          );

          bool productoCreado = await Producto.crearProducto(producto, [categoriaSeleccionada]);

          if (productoCreado) {
            List<Producto> productosInsertados = await Producto.obtenerProductosPorNombre(nombreUnico);
            if (productosInsertados.isNotEmpty) {
              Producto productoInsertado = productosInsertados.first;

              await ProductoCategoria.asignarRelacion(productoInsertado.idProducto, categoriaSeleccionada.idCategoria);

              Lote lote = Lote(
                idProducto: productoInsertado.idProducto!,
                cantidadActual: (i + 1) * 2,
                cantidadComprada: (i + 1) * 2,
                cantidadPerdida: 0,
                precioCompra: precio,
                precioCompraUnidad: precio / (i + 1),
                fechaCompra: DateTime.now(),
                estaDisponible: true,
              );

              await Lote.crearLote(lote);
              print("Producto $nombreUnico y lote creados correctamente.");
            }
          }
        } catch (e) {
          print("Error en la inserción del producto $nombreUnico: $e");
          mensaje += "❌ Error en la inserción del producto $nombreUnico: $e\n";
        }

        setState(() {
          progreso = (i + 1) / cantidadProductos;
        });
      }

      stopwatch.stop();
      setState(() {
        isLoading = false;
        mensaje += "✅ Se insertaron $cantidadProductos productos y lotes en ${stopwatch.elapsedMilliseconds} ms\n";
        resultadosTest['insercion'] = stopwatch.elapsedMilliseconds;
      });
    } catch (e) {
      print("Error en la carga masiva: $e");
      setState(() {
        isLoading = false;
        mensaje += "❌ Error en la carga masiva: $e\n";
      });
    }
  }

  Future<void> _probarConsultaMasiva() async {
    setState(() {
      isLoading = true;
      mensaje = "Consultando productos y lotes...\n";
    });

    final Stopwatch stopwatch = Stopwatch()..start();
    List<Producto> productos = await Producto.obtenerProductosPorNombre("Producto Test");
    int totalLotes = 0;

    for (var producto in productos) {
      List<Lote> lotes = await Lote.obtenerLotesDeProducto(producto.idProducto!);
      totalLotes += lotes.length;
    }

    stopwatch.stop();
    setState(() {
      isLoading = false;
      mensaje += "🔍 Se consultaron ${productos.length} productos y $totalLotes lotes en ${stopwatch.elapsedMilliseconds} ms\n";
      resultadosTest['consulta'] = stopwatch.elapsedMilliseconds;
    });
  }

  Future<void> _borrarProductosTest() async {
    final stopwatch = Stopwatch();  // Asegúrate de crear el stopwatch

    setState(() {
      isLoading = true;
      mensaje = "Borrando productos y lotes de prueba...\n";
    });

    stopwatch.start();  // Inicia el cronómetro

    try {
      List<Producto> productos = await Producto.obtenerProductosPorNombre("Producto Test");
      print("Productos encontrados: ${productos.length}");

      if (productos.isEmpty) {
        setState(() {
          isLoading = false;
          mensaje += "⚠️ No se encontraron productos para borrar.\n";
        });
        return;
      }

      int totalProductosBorrados = 0;
      int totalLotesBorrados = 0;

      for (var producto in productos) {
        print("Borrando producto: ${producto.nombreProducto}");
        List<Lote> lotes = await Lote.obtenerLotesDeProducto(producto.idProducto!);
        print("Lotes encontrados para el producto: ${lotes.length}");

        for (var lote in lotes) {
          if (lote.idLote != null) {
            await Lote.eliminarLotePorId(lote.idLote!, lote.idProducto);
            totalLotesBorrados++;
            print("Lote borrado: ${lote.idLote}");
          }
        }

        await Producto.eliminarProductoDefinitivo(producto.idProducto!);
        totalProductosBorrados++;
        print("Producto borrado: ${producto.idProducto}");
      }

      setState(() {
        isLoading = false;
        mensaje += "🗑️ Se eliminaron $totalProductosBorrados productos y $totalLotesBorrados lotes de prueba.\n";
        resultadosTest['borrado'] = stopwatch.elapsedMilliseconds;
      });
    } catch (e) {
      print("Error al borrar productos y lotes: $e");
      setState(() {
        isLoading = false;
        mensaje += "❌ Error al borrar productos y lotes: $e\n";
      });
    } finally {
      stopwatch.stop();  // Detén el cronómetro cuando termine el proceso
    }
  }


  Future<void> _ejecutarTestCompleto() async {
    setState(() {
      resultadosTest.clear();
    });

    await _probarCargaMasiva();
    await _probarConsultaMasiva();
    await _borrarProductosTest();

    _mostrarResultadosTest();
  }

  Future<void> _mostrarResultadosTest() async {
    // Obtener información del dispositivo usando device_info_plus
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      mensaje += "\n📊 Resultados del Test:\n";
      mensaje += "Inserción: ${resultadosTest['insercion']} ms\n";
      mensaje += "Consulta: ${resultadosTest['consulta']} ms\n";
      mensaje += "Borrado: ${resultadosTest['borrado']} ms\n";

      mensaje += "\n💻 Información del Dispositivo:\n";
      mensaje += "Modelo: ${androidInfo.model}\n";
      mensaje += "Marca: ${androidInfo.manufacturer}\n";
      mensaje += "Versión de Android: ${androidInfo.version.release}\n";
      mensaje += "SDK: ${androidInfo.version.sdkInt}\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba de Rendimiento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna de botones
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: cantidadController,
                    decoration: const InputDecoration(labelText: "Número de Productos"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        cantidadProductos = int.tryParse(value) ?? 1000;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _probarCargaMasiva,
                    child: const Text("📤 Insertar Datos Masivos"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _probarConsultaMasiva,
                    child: const Text("🔍 Probar Consulta Masiva"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _borrarProductosTest,
                    child: const Text("🗑️ Borrar Datos de Prueba"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _ejecutarTestCompleto,
                    child: const Text("🚀 Ejecutar Test Completo"),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) LinearProgressIndicator(value: progreso),
                ],
              ),
            ),

            // Espaciado entre botones y consola
            const SizedBox(width: 20),

            // Consola de progreso
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    mensaje,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}