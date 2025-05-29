import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicalife/screens/HistoriaClinicaListScreen.dart';
import 'package:medicalife/screens/admin_screen.dart';
import 'package:medicalife/screens/appointment_list_screen.dart';
import 'package:medicalife/screens/billing_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isAdmin = false;
  bool isMedico = false;
  bool isLoading = true;
  String userId = "";
  String pacienteId = "";

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        userId = user.uid;
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            final rol = userDoc['rol'];
            isAdmin = rol == 'administrador';
            isMedico = rol == 'medico';
            pacienteId = rol == 'paciente' ? user.uid : '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar roles: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a MedicalLife',  style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Usuario',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              key:const ValueKey('historiasclinicas'),
              leading: Icon(Icons.folder_open, color: Colors.white),
              title: Text('Historias Clínicas', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoriaClinicaListScreen(
                      pacienteId: isMedico || isAdmin ? '' : pacienteId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              key:const ValueKey('citasmedicas'),
              leading: Icon(Icons.calendar_month, color: Colors.white),
              title: Text('Citas Médicas', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentListScreen(),
                  ),
                );
              },
            ),
            if (isAdmin)
              ListTile(
                key:const ValueKey('administracion'),
                leading: Icon(Icons.admin_panel_settings, color: Colors.white),
                title: Text('Administración', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminScreen()),
                  );
                },
              ),
            if (isAdmin || isMedico)
              ListTile(
                key:const ValueKey('facturas'),
                leading: Icon(Icons.receipt, color: Colors.white),
                title: Text('Facturas', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BillingScreen()),
                  );
                },
              ),
            ListTile(
              key:const ValueKey('cerrarsesion'),
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
              onTap: () {
                _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  MenuOptionCard(
                    key:const ValueKey('hisclinicasmenu'),
                    icon: Icons.folder_open,
                    label: 'Historias Clínicas',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoriaClinicaListScreen(
                          pacienteId: isMedico || isAdmin ? '' : pacienteId,
                        ),
                      ),
                    ),
                  ),
                  MenuOptionCard(
                    key:const ValueKey('citasmedmenu'),
                    icon: Icons.calendar_month,
                    label: 'Citas Médicas',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentListScreen(),
                      ),
                    ),
                  ),
                  if (isAdmin)
                    MenuOptionCard(
                      key:const ValueKey('adminmenu'),
                      icon: Icons.admin_panel_settings,
                      label: 'Administración',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminScreen()),
                      ),
                    ),
                  if (isAdmin || isMedico)
                    MenuOptionCard(
                      key:const ValueKey('facturasmenu'),
                      icon: Icons.receipt,
                      label: 'Facturas',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BillingScreen()),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class MenuOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuOptionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.blue[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
