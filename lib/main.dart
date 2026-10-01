import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary = Color(0xFF123C4A);
  static const green = Color(0xFF2AD08B);
  static const greenText = Color(0xFF117653);
  static const lightGreen = Color(0xFFE7FBF3);
  static const neutral = Color(0xFFF3F6F6);
  static const border = Color(0xFFE3EBE9);
  static const background = Color(0xFFFFFFFF);
  static const orange = Color(0xFFF47B20);
  static const orangeSoft = Color(0xFFFFF1E5);
  static const orangeText = Color(0xFF9B4513);
  static const white = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);
  static const headerSurface = Color(0xFFF3F6F6);
  static const headerDetail = Color(0xFF64748B);
}

enum OfferSortOrder { relevance, lowestPrice, highestPrice, nearest }

extension OfferSortOrderLabel on OfferSortOrder {
  String get label => switch (this) {
    OfferSortOrder.relevance => 'Relevância',
    OfferSortOrder.lowestPrice => 'Menor preço',
    OfferSortOrder.highestPrice => 'Maior preço',
    OfferSortOrder.nearest => 'Mais próximos',
  };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AchadosDoComercioApp());
}

class AchadosDoComercioApp extends StatelessWidget {
  const AchadosDoComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achados do Comércio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              secondary: AppColors.green,
              onSecondary: AppColors.white,
              secondaryContainer: AppColors.lightGreen,
              onSecondaryContainer: AppColors.primary,
              tertiary: AppColors.orange,
              onTertiary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.primary,
              onSurfaceVariant: AppColors.textSecondary,
            ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.lightGreen,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selecionado = states.contains(WidgetState.selected);
            return TextStyle(
              color: selecionado
                  ? AppColors.greenText
                  : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selecionado = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selecionado
                  ? AppColors.greenText
                  : AppColors.textSecondary,
              size: 21,
            );
          }),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.primary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELO DE DADOS
// -----------------------------------------------------------------------------
class Oferta {
  final String id;
  final String titulo;
  final String loja;
  final double precoOriginal;
  final double precoPromocional;
  final String categoria;
  final String imagemUrl;
  final String distancia;
  final String contatoWhatsapp;

  Oferta({
    required this.id,
    required this.titulo,
    required this.loja,
    required this.precoOriginal,
    required this.precoPromocional,
    required this.categoria,
    required this.imagemUrl,
    required this.distancia,
    required this.contatoWhatsapp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'loja': loja,
      'precoOriginal': precoOriginal,
      'precoPromocional': precoPromocional,
      'categoria': categoria,
      'imagemUrl': imagemUrl,
      'distancia': distancia,
      'contatoWhatsapp': contatoWhatsapp,
    };
  }

  factory Oferta.fromMap(Map<String, dynamic> map) {
    return Oferta(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      loja: map['loja'] ?? '',
      precoOriginal: (map['precoOriginal'] as num).toDouble(),
      precoPromocional: (map['precoPromocional'] as num).toDouble(),
      categoria: map['categoria'] ?? 'Geral',
      imagemUrl: map['imagemUrl'] ?? '',
      distancia: map['distancia'] ?? '0 km',
      contatoWhatsapp: map['contatoWhatsapp'] ?? '',
    );
  }
}

// -----------------------------------------------------------------------------
// SERVIÇO DE ARMAZENAMENTO LOCAL
// -----------------------------------------------------------------------------
class StorageService {
  static const String _keyOfertas = 'ofertas_locais_v1';

  static Future<void> salvarOfertas(List<Oferta> ofertas) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ofertasJson = ofertas
        .map((o) => jsonEncode(o.toMap()))
        .toList();
    await prefs.setStringList(_keyOfertas, ofertasJson);
  }

  static Future<List<Oferta>> carregarOfertas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ofertasJson = prefs.getStringList(_keyOfertas);

    if (ofertasJson == null) {
      return _getOfertasIniciais();
    }

    return ofertasJson.map((item) => Oferta.fromMap(jsonDecode(item))).toList();
  }

  static List<Oferta> _getOfertasIniciais() {
    return [
      Oferta(
        id: '1',
        titulo: 'Tênis Esportivo Corrida Tam 40',
        loja: 'Calçados Feira Central',
        precoOriginal: 299.90,
        precoPromocional: 149.90,
        categoria: 'Calçados',
        imagemUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&w=900&q=85',
        distancia: '0.8 km',
        contatoWhatsapp: '75999998888',
      ),
      Oferta(
        id: '2',
        titulo: 'Fone de Ouvido Bluetooth Sem Fio',
        loja: 'Tech Store Centro',
        precoOriginal: 120.00,
        precoPromocional: 69.90,
        categoria: 'Eletrônicos',
        imagemUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&w=900&q=85',
        distancia: '1.2 km',
        contatoWhatsapp: '75988887777',
      ),
      Oferta(
        id: '3',
        titulo: 'Jaqueta Jeans Masculina G',
        loja: 'Boutique do Bairro',
        precoOriginal: 180.00,
        precoPromocional: 99.00,
        categoria: 'Roupas',
        imagemUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&w=900&q=85',
        distancia: '2.5 km',
        contatoWhatsapp: '75977776666',
      ),
    ];
  }
}

// -----------------------------------------------------------------------------
// NAVEGAÇÃO
// -----------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _cadastroAberto = false;
  List<Oferta> _listaOfertas = [];
  final Set<String> _favoritosIds = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosStorage();
  }

  Future<void> _carregarDadosStorage() async {
    final ofertas = await StorageService.carregarOfertas();
    setState(() {
      _listaOfertas = ofertas;
      _carregando = false;
    });
  }

  Future<void> _adicionarNovaOferta(Oferta novaOferta) async {
    setState(() {
      _listaOfertas.insert(0, novaOferta);
    });
    await StorageService.salvarOfertas(_listaOfertas);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta cadastrada com sucesso!')),
      );
    }
  }

  Future<void> _concluirCadastro(Oferta novaOferta) async {
    await _adicionarNovaOferta(novaOferta);
    if (mounted) {
      setState(() => _cadastroAberto = false);
    }
  }

  Future<void> _removerOferta(Oferta oferta) async {
    setState(() {
      _listaOfertas.removeWhere((item) => item.id == oferta.id);
    });
    await StorageService.salvarOfertas(_listaOfertas);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Publicação excluída.')));
    }
  }

  void _alternarFavorito(String ofertaId) {
    setState(() {
      if (!_favoritosIds.add(ofertaId)) {
        _favoritosIds.remove(ofertaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Widget telaAtual = _cadastroAberto
        ? CadastroOfertaTab(
            onCadastrar: _concluirCadastro,
            onCancelar: () => setState(() => _cadastroAberto = false),
          )
        : switch (_currentIndex) {
            0 => FeedOfertasTab(
              ofertas: _listaOfertas,
              favoritosIds: _favoritosIds,
              onAlternarFavorito: _alternarFavorito,
              onViewProfile: () => setState(() => _currentIndex = 4),
            ),
            1 => FeedOfertasTab(
              ofertas: _listaOfertas,
              focusSearch: true,
              favoritosIds: _favoritosIds,
              onAlternarFavorito: _alternarFavorito,
              onViewProfile: () => setState(() => _currentIndex = 4),
            ),
            2 => FavoriteOffersTab(
              ofertas: _listaOfertas
                  .where((oferta) => _favoritosIds.contains(oferta.id))
                  .toList(),
              favoritosIds: _favoritosIds,
              onAlternarFavorito: _alternarFavorito,
            ),
            3 => const EmptyDestinationTab(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Seus interesses ficam por aqui',
              subtitle:
                  'Explore ofertas locais e fale diretamente com as lojas.',
            ),
            _ => PerfilTab(
              ofertas: _listaOfertas,
              onCreateOffer: () => setState(() => _cadastroAberto = true),
              onDeleteOffer: _removerOferta,
            ),
          };

    return Scaffold(
      body: telaAtual,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() {
          _cadastroAberto = false;
          _currentIndex = index;
        }),
        indicatorColor: AppColors.lightGreen,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Interesses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class EmptyDestinationTab extends StatelessWidget {
  const EmptyDestinationTab({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.greenText, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteOffersTab extends StatelessWidget {
  const FavoriteOffersTab({
    super.key,
    required this.ofertas,
    required this.favoritosIds,
    required this.onAlternarFavorito,
  });

  final List<Oferta> ofertas;
  final Set<String> favoritosIds;
  final ValueChanged<String> onAlternarFavorito;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ofertas.isEmpty
          ? const EmptyDestinationTab(
              icon: Icons.favorite_border_rounded,
              title: 'Seus favoritos ficam por aqui',
              subtitle: 'Salve ofertas para encontrá-las com facilidade.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: ofertas.length,
              itemBuilder: (context, index) => ItemCardOferta(
                oferta: ofertas[index],
                favorito: favoritosIds.contains(ofertas[index].id),
                onAlternarFavorito: () => onAlternarFavorito(ofertas[index].id),
              ),
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: FEED DE OFERTAS
// -----------------------------------------------------------------------------
class FeedOfertasTab extends StatefulWidget {
  final List<Oferta> ofertas;
  final Set<String> favoritosIds;
  final ValueChanged<String> onAlternarFavorito;
  final bool focusSearch;
  final VoidCallback? onViewProfile;

  const FeedOfertasTab({
    super.key,
    required this.ofertas,
    required this.favoritosIds,
    required this.onAlternarFavorito,
    this.focusSearch = false,
    this.onViewProfile,
  });

  @override
  State<FeedOfertasTab> createState() => _FeedOfertasTabState();
}

class _FeedOfertasTabState extends State<FeedOfertasTab> {
  String _filtroTexto = '';
  String _categoriaSelecionada = 'Todas';
  OfferSortOrder _ordenacaoSelecionada = OfferSortOrder.relevance;
  final FocusNode _campoBuscaFocusNode = FocusNode();

  @override
  void didUpdateWidget(covariant FeedOfertasTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusSearch != widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.focusSearch) {
          _campoBuscaFocusNode.requestFocus();
        } else {
          _campoBuscaFocusNode.unfocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _campoBuscaFocusNode.dispose();
    super.dispose();
  }

  static const List<String> _categorias = [
    'Todas',
    'Roupas',
    'Calçados',
    'Eletrônicos',
    'Informática',
    'Casa',
    'Beleza',
    'Móveis',
    'Utilidades',
  ];

  static const List<String> _categoriasHome = [
    'Roupas',
    'Calçados',
    'Eletrônicos',
    'Informática',
    'Casa',
    'Beleza',
    'Móveis',
    'Mais',
  ];

  static const Map<String, IconData> _iconesCategorias = {
    'Roupas': Icons.checkroom_outlined,
    'Calçados': Icons.directions_walk_outlined,
    'Eletrônicos': Icons.devices_other_outlined,
    'Informática': Icons.computer_outlined,
    'Casa': Icons.home_outlined,
    'Beleza': Icons.spa_outlined,
    'Móveis': Icons.chair_alt_outlined,
    'Mais': Icons.grid_view_outlined,
  };

  void _selecionarCategoria(String categoria) {
    if (categoria == 'Mais') {
      _abrirFiltros();
      return;
    }

    setState(() => _categoriaSelecionada = categoria);
  }

  void _abrirFiltros() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por categoria',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categorias.map((categoria) {
                  return ChoiceChip(
                    label: Text(categoria),
                    selected: categoria == _categoriaSelecionada,
                    selectedColor: AppColors.lightGreen,
                    onSelected: (_) {
                      setState(() => _categoriaSelecionada = categoria);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ordenarOfertas(List<Oferta> ofertas) {
    switch (_ordenacaoSelecionada) {
      case OfferSortOrder.relevance:
        break;
      case OfferSortOrder.lowestPrice:
        ofertas.sort(
          (a, b) => a.precoPromocional.compareTo(b.precoPromocional),
        );
      case OfferSortOrder.highestPrice:
        ofertas.sort(
          (a, b) => b.precoPromocional.compareTo(a.precoPromocional),
        );
      case OfferSortOrder.nearest:
        ofertas.sort(
          (a, b) =>
              _distanciaEmKm(a.distancia)
                  .compareTo(_distanciaEmKm(b.distancia)),
        );
    }
  }

  double _distanciaEmKm(String distancia) {
    final valorNumerico = distancia
        .toLowerCase()
        .replaceAll('km', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(valorNumerico) ?? double.infinity;
  }

  void _mostrarMapaEmBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A visualização no mapa estará disponível em breve.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ofertasFiltradas = widget.ofertas.where((oferta) {
      final bateNome =
          oferta.titulo.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
          oferta.loja.toLowerCase().contains(_filtroTexto.toLowerCase());
      final bateCategoria =
          _categoriaSelecionada == 'Todas' ||
          oferta.categoria == _categoriaSelecionada;
      return bateNome && bateCategoria;
    }).toList();
    _ordenarOfertas(ofertasFiltradas);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── CABEÇALHO ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo em círculo verde
                    Container(
                      key: const ValueKey('brand-logo'),
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        border: Border.all(color: AppColors.green, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F2AD08B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logoAchados.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nome do app + localização
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Achados do Comércio',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.green,
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                'Feira de Santana',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Ícones de ação
                    const SizedBox(width: 8),
                    if (widget.onViewProfile != null) ...[
                      _HeaderIconButton(
                        tooltip: 'Perfil',
                        icon: Icons.person_outline_rounded,
                        bgColor: AppColors.neutral,
                        onPressed: widget.onViewProfile!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _HeaderIconButton(
                      tooltip: 'Notificações',
                      icon: Icons.notifications_none_rounded,
                      bgColor: AppColors.lightGreen,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BARRA DE BUSCA ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      focusNode: _campoBuscaFocusNode,
                      onChanged: (val) => setState(() => _filtroTexto = val),
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'O que você está procurando?',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.green,
                          size: 22,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _abrirFiltros,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // ── CONTEÚDO ROLÁVEL ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NearbyProductsSectionHeader(
                    sortOrder: _ordenacaoSelecionada,
                    onSortChanged: (order) {
                      setState(() => _ordenacaoSelecionada = order);
                    },
                    onFilterPressed: _abrirFiltros,
                    onMapPressed: _mostrarMapaEmBreve,
                  ),
                  if (ofertasFiltradas.isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text('Nenhum achado encontrado no momento.'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 330,
                      child: ListView.separated(
                        key: const ValueKey('products-carousel'),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount: ofertasFiltradas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) => SizedBox(
                          width: 256,
                          child: ItemCardOferta(
                            oferta: ofertasFiltradas[index],
                            favorito: widget.favoritosIds.contains(
                              ofertasFiltradas[index].id,
                            ),
                            onAlternarFavorito: () => widget.onAlternarFavorito(
                              ofertasFiltradas[index].id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const NearbyStoresSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para ícones do cabeçalho
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.bgColor,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}

class NearbyProductsSectionHeader extends StatelessWidget {
  const NearbyProductsSectionHeader({
    super.key,
    required this.sortOrder,
    required this.onSortChanged,
    required this.onFilterPressed,
    required this.onMapPressed,
  });

  final OfferSortOrder sortOrder;
  final ValueChanged<OfferSortOrder> onSortChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onMapPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.greenText,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produtos perto de você',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lojas físicas da sua cidade.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Botões à direita
          OutlinedButton.icon(
            onPressed: onMapPressed,
            icon: const Icon(Icons.map_outlined, size: 14),
            label: const Text('Mapa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.greenText,
              side: const BorderSide(color: AppColors.green),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: const Size(0, 30),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 4),
          OfferSortMenu(
            selectedOrder: sortOrder,
            onSelected: onSortChanged,
          ),
        ],
      ),
    );
  }
}

class OfferSortMenu extends StatelessWidget {
  const OfferSortMenu({
    super.key,
    required this.selectedOrder,
    required this.onSelected,
  });

  final OfferSortOrder selectedOrder;
  final ValueChanged<OfferSortOrder> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OfferSortOrder>(
      tooltip: 'Ordenar: ${selectedOrder.label}',
      onSelected: onSelected,
      itemBuilder: (context) => OfferSortOrder.values
          .map(
            (order) => PopupMenuItem(
              value: order,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: order == selectedOrder
                        ? const Icon(Icons.check, color: AppColors.greenText)
                        : null,
                  ),
                  Text(order.label),
                ],
              ),
            ),
          )
          .toList(),
      child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
    );
  }
}

class NearbyStoresSection extends StatelessWidget {
  const NearbyStoresSection({super.key});

  static const lojas = [
    (
      nome: 'Moda Style',
      categoria: 'Roupas e acessórios',
      avaliacao: '4,8 (124)',
      distancia: '0,5 km',
      imagem: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&w=700&q=85',
    ),
    (
      nome: 'Sneakers Store',
      categoria: 'Calçados',
      avaliacao: '4,7 (98)',
      distancia: '1,2 km',
      imagem: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&w=700&q=85',
    ),
    (
      nome: 'Tech Store',
      categoria: 'Eletrônicos e informática',
      avaliacao: '4,6 (76)',
      distancia: '2,3 km',
      imagem: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&w=700&q=85',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lojas próximas',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Conheça o comércio da sua região.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 216,
          child: ListView.separated(
            key: const ValueKey('nearby-stores'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            scrollDirection: Axis.horizontal,
            itemCount: lojas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final loja = lojas[index];
              return SizedBox(
                width: 204,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.white,
                  surfaceTintColor: AppColors.white,
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: ColoredBox(
                          color: AppColors.neutral,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.network(
                              loja.imagem,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.storefront_outlined,
                                    color: AppColors.green,
                                    size: 32,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loja.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loja.categoria,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_outline_rounded,
                                  color: AppColors.orange,
                                  size: 15,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  loja.avaliacao,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.green,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  loja.distancia,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ItemCardOferta extends StatelessWidget {
  final Oferta oferta;
  final bool favorito;
  final VoidCallback onAlternarFavorito;

  const ItemCardOferta({
    super.key,
    required this.oferta,
    required this.favorito,
    required this.onAlternarFavorito,
  });

  Widget _imagemDoProduto() {
    Widget imagemIndisponivel() => const ColoredBox(
      color: AppColors.lightGreen,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary,
          size: 38,
        ),
      ),
    );

    final separadorData = oferta.imagemUrl.indexOf(',');
    if (oferta.imagemUrl.startsWith('data:image/') && separadorData > 0) {
      try {
        return Image.memory(
          base64Decode(oferta.imagemUrl.substring(separadorData + 1)),
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => imagemIndisponivel(),
        );
      } on FormatException {
        return imagemIndisponivel();
      }
    }

    if (oferta.imagemUrl.isEmpty) return imagemIndisponivel();

    return Image.network(
      oferta.imagemUrl,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => imagemIndisponivel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desconto =
        (((oferta.precoOriginal - oferta.precoPromocional) /
                    oferta.precoOriginal) *
                100)
            .round();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE7EEEB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do produto
          Stack(
            children: [
              SizedBox(
                height: 145,
                width: double.infinity,
                child: ColoredBox(
                  color: const Color(0xFFF8FAF9),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imagemDoProduto(),
                    ),
                  ),
                ),
              ),
              // Badge de desconto laranja
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-$desconto%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              // Botão favorito
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onAlternarFavorito,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      favorito
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: favorito
                          ? const Color(0xFFE53935)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Informações do produto
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oferta.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 13,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        oferta.loja,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      oferta.distancia,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                // Preços
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'De R\$ ${oferta.precoOriginal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'R\$ ${oferta.precoPromocional.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.greenText,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Botão de interesse
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Conectando ao WhatsApp da loja ${oferta.loja}...',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Tenho interesse',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: CADASTRO
// -----------------------------------------------------------------------------
class CadastroOfertaTab extends StatefulWidget {
  final Function(Oferta) onCadastrar;
  final VoidCallback onCancelar;

  const CadastroOfertaTab({
    super.key,
    required this.onCadastrar,
    required this.onCancelar,
  });

  @override
  State<CadastroOfertaTab> createState() => _CadastroOfertaTabState();
}

class _CadastroOfertaTabState extends State<CadastroOfertaTab> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _tituloController = TextEditingController();
  final _lojaController = TextEditingController();
  final _precoOriginalController = TextEditingController();
  final _precoPromocionalController = TextEditingController();
  final _whatsappController = TextEditingController();
  Uint8List? _imagemSelecionada;
  String _mimeTypeImagem = 'image/jpeg';

  String _categoriaSelecionada = 'Roupas';
  final List<String> _categorias = [
    'Roupas',
    'Calçados',
    'Eletrônicos',
    'Utilidades',
  ];

  Future<void> _selecionarImagem() async {
    try {
      final arquivo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (arquivo == null) return;

      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imagemSelecionada = bytes;
        _mimeTypeImagem = arquivo.mimeType ?? 'image/jpeg';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar essa imagem.')),
      );
    }
  }

  void _submeterFormulario() {
    if (_formKey.currentState!.validate()) {
      final novaOferta = Oferta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text,
        loja: _lojaController.text,
        precoOriginal: double.parse(_precoOriginalController.text),
        precoPromocional: double.parse(_precoPromocionalController.text),
        categoria: _categoriaSelecionada,
        imagemUrl: _imagemSelecionada == null
            ? ''
            : 'data:$_mimeTypeImagem;base64,${base64Encode(_imagemSelecionada!)}',
        distancia: '0.5 km',
        contatoWhatsapp: _whatsappController.text,
      );

      widget.onCadastrar(novaOferta);

      _tituloController.clear();
      _lojaController.clear();
      _precoOriginalController.clear();
      _precoPromocionalController.clear();
      _whatsappController.clear();
      setState(() => _imagemSelecionada = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: widget.onCancelar,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Cadastrar Novo Achado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título do Produto / Oferta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lojaController,
                decoration: const InputDecoration(
                  labelText: 'Nome da sua Loja',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a loja' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoOriginalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preço Original (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _precoPromocionalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preço Com Desconto (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _categoriaSelecionada = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Foto do produto',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selecionarImagem,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 176,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.green),
                  ),
                  child: _imagemSelecionada == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.green,
                              size: 34,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Adicionar foto do produto',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Image.memory(
                          _imagemSelecionada!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selecionarImagem,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _imagemSelecionada == null
                      ? 'Escolher imagem'
                      : 'Trocar imagem',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp para Contato',
                  border: OutlineInputBorder(),
                  hintText: '75999999999',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o WhatsApp'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submeterFormulario,
                icon: const Icon(Icons.check),
                label: const Text('Publicar Oferta e Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 3: PERFIL
// -----------------------------------------------------------------------------
class PerfilTab extends StatelessWidget {
  const PerfilTab({
    super.key,
    required this.ofertas,
    required this.onCreateOffer,
    required this.onDeleteOffer,
  });

  final List<Oferta> ofertas;
  final VoidCallback onCreateOffer;
  final Future<void> Function(Oferta) onDeleteOffer;

  Future<void> _confirmarExclusao(BuildContext context, Oferta oferta) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir publicação?'),
        content: Text('"${oferta.titulo}" será removido do aplicativo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await onDeleteOffer(oferta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.storefront_outlined, size: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lojista do Comércio Local',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Feira de Santana - BA',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: const Text('Publicar uma oferta'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onCreateOffer,
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar dados do estabelecimento'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Dados armazenados no LocalStorage'),
            subtitle: const Text('Comportamento offline ativo'),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Minhas publicações',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${ofertas.length}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (ofertas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Nenhuma publicação cadastrada.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...ofertas.map(
              (oferta) => Card(
                color: AppColors.white,
                surfaceTintColor: AppColors.white,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE7EEEB)),
                ),
                child: ListTile(
                  title: Text(
                    oferta.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${oferta.loja} · R\$ ${oferta.precoPromocional.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'Excluir publicação',
                    onPressed: () => _confirmarExclusao(context, oferta),
                    color: Theme.of(context).colorScheme.error,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
