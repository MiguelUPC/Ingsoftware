import 'package:cloud_firestore/cloud_firestore.dart';

class HistoriaClinicaModel {
  final String id;                  // ID de la historia clínica
  final String citaId;              // ID de la cita relacionada
  final String medicoId;            // ID del médico que la registra
  final String pacienteId;          // ID del paciente
  final String descripcion;         // Descripción de la historia clínica
  final DateTime fechaRegistro;     // Fecha de registro
  final String estado;              // Estado de la historia clínica (pendiente, completada)
  final DateTime fechaUltimaActualizacion; // Fecha de la última actualización

  HistoriaClinicaModel({
    required this.id,
    required this.citaId,
    required this.medicoId,
    required this.pacienteId,
    required this.descripcion,
    required this.fechaRegistro,
    required this.estado,
    required this.fechaUltimaActualizacion,
  });

  factory HistoriaClinicaModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return HistoriaClinicaModel(
      id: documentId,
      citaId: data['cita_id'],
      medicoId: data['medico_id'],
      pacienteId: data['paciente_id'],
      descripcion: data['descripcion'],
      fechaRegistro: (data['fecha_registro'] as Timestamp).toDate(),
      estado: data['estado'],
      fechaUltimaActualizacion: (data['fecha_ultima_actualizacion'] as Timestamp).toDate(),
    );
  }

  static Future<bool> puedeModificarHistoria(String medicoId, String citaId) async {
    // Obtener la cita correspondiente para verificar que el médico es el asignado
    DocumentSnapshot citaSnapshot = await FirebaseFirestore.instance.collection('appointments').doc(citaId).get();
    if (citaSnapshot.exists) {
      String citaMedicoId = citaSnapshot['medico_id'];
      return citaMedicoId == medicoId; // Si el médico que consulta es el mismo que el asignado a la cita, puede modificar
    } else {
      return false; // No existe la cita
    }
  }

  Future<void> registrarHistoriaClinica() async {
    // Verificar que el médico está autorizado a registrar la historia
    bool puedeModificar = await puedeModificarHistoria(this.medicoId, this.citaId);
    if (puedeModificar) {
      await FirebaseFirestore.instance.collection('historias_clinicas').add({
        'cita_id': this.citaId,
        'medico_id': this.medicoId,
        'paciente_id': this.pacienteId,
        'descripcion': this.descripcion,
        'fecha_registro': Timestamp.fromDate(this.fechaRegistro),
        'estado': this.estado,
        'fecha_ultima_actualizacion': Timestamp.fromDate(DateTime.now()), // Fecha de actualización al momento del registro
      });
    } else {
      throw Exception("El médico no tiene permiso para modificar esta historia clínica.");
    }
  }

  Future<void> actualizarHistoriaClinica(String nuevaDescripcion) async {
    // Verificar que el médico está autorizado a actualizar la historia clínica
    bool puedeModificar = await puedeModificarHistoria(this.medicoId, this.citaId);
    if (puedeModificar) {
      await FirebaseFirestore.instance.collection('historias_clinicas').doc(this.id).update({
        'descripcion': nuevaDescripcion,
        'fecha_ultima_actualizacion': Timestamp.fromDate(DateTime.now()), // Actualiza la fecha de última modificación
      });
    } else {
      throw Exception("El médico no tiene permiso para modificar esta historia clínica.");
    }
  }
}
