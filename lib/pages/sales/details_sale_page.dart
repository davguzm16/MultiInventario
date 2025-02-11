import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';




class DetailsSalePage extends StatefulWidget {
  
  const DetailsSalePage({super.key});
  @override
  State<DetailsSalePage> createState() => _DetailsSalePageState();
}


class _DetailsSalePageState extends State<DetailsSalePage> {
  final List<DetallesVentas> item = [
    DetallesVentas(cantidadProducto: 1, subtotalProducto: 12.40, descuentoProducto: 0.30),
    DetallesVentas(cantidadProducto: 3, subtotalProducto: 4.50),
    DetallesVentas(cantidadProducto: 2, subtotalProducto: 11.50),
  ];
  bool descuento = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.print, size: 35,),
              onPressed: () {},
            ),
          ),
        ],
      ),


      body: Padding(
        padding: EdgeInsets.only(left:32.0, right: 32.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Código: 00000023', style: TextStyle(fontWeight: FontWeight.bold)),
            Text.rich(
              TextSpan(
                text: 'Código: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E),fontSize: 16),
                children: [
                  TextSpan(
                    text: '00000023',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            //Text('Cliente: Alvaro Cencia Perez', style: TextStyle(color: Colors.blue)),
            Text.rich(
              TextSpan(
                text: 'Cliente: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E), fontSize: 16),
                children: [
                  TextSpan(
                    text: 'Alvaro Cencia Perez',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            //Text('DNI: 71234561'),
            SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'DNI: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E), fontSize: 16),
                children: [
                  TextSpan(
                    text: '71234561',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            //Text('Fecha: 09/01/2025', style: TextStyle(color: Colors.blue)),
            SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Fecha: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E), fontSize: 16),
                children: [
                  TextSpan(
                    text: '09/01/2025',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            //Text('Hora: 08:05'),
            SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Hora: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E), fontSize: 16),
                children: [
                  TextSpan(
                    text: '08:05',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            //Text('Estado: Al contado', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Estado: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E), fontSize: 16 ),
                children: [
                  TextSpan(
                    text: 'Al contado',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 18),
                Text('Ud', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF493D9E))),
                SizedBox(width: 57),
                Text('Descripción',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF493D9E))),
                SizedBox(width: 48),
                Text('Precio',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF493D9E))),
                SizedBox(width: 13),
                Text('Subtotal',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF493D9E))),

              ],
            ),

            SizedBox(height: 5),
            

            //TABLA:
            Expanded(
              //por si la tabla es muy grande
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                
              child: Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), 
              border: Border.all(color: Color(0xFF493D9E), width: 1.5), 
               
              ),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(20),

              //Empieza la tabla

              child: Table(
                border: TableBorder(
                  verticalInside: BorderSide(width: 1.5, color: Color(0xFF493D9E)),
                ),

                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(0.5),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(0.6),
                  3: FlexColumnWidth(0.6),
                  },  
                children: [
                      ...item.expand((detalle) => [
      TableRow(
        children: [
          TableCell(child: Center(child: Text("${detalle.cantidadProducto} kg"))),
          TableCell(child: Center(child: Text('Arroz Mass'))), // Falta personalizar
          TableCell(child: Center(child: Text('${detalle.subtotalProducto.toStringAsFixed(2)}'))),
          TableCell(child: Center(child: Text('${detalle.subtotalProducto.toStringAsFixed(2)}'))),
        ],
      ),
      // Si hay un descuento, se agrega una fila adicional
      if (detalle.descuentoProducto != null)
        TableRow(
          children: [
            TableCell(child: Center(child: Text(''))),
            TableCell(child: Center(child: Text('Descuento Arroz Mass', textAlign: TextAlign.center))), // Falta personalizar
            TableCell(child: Center(child: Text(''))),
            TableCell(child: Center(child: Text('-${detalle.descuentoProducto!.toStringAsFixed(2)}'))),
          ],
        ),
    ]),
                ],
              ),

            ),
            ),
              ),
              ),

            SizedBox(height: 12),


            
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: 23.00',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF493D9E)),
              ),
            ),
          ],
        ),
      ),

    );
  }
  
}
class DetallesVentas{
  final int cantidadProducto;
  final double subtotalProducto; 
  final double? descuentoProducto;
  DetallesVentas({
    required this.cantidadProducto,
    required this.subtotalProducto,
    this.descuentoProducto,
  });
}

