import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersStream = _firestore.collection('users').snapshots();
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!.docs.where((user) {
            final userData = user.data() as Map<String, dynamic>;
            return userData['identificacion'].toString().contains(_searchQuery) ||
                userData['nombre'].toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;

              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 33, 150, 243),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    userData['nombre'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Text('Email: ${userData['email']}'),
                      Text('Teléfono: ${userData['telefono']}'),
                      Text('Rol: ${userData['rol']}'),
                      Text('Identificación: ${userData['identificacion']}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    key:const ValueKey('listaedityeliminar'),
                    onSelected: (value) {
                      if (value == 'Eliminar') {
                        _deleteUser(userId);
                      } else if (value == 'Editar') {
                        _showEditDialog(userId, userData);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(key:const ValueKey('editar'),value: 'Editar', child: Text('Editar')),
                      PopupMenuItem(key:const ValueKey('eliminar'),value: 'Eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
//agregar usuarios 
  void _showEditDialog(String userId, Map<String, dynamic> userData) {
    String newName = userData['nombre'];
    String newEmail = userData['email'];
    String newPhone = userData['telefono'];
    String newRole = userData['rol'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key:const ValueKey('editnombre'),
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  newName = value;
                },
                controller: TextEditingController(text: newName),
              ),
              TextField(
                key:const ValueKey('editemail'),
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  newEmail = value;
                },
                controller: TextEditingController(text: newEmail),
              ),
              TextField(
                key:const ValueKey('edittelefono'),
                decoration: InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) {
                  newPhone = value;
                },
                controller: TextEditingController(text: newPhone),
              ),
              DropdownButton<String>(
                key:const ValueKey('editmenurol'),
                value: newRole,
                items: [
                  DropdownMenuItem(key:const ValueKey('roladmin'),child: Text('Administrador'), value: 'administrador'),
                  DropdownMenuItem(key:const ValueKey('rolmedico'),child: Text('Médico'), value: 'medico'),
                  DropdownMenuItem(key:const ValueKey('rolpaciente'),child: Text('Paciente'), value: 'paciente')
                ],
                onChanged: (value) {
                  if (value != null) {
                    newRole = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              key:const ValueKey('actualizaredit'),
              onPressed: () {
                _updateUser(userId, {
                  'nombre': newName,
                  'email': newEmail,
                  'telefono': newPhone,
                  'rol': newRole,
                });
                Navigator.of(context).pop();
              },
              child: Text('Actualizar'),
            ),
            TextButton(
              key:const ValueKey('cancelaredit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
//filtrar usuarios
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buscar Usuario'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(labelText: 'Buscar por cédula o nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
