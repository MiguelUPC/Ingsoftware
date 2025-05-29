import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHistoriaClinicaScreen extends StatefulWidget {
  final String appointmentId; // ID de la cita a la que pertenece la historia clínica

  AddHistoriaClinicaScreen({required this.appointmentId, required pacienteId, required String citaId});

  @override
  _AddHistoriaClinicaScreenState createState() => _AddHistoriaClinicaScreenState();
}

class _AddHistoriaClinicaScreenState extends State<AddHistoriaClinicaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _isSaving = false; // Para indicar si se está guardando la historia clínica

  // Método para guardar la historia clínica en Firestore
  Future<void> _saveHistoriaClinica() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Obtén el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Crear un nuevo documento de historia clínica en Firestore
        await FirebaseFirestore.instance.collection('historias_clinicas').add({
          'appointment_id': widget.appointmentId, // Relacionar con la cita
          'medico_id': user.uid, // El médico que está ingresando la historia clínica
          'motivo': _motivoController.text,
          'diagnostico': _diagnosticoController.text,
          'tratamiento': _tratamientoController.text,
          'observaciones': _observacionesController.text,
          'fecha_creacion': FieldValue.serverTimestamp(), // Fecha de creación
        });

        // Confirmación de que se guardó correctamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historia clínica guardada exitosamente')),
        );

        // Regresar a la pantalla anterior
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error al guardar historia clínica: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la historia clínica')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Historia Clínica'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  key:const ValueKey('motivodeconsulta'),
                  controller: _motivoController,
                  decoration: InputDecoration(
                    labelText: 'Motivo de la consulta',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el motivo de la consulta';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  key:const ValueKey('diagnostico'),
                  controller: _diagnosticoController,
                  decoration: InputDecoration(
                    labelText: 'Diagnóstico',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el diagnóstico';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  key:const ValueKey('tratamiento'),
                  controller: _tratamientoController,
                  decoration: InputDecoration(
                    labelText: 'Tratamiento',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el tratamiento';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  key:const ValueKey('observaciones'),
                  controller: _observacionesController,
                  decoration: InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese las observaciones';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isSaving
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      key:const ValueKey('guardarhistclinica'),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _saveHistoriaClinica();
                          }
                        },
                        child: Text('Guardar Historia Clínica'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
