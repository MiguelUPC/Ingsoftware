import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String pacienteId;
  final String medicoId;
  final DateTime fecha;
  final String descripcion;
  final String estado;
  final double costo;
  final String pacienteNombre; // Nuevo campo agregado

  AppointmentModel({
    required this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.fecha,
    required this.descripcion,
    required this.estado,
    required this.costo,
    required this.pacienteNombre, // Incluimos el pacienteNombre en el constructor
  });

  // Modificamos la función factory para incluir paciente_nombre
  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      pacienteId: data['paciente_id'],
      medicoId: data['medico_id'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      descripcion: data['descripcion'],
      estado: data['estado'],
      costo: data['costo'],
      pacienteNombre: data['paciente_nombre'] ?? 'No disponible', // Asignamos paciente_nombre
    );
  }

  // Método adicional para cargar el nombre del paciente desde otra colección (por ejemplo, "users")
  static Future<String> getPacienteNombre(String pacienteId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(pacienteId).get();
      if (userSnapshot.exists) {
        return userSnapshot['nombre'] ?? 'Sin nombre';
      } else {
        return 'Paciente no encontrado';
      }
    } catch (e) {
      return 'Error al obtener nombre';
    }
  }
}
