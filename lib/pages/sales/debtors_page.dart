import 'package:flutter/material.dart';

class DebtorsPage extends StatefulWidget {
  const DebtorsPage({super.key});

  @override
  DebtorsPageState createState() => DebtorsPageState();
}

class DebtorsPageState extends State<DebtorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deudores',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          DebtorCard(
            name: 'Luis Alfredo Muñoz',
            lastPurchase: '04/01/2025',
            totalAmount: 'S/150.00',
          ),
          DebtorCard(
            name: 'José Miguel Rodriguez',
            lastPurchase: '04/01/2025',
            totalAmount: 'S/150.00',
          ),
          DebtorCard(
            name: 'Alvaro Cencia Perez',
            lastPurchase: '04/01/2025',
            totalAmount: 'S/150.00',
          ),
          DebtorCard(
            name: 'Luis Cuadros',
            lastPurchase: '04/01/2025',
            totalAmount: 'S/150.00',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF493D9E),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Inventario'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class DebtorCard extends StatelessWidget {
  final String name;
  final String lastPurchase;
  final String totalAmount;

  DebtorCard(
      {required this.name,
      required this.lastPurchase,
      required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Última compra: $lastPurchase',
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 4),
            Text('Monto total: $totalAmount',
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF493D9E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DebtorDetailsPage(name: name)),
                  );
                },
                child:
                    Text('Más detalles', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebtorDetailsPage extends StatelessWidget {
  final String name;

  DebtorDetailsPage({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
            color:
                Colors.black), // Asegura que el ícono de la AppBar sea visible
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Deudas de productos de $name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
                child:
                    DebtsList()), // Use Expanded to ensure the list takes up available space
            SizedBox(height: 16),
            TotalDebt(),
          ],
        ),
      ),
    );
  }
}

class DebtsList extends StatelessWidget {
  final List<Map<String, dynamic>> debts = [
    {
      'date': '04/01/2025',
      'products': [
        {'product': 'Producto A', 'amount': 50.00},
        {'product': 'Producto B', 'amount': 75.00},
        {'product': 'Producto C', 'amount': 25.00},
      ]
    },
    {
      'date': '05/01/2025',
      'products': [
        {'product': 'Producto X', 'amount': 40.00},
        {'product': 'Producto Y', 'amount': 60.00},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: debts.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        thickness: 1,
        indent: 16.0,
        endIndent: 16.0,
      ),
      itemBuilder: (context, index) {
        var debt = debts[index];
        double totalDebt = 0.0;
        debt['products'].forEach((product) {
          totalDebt += product['amount'];
        });

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fecha: ${debt['date']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Column(
                  children: debt['products'].map<Widget>((product) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product['product'],
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'S/${product['amount'].toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total deuda:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/${totalDebt.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TotalDebt extends StatelessWidget {
  final List<Map<String, dynamic>> debts = [
    {
      'date': '04/01/2025',
      'products': [
        {'product': 'Producto A', 'amount': 50.00},
        {'product': 'Producto B', 'amount': 75.00},
        {'product': 'Producto C', 'amount': 25.00},
      ]
    },
    {
      'date': '05/01/2025',
      'products': [
        {'product': 'Producto X', 'amount': 40.00},
        {'product': 'Producto Y', 'amount': 60.00},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    double totalDebt = 0.0;
    debts.forEach((debt) {
      debt['products'].forEach((product) {
        totalDebt += product['amount'];
      });
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Total de deudas:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'S/${totalDebt.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
