import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends StatefulWidget{
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}
class _PaymentPageState extends State<PaymentPage> {
  @override
  String metodoPago = "Al contado";
  double montoTotal = 12.30;
  double cantidadRecibida = 0.0;
  final TextEditingController _cantidadController = TextEditingController(text: "0.0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pago",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.add_circle_outline),
          SizedBox(width: 10),
          Icon(Icons.filter_list),
          SizedBox(width: 10),
          Icon(Icons.search),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        
        padding: const EdgeInsets.only(left: 40,top: 12, right: 40, bottom: 16),
          
          child:SingleChildScrollView(
            scrollDirection: Axis.vertical,
                    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cliente:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E))),
            const SizedBox(height: 8),
            _buildTextField("Nombre"),
            _buildTextField("Dni"),
            _buildTextField("Correo Electrónico"),
            
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPagoButton("Al contado"),
                const SizedBox(width: 10),
                _buildPagoButton("Crédito"),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text.rich(
              TextSpan(
                text: "Monto total: ",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E)),
                children: [
                  TextSpan(
                    text: "\$${montoTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),

            _buildTipoPago(metodoPago),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
                child: const Text("Confirmar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
          ) ,
          
        
        )

      );
    
  }


Widget _buildTipoPago(String metodoPago) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (metodoPago == 'Al contado') 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Cantidad recibida (S/)", onChanged: (value) {
              setState(() {
                cantidadRecibida = double.tryParse(value) ?? 0.0;
              });
            }, keyboardType: TextInputType.number),
            Text.rich(
              TextSpan(
                text: "Vuelto: ",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E)),
                children: [
                  TextSpan(
                    text: "\$${(cantidadRecibida - montoTotal).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      if (metodoPago == 'Crédito') 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cantidad recibida', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E)),  
            ),
            _buildTextField("Cantidad recibida (S/)", onChanged: (value) {
              setState(() {
                cantidadRecibida = double.tryParse(value) ?? 0.0;
              });
            }, controller: _cantidadController, keyboardType: TextInputType.number),
            Text.rich(
              TextSpan(
                text: "Por cancelar: ",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF493D9E)),
                children: [
                  TextSpan(
                    text: "\$${(montoTotal - cantidadRecibida).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
    ],
  );
}



  Widget _buildTextField(String label, {ValueChanged<String>? onChanged, TextEditingController? controller, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 45,
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFF493D9E))),
        ),
      ),
      ),
    );
  }

  Widget _buildPagoButton(String text) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: metodoPago == text ? Color(0xFF493D9E) : Colors.white,
        foregroundColor: metodoPago == text ? Colors.white : Color(0xFF493D9E),
        side: BorderSide(color: Color(0xFF493D9E)),
      ),
      onPressed: () {
        setState(() {
          metodoPago = text;
        });
      },
      child: Text(text),
    );
  }
}

