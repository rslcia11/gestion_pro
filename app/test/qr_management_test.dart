// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/business/qr_management/qr_management_screen.dart';
import 'support/supabase_test_setup.dart';

void main() {
  setUpAll(() async {
    await initializeTestSupabase();
  });

  testWidgets('QRManagementScreen smoke test: loading -> empty state', (
    WidgetTester tester,
  ) async {
    // QRManagementScreen es un StatefulWidget plano (no Consumer), no necesita
    // ProviderScope ancestro. Supabase apunta a un localhost inalcanzable en
    // este entorno de test: _loadQRCodes() falla rápido ("connection
    // refused", no timeout) y su catch deja _qrCodes vacío -> estado vacío,
    // sin quedar colgado en el spinner de carga.
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
