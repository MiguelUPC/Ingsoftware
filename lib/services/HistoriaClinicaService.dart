import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/models/HistoriaClinicaModel%20.dart';


class HistoriaClinicaService {
  // Agregar una nueva historia clínica
  Future<void> agregarHistoriaClinica(HistoriaClinicaModel historiaClinica) async {
    try {
      await historiaClinica.registrarHistoriaClinica();
    } catch (e) {
      throw Exception("Error al agregar la historia clínica: $e");
    }
  }

  // Actualizar una historia clínica existente
  Future<void> actualizarHistoriaClinica(String historiaId, String nuevaDescripcion, String medicoId, String citaId) async {
    try {
      HistoriaClinicaModel historia = await obtenerHistoriaClinicaPorId(historiaId);
      await historia.actualizarHistoriaClinica(nuevaDescripcion);
    } catch (e) {
      throw Exception("Error al actualizar la historia clínica: $e");
    }
  }

  // Obtener todas las historias clínicas para un paciente
  Future<List<HistoriaClinicaModel>> obtenerHistoriasClinicasPorPaciente(String pacienteId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historias_clinicas')
          .where('paciente_id', isEqualTo: pacienteId)
          .get();

      return snapshot.docs.map((doc) {
        return HistoriaClinicaModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Error al obtener las historias clínicas: $e");
    }
  }

  // Obtener todas las historias clínicas para un médico
  Future<List<HistoriaClinicaModel>> obtenerHistoriasClinicasPorMedico(String medicoId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historias_clinicas')
          .where('medico_id', isEqualTo: medicoId)
          .get();

      return snapshot.docs.map((doc) {
        return HistoriaClinicaModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Error al obtener las historias clínicas para el médico: $e");
    }
  }

  // Obtener una historia clínica por su ID
  Future<HistoriaClinicaModel> obtenerHistoriaClinicaPorId(String historiaId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('historias_clinicas').doc(historiaId).get();
      return HistoriaClinicaModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception("Error al obtener la historia clínica: $e");
    }
  }
}
