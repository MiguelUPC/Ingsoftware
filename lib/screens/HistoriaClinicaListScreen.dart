import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelo de Historia Clínica
class HistoriaClinicaModel {
  final String descripcion;
  final String estado;

  HistoriaClinicaModel({required this.descripcion, required this.estado});

  factory HistoriaClinicaModel.fromMap(Map<String, dynamic> map) {
    return HistoriaClinicaModel(
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'] ?? '',
    );
  }
}

// Servicio de Historia Clínica
class HistoriaClinicaService {
  // Obtener todas las historias clínicas (solo para médicos)
  Future<List<HistoriaClinicaModel>> obtenerTodasLasHistoriasClinicas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('historias_clinicas')
        .get();

    return snapshot.docs
        .map((doc) => HistoriaClinicaModel.fromMap(doc.data()))
        .toList();
  }

  // Obtener historias clínicas por identificación (para pacientes)
  Future<List<HistoriaClinicaModel>> obtenerHistoriasClinicasPorIdentificacion(
      String identificacion) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('historias_clinicas')
        .where('identificacion', isEqualTo: identificacion)
        .get();

    return snapshot.docs
        .map((doc) => HistoriaClinicaModel.fromMap(doc.data()))
        .toList();
  }
}

// Pantalla de lista de historias clínicas
class HistoriaClinicaListScreen extends StatelessWidget {
    final FirebaseAuth _auth = FirebaseAuth.instance;

  HistoriaClinicaListScreen({Key? key, required String pacienteId}) : super(key: key);

  Future<Map<String, dynamic>?> _obtenerDatosUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    return snapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historias Clínicas"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _obtenerDatosUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo obtener la información del usuario.'));
          }

          final userData = snapshot.data!;
          final rol = userData['rol'] ?? '';
          // ignore: unused_local_variable
          final userId = _auth.currentUser!.uid;

          // Instancia del servicio
          final historiaService = HistoriaClinicaService();

          // Determinar qué tipo de consulta hacer
          Future<List<HistoriaClinicaModel>> historiasFuture;

          if (rol == 'Médico') {
            historiasFuture = historiaService.obtenerTodasLasHistoriasClinicas();
          } else {
            final identificacion = userData['identificacion'];
            if (identificacion == null) {
              return const Center(child: Text('Identificación del paciente no encontrada.'));
            }
            historiasFuture = historiaService.obtenerHistoriasClinicasPorIdentificacion(identificacion);
          }

          return FutureBuilder<List<HistoriaClinicaModel>>(
            future: historiasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar las historias clínicas.'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay historias clínicas disponibles.'));
              }

              final historias = snapshot.data!;

              return ListView.builder(
                itemCount: historias.length,
                itemBuilder: (context, index) {
                  final historia = historias[index];
                  return ListTile(
                    title: Text('Historia Clínica: ${historia.descripcion}'),
                    subtitle: Text('Estado: ${historia.estado}'),
                    onTap: () {
                      // Aquí podrías navegar a los detalles de la historia
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
