import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicalife/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login y navegación a Home', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Ingresar credenciales
    await tester.enterText(find.byType(TextField).at(0), 'mangelruiz@unicesar.edu.co');
    await tester.enterText(find.byType(TextField).at(1), 'Prueba123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verificar que se navega a Home
    expect(find.textContaining('Bienvenido'), findsOneWidget);
  });

  testWidgets('Acceder a pantalla de usuarios', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Login
    await tester.enterText(find.byType(TextField).at(0), 'mangelruiz@unicesar.edu.co');
    await tester.enterText(find.byType(TextField).at(1), 'Prueba123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Abrir menú y navegar a administración
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administración'));
    await tester.pumpAndSettle();

    // Ir a Controlar Usuarios
    await tester.tap(find.text('Controlar Usuarios'));
    await tester.pumpAndSettle();

    expect(find.text('Administrar Usuarios'), findsOneWidget);
  });
}
