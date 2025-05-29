import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/AddUserScreen.dart';

class AdminScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _anularFactura(String facturaId) async {
    await _firestore.collection('billing').doc(facturaId).update({
      'estado': 'anulada',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Fondo negro
        title: const Text(
          'Administración',
          style: TextStyle(color: Colors.white), // Texto blanco
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddUserScreen()),
              );
            },
            tooltip: 'Añadir Usuario',
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Fondo negro para toda la pantalla
        child: StreamBuilder(
          stream: _firestore.collection('billing').snapshots(),
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
                  color: Colors.grey[800], // Fondo gris para cada tarjeta
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Factura: ${factura.id}',
                      style: const TextStyle(color: Colors.white), // Texto blanco
                    ),
                    subtitle: Text(
                      'Estado: ${factura['estado']}',
                      style: const TextStyle(color: Colors.white70), // Texto gris claro
                    ),
                    trailing: factura['estado'] != 'anulada'
                        ? ElevatedButton(
                            onPressed: () {
                              _anularFactura(factura.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Factura anulada')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.red, // Texto blanco
                            ),
                            child: const Text('Anular Factura'),
                          )
                        : const Text(
                            'Anulada',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
