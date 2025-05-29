import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/home_screen.dart';

class AddBillingScreen extends StatefulWidget {
  @override
  _AddBillingScreenState createState() => _AddBillingScreenState();
}

class _AddBillingScreenState extends State<AddBillingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  List<DocumentSnapshot> _pacientesList = [];
  String? _selectedPacienteId;
  String? _selectedPacienteNombre;

  Future<void> _searchPaciente(String query) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('nombre', isGreaterThanOrEqualTo: query)
        .where('nombre', isLessThan: query + 'z')
        .get();

    setState(() {
      _pacientesList = querySnapshot.docs;
    });
  }

  Future<void> _addFactura() async {
    if (_selectedPacienteId != null) {
      await _firestore.collection('billing').add({
        'paciente_id': _selectedPacienteId,
        'monto': double.tryParse(_montoController.text) ?? 0.0,
        'fecha_emision': Timestamp.now(),
        'estado': 'pendiente',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura añadida')),
      );
      _identificacionController.clear();
      _montoController.clear();
      setState(() {
        _pacientesList.clear();
        _selectedPacienteId = null;
        _selectedPacienteNombre = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione un paciente antes de añadir la factura.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key:const ValueKey('añadirfacturabarra'),
        title: const Text('Añadir Factura', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          tooltip: 'Volver al Home',
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para buscar pacientes
            TextField(
              key:const ValueKey('buscarpacientefiltro'),
              controller: _identificacionController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Buscar Paciente',
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 33, 150, 243)),
                labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _searchPaciente(value),
            ),
            const SizedBox(height: 16),

            // Lista de pacientes
            if (_pacientesList.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: _pacientesList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        key:const ValueKey('nombrepaciente'),
                        leading: const Icon(Icons.person, color: Color.fromARGB(255, 33, 150, 243)),
                        title: Text(
                          _pacientesList[index]['nombre'],
                          style: const TextStyle(color: Colors.black),
                          
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPacienteId = _pacientesList[index]['identificacion'];
                            _selectedPacienteNombre = _pacientesList[index]['nombre'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Paciente seleccionado
            if (_selectedPacienteNombre != null) ...[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Paciente seleccionado: $_selectedPacienteNombre',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Campo para el monto
            TextField(
              key:const ValueKey('monto'),
              controller: _montoController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: const Icon(Icons.monetization_on, color: Color.fromARGB(255, 33, 150, 243)),
                labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Botón para añadir factura
            SizedBox(
              key:const ValueKey('añadirfactura'),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addFactura,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Añadir Factura'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
