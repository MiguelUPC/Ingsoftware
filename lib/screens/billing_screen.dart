import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/add_billing_screen.dart';
import 'package:medicalife/screens/home_screen.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedEstado = 'pendiente'; // Estado seleccionado por defecto

  Future<void> _actualizarFactura(String facturaId) async {
    await _firestore.collection('billing').doc(facturaId).update({
      'estado': 'pagada',
      'fecha_pago': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Fondo negro
        title: const Text(
          'Facturas',
          style: TextStyle(color: Colors.white), // Texto blanco
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          tooltip: 'Volver al Home',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddBillingScreen()),
              );
            },
            tooltip: 'Añadir Factura',
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Fondo negro para toda la pantalla
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                dropdownColor: Colors.white, // Fondo del menú desplegable
                value: selectedEstado,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEstado = newValue!;
                  });
                },
                items: <String>['pendiente', 'pagada', 'anulada']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black), // Texto azul
                    ),
                  );
                }).toList(),
                underline: Container(height: 2, color: Colors.green),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('billing')
                    .where('estado', isEqualTo: selectedEstado)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white), // Indicador blanco
                    );
                  }

                  final facturas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: facturas.length,
                    itemBuilder: (context, index) {
                      var factura = facturas[index];
                      return Card(
                        color: const Color.fromARGB(185, 225, 227, 230), // Fondo gris oscuro para las tarjetas
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            'Factura: ${factura.id}',
                            style: const TextStyle(color: Colors.black87), // Texto blanco
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estado: ${factura['estado']}',
                                style: const TextStyle(color: Colors.black), // Texto gris claro
                              ),
                              Text(
                                'Monto: \$${factura['monto'].toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          trailing: factura['estado'] == 'pendiente'
                              ? ElevatedButton(
                                  onPressed: () {
                                    _actualizarFactura(factura.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Factura actualizada a pagada'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Texto blanco
                                  ),
                                  child: const Text('Marcar como Pagada'),
                                )
                              : Text(
                                  factura['estado'] == 'pagada' ? 'Pagada' : 'Anulada',
                                  style: TextStyle(
                                    color: factura['estado'] == 'pagada'
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
