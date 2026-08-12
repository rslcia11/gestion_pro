import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/cards/my_cards_screen.dart';

void main() {
  group('CardsErrorState', () {
    testWidgets('renders the default plain-language message and a retry action', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardsErrorState(onRetry: () => retryCount++),
          ),
        ),
      );

      expect(
        find.text('No pudimos cargar tus tarjetas. Revisá tu conexión e intentá de nuevo.'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(retryCount, 1);
    });

    testWidgets('renders a custom message when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardsErrorState(
              message: 'mensaje de prueba',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('mensaje de prueba'), findsOneWidget);
    });
  });
}
