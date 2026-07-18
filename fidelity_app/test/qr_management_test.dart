// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fidelity_app/features/business/qr_management/qr_management_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fidelity_app/core/config/supabase_config.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (_) {
      // Already initialized
    }
  });

  testWidgets('QRManagementScreen smoke test: loading -> empty state', (
    WidgetTester tester,
  ) async {
    // QRManagementScreen es un StatefulWidget plano (no Consumer), no necesita
    // ProviderScope ancestro.
    await tester.pumpWidget(
      const MaterialApp(
        home: QRManagementScreen(businessId: 'test-business-id'),
      ),
    );

    // _isLoading arranca en true: el primer pump debe mostrar el spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Sin backend conectado, _loadQRCodes() falla y cae al catch, que setea
    // _isLoading = false dejando _qrCodes vacío -> estado vacío.
    await tester.pumpAndSettle();

    expect(find.text('Sin códigos QR'), findsOneWidget);

    // El FAB solo se renderiza cuando !_isLoading && _qrCodes.isEmpty.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Generar mi QR'), findsOneWidget);
  });
}
