// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:achados_do_comercio/main.dart';

void main() {
  testWidgets('exibe a marca e aplica a cor principal', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AchadosDoComercioApp());
    await tester.pumpAndSettle();

    expect(find.text('Achados do Comércio'), findsOneWidget);
    expect(find.text('Encontre. Compare. Compre local.'), findsOneWidget);
    expect(find.text('Feira de Santana'), findsOneWidget);
    expect(find.text('Busque produtos, lojas ou categorias...'), findsOneWidget);
    expect(find.byTooltip('Notificações'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Filtrar por categoria'), findsOneWidget);
    expect(find.text('Eletrônicos'), findsWidgets);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, const Color(0xFF123C4A));
  });
}
