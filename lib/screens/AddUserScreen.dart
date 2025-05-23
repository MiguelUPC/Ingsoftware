import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  String _role = 'medico';
  String _identificacion = '';
  bool _activo = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nombre': _name,
          'email': _email,
          'telefono': _phone,
          'rol': _role,
          'activo': _activo,
          'fecha_creacion': Timestamp.now(),
          'identificacion': _identificacion,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario añadido correctamente')),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Añadir Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo Nombre
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor ingresa un correo válido';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Contraseña
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Teléfono
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un número de teléfono';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _phone = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Identificación
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Identificación',
                    prefixIcon: Icon(Icons.badge, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la identificación';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _identificacion = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Rol
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFE8F0FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: _role,
                  items: const [
                    DropdownMenuItem(
                      child: Text('Administrador'),
                      value: 'administrador',
                    ),
                    DropdownMenuItem(
                      child: Text('Médico'),
                      value: 'medico',
                    ),
                    DropdownMenuItem(
                      child: Text('Paciente'),
                      value: 'paciente',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Botón Añadir Usuario
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addUser,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: const Text('Añadir Usuario'),
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
        ),
      ),
    );
  }
}
