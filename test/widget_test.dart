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
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AchadosDoComercioApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('brand-logo')), findsOneWidget);
    expect(find.text('Feira de Santana'), findsOneWidget);
    expect(find.text('O que você está procurando?'), findsOneWidget);
    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
    expect(find.text('Produtos perto de você'), findsOneWidget);
    expect(
      find.text('Encontre em lojas físicas da sua cidade.'),
      findsOneWidget,
    );
    expect(find.text('Ver no mapa'), findsOneWidget);
    expect(find.byTooltip('Filtrar produtos'), findsOneWidget);
    final productsCarousel = tester.widget<ListView>(
      find.byKey(const ValueKey('products-carousel')),
    );
    expect(productsCarousel.scrollDirection, Axis.horizontal);
    expect(find.text('Lojas próximas'), findsOneWidget);
    expect(find.text('Moda Style'), findsOneWidget);
    expect(find.text('Tênis Esportivo Corrida Tam 40'), findsOneWidget);
    expect(find.text('Tenho interesse'), findsWidgets);
    expect(
      tester.getRect(find.text('Tenho interesse').first).bottom,
      lessThan(844 - 72),
    );
    final storesCarousel =
        tester.widget<ListView>(find.byKey(const ValueKey('nearby-stores')));
    expect(storesCarousel.scrollDirection, Axis.horizontal);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.fit == BoxFit.contain,
      ),
      findsWidgets,
    );
    for (final destination in [
      'Início',
      'Buscar',
      'Favoritos',
      'Meus interesses',
      'Perfil',
    ]) {
      expect(find.text(destination), findsOneWidget);
    }

    final categoryList = tester.widget<ListView>(
      find.byKey(const ValueKey('home-categories')),
    );
    expect(categoryList.scrollDirection, Axis.horizontal);
    for (final category in [
      'Roupas',
      'Calçados',
      'Eletrônicos',
      'Informática',
      'Casa',
      'Beleza',
      'Móveis',
      'Mais',
    ]) {
      if (category == 'Móveis') {
        await tester.drag(
          find.byKey(const ValueKey('home-categories')),
          const Offset(-260, 0),
        );
        await tester.pumpAndSettle();
      }
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-categories')),
          matching: find.text(category),
        ),
        findsOneWidget,
      );
    }
    await tester.drag(
      find.byKey(const ValueKey('home-categories')),
      const Offset(260, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ordenar: Relevância'));
    await tester.pumpAndSettle();
    expect(find.text('Mais próximos'), findsOneWidget);
    await tester.tap(find.text('Mais próximos'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ordenar: Mais próximos'), findsOneWidget);

    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    final campoBusca = tester.widget<TextField>(find.byType(TextField));
    expect(campoBusca.focusNode!.hasFocus, isTrue);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Seus favoritos ficam por aqui'), findsOneWidget);

    await tester.tap(find.text('Meus interesses'));
    await tester.pumpAndSettle();
    expect(find.text('Seus interesses ficam por aqui'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar uma oferta'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar Novo Achado'), findsOneWidget);
    expect(find.text('Foto do produto'), findsOneWidget);
    expect(find.text('Adicionar foto do produto'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('home-categories')),
        matching: find.text('Calçados'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tênis Esportivo Corrida Tam 40'), findsOneWidget);
    expect(find.text('Jaqueta Jeans Masculina G'), findsNothing);

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Filtrar por categoria'), findsOneWidget);
    expect(find.text('Eletrônicos'), findsWidgets);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, const Color(0xFF123C4A));
    expect(app.theme!.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    expect(app.theme!.colorScheme.secondary, const Color(0xFF2AD08B));
    expect(app.theme!.colorScheme.tertiary, const Color(0xFFF47B20));
  });

  test('persiste a imagem codificada junto da oferta', () async {
    SharedPreferences.setMockInitialValues({});
    const imagemDataUri = 'data:image/jpeg;base64,/9j/2Q==';
    final oferta = Oferta(
      id: 'teste-imagem',
      titulo: 'Produto com foto',
      loja: 'Loja Local',
      precoOriginal: 100,
      precoPromocional: 80,
      categoria: 'Roupas',
      imagemUrl: imagemDataUri,
      distancia: '0.5 km',
      contatoWhatsapp: '75999999999',
    );

    await StorageService.salvarOfertas([oferta]);
    final ofertasCarregadas = await StorageService.carregarOfertas();

    expect(ofertasCarregadas.single.imagemUrl, imagemDataUri);
  });

  testWidgets('adiciona uma oferta aos favoritos pela home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AchadosDoComercioApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar aos favoritos').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('Tênis Esportivo Corrida Tam 40'), findsOneWidget);
    await tester.tap(find.byTooltip('Remover dos favoritos').first);
    await tester.pumpAndSettle();
    expect(find.text('Seus favoritos ficam por aqui'), findsOneWidget);
  });

  testWidgets('exclui publicações do perfil e mantém a lista vazia', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AchadosDoComercioApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byTooltip('Excluir publicação').first);
      await tester.pumpAndSettle();
      expect(find.text('Excluir publicação?'), findsOneWidget);
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Nenhuma publicação cadastrada.'), findsOneWidget);
    expect(await StorageService.carregarOfertas(), isEmpty);
  });
}
