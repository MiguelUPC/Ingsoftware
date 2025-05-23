import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _pacienteController = TextEditingController();
  final TextEditingController _medicoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? _pacienteNombre;
  String? _medicoNombre;
  bool _isLoadingPaciente = false;
  bool _isLoadingMedico = false;
  DateTime? _selectedDateTime;

  Future<void> _searchPaciente() async {
    setState(() => _isLoadingPaciente = true);

    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('identificacion', isEqualTo: _pacienteController.text)
        .get();

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _pacienteNombre = querySnapshot.docs[0]['nombre'];
      } else {
        _pacienteNombre = null;
      }
      _isLoadingPaciente = false;
    });
  }

  Future<void> _searchMedico() async {
    setState(() => _isLoadingMedico = true);

    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('identificacion', isEqualTo: _medicoController.text)
        .where('rol', isEqualTo: 'medico')
        .get();

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _medicoNombre = querySnapshot.docs[0]['nombre'];
      } else {
        _medicoNombre = null;
      }
      _isLoadingMedico = false;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addAppointment() async {
    if (_pacienteNombre != null && _medicoNombre != null && _selectedDateTime != null) {
      await _firestore.collection('appointments').add({
        'paciente_id': _pacienteController.text,
        'medico_id': _medicoController.text,
        'fecha': Timestamp.fromDate(_selectedDateTime!),
        'descripcion': _descripcionController.text,
        'estado': 'pendiente',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cita añadida con éxito')),
      );

      // Limpiar los datos
      setState(() {
        _pacienteController.clear();
        _medicoController.clear();
        _descripcionController.clear();
        _pacienteNombre = null;
        _medicoNombre = null;
        _selectedDateTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor complete todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Cita', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _pacienteController,
                labelText: 'ID del Paciente',
                icon: Icons.person,
                onChanged: (_) => _searchPaciente(),
              ),
              if (_isLoadingPaciente) CircularProgressIndicator(),
              if (_pacienteNombre != null)
                Text('Paciente: $_pacienteNombre', style: TextStyle(color: Colors.green))
              else if (_pacienteController.text.isNotEmpty && !_isLoadingPaciente)
                Text('Paciente no encontrado', style: TextStyle(color: Colors.red)),

              SizedBox(height: 20),
              _buildTextField(
                controller: _medicoController,
                labelText: 'ID del Médico',
                icon: Icons.local_hospital,
                onChanged: (_) => _searchMedico(),
              ),
              if (_isLoadingMedico) CircularProgressIndicator(),
              if (_medicoNombre != null)
                Text('Médico: $_medicoNombre', style: TextStyle(color: Colors.green))
              else if (_medicoController.text.isNotEmpty && !_isLoadingMedico)
                Text('Médico no encontrado', style: TextStyle(color: Colors.red)),

              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: TextEditingController(
                      text: _selectedDateTime == null
                          ? ''
                          : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
                    ),
                    labelText: 'Fecha y Hora de la Cita',
                    icon: Icons.calendar_today,
                    readOnly: true,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _descripcionController,
                labelText: 'Descripción',
                icon: Icons.notes,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAppointment,
                child: Text('Añadir Cita', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
