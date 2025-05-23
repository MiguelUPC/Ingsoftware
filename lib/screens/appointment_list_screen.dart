import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalife/models/user_model.dart';
import 'package:medicalife/screens/appointment_screen.dart';
import 'package:medicalife/screens/home_screen.dart';
import 'package:medicalife/screens/add_historia_clinica_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  Future<void> _marcarCitaComoVista(String citaId) async {
    await _firestore.collection('appointments').doc(citaId).update({
      'estado': 'vista',
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Citas Médicas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          tooltip: 'Volver al Home',
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              UserModel currentUser = UserModel.fromFirestore(
                  snapshot.data!.data() as Map<String, dynamic>,
                  snapshot.data!.id);

              return currentUser.rol != 'Paciente'
                  ? IconButton(
                      icon: const Icon(Icons.event_note, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AppointmentScreen()));
                      },
                      tooltip: 'Añadir Cita',
                    )
                  : SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por fecha, descripción o paciente ID',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('appointments').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final citas = snapshot.data!.docs.where((cita) {
                  final pacienteId =
                      cita['paciente_id'].toString().toLowerCase();
                  final descripcion =
                      cita['descripcion'].toString().toLowerCase();
                  final fecha = DateFormat('dd/MM/yyyy')
                      .format(cita['fecha'].toDate())
                      .toLowerCase();

                  return pacienteId.contains(searchQuery) ||
                      descripcion.contains(searchQuery) ||
                      fecha.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    var cita = citas[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paciente: ${cita['paciente_id']}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Descripción: ${cita['descripcion']}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(cita['fecha'].toDate())}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Estado: ${cita['estado']}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.green),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (cita['estado'] != 'vista')
                                  ElevatedButton(
                                    onPressed: () {
                                      _marcarCitaComoVista(cita.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Cita marcada como vista')),
                                      );
                                    },
                                    child: const Text('Marcar como Vista'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddHistoriaClinicaScreen(
                                          appointmentId: cita.id,
                                          pacienteId: cita['paciente_id'],
                                          citaId: cita.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Añadir Historia Clínica'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
