import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo blanco
      title: const Text(
        'Panel Médico',
        style: TextStyle(
          color: Colors.blue, // Texto azul
          fontSize: 20,
          fontWeight: FontWeight.bold, // Negrita
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.blue, // Color blanco para el icono
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }
}
