// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/business/qr_management/qr_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('QRManagementScreen smoke test: loading -> empty state', (
    WidgetTester tester,
  ) async {
    // QRManagementScreen es un StatefulWidget plano (no Consumer), no necesita
    // ProviderScope ancestro. Sin backend conectado, _loadQRCodes() resuelve
    // de forma síncrona (sin red real) dejando _qrCodes vacío -> estado vacío
    // directo, sin pasar por el spinner de carga.
    await tester.pumpWidget(
      const MaterialApp(
        home: QRManagementScreen(businessId: 'test-business-id'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin códigos QR'), findsOneWidget);

    // El FAB solo se renderiza cuando !_isLoading && _qrCodes.isEmpty.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Generar mi QR'), findsOneWidget);
  });
}
