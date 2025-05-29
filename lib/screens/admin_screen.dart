import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/AddUserScreen.dart';
import 'package:medicalife/screens/UserManagementScreen.dart'; // Pantalla para controlar usuarios

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
        title: Text('Panel de Administración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // Fondo del AppBar
        leading: IconButton(
          key:const ValueKey('regresarcontx'),
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            
            key:const ValueKey('Añadirusuario'),
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserScreen()));
            },
            tooltip: 'Añadir Usuario',
          ),
        ],
      ),
      backgroundColor: Colors.white, // Fondo de la pantalla
      body: Column(
        children: [
          // Botón para controlar usuarios
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              key:const ValueKey('controlarusuaruios'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementScreen()),
                );
              },
              child: Text('Controlar Usuarios'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 67, 190, 43), // Texto blanco
              ),
            ),
          ),

          // Lista de facturas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('billing').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final facturas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: facturas.length,
                  itemBuilder: (context, index) {
                    var factura = facturas[index];
                    return Card(
                      color: const Color.fromARGB(202, 226, 222, 222), // Fondo gris de cada tarjeta
                      margin: EdgeInsets.all(8.0), // Espaciado entre tarjetas
                      child: ListTile(
                        title: Text('Factura: ${factura.id}', style: TextStyle(color: Colors.black)),
                        subtitle: Text('Estado: ${factura['estado']}', style: TextStyle(color: Colors.black)),
                        trailing: factura['estado'] != 'anulada'
                            ? ElevatedButton(
                              key:const ValueKey('anularfactura'),
                                onPressed: () {
                                  _anularFactura(factura.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Factura anulada')),
                                  );
                                },
                                child: Text('Anular Factura'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red, // Texto blanco
                                ),
                              )
                            : Text('Anulada', style: TextStyle(color: Colors.red)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
