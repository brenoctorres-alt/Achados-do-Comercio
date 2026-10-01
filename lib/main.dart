import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary = Color(0xFF123C4A);
  static const green = Color(0xFF18A66A);
  static const lightGreen = Color(0xFFDFF4E9);
  static const background = Color(0xFFFFF8F0);
  static const orange = Color(0xFFF47B20);
  static const white = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);
  static const headerSurface = Color(0x1AFFFFFF);
  static const headerDetail = Color(0x66FFFFFF);
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.textSecondary,
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
      imagemUrl: map['imagemUrl'] ?? 'https://picsum.photos/300/200',
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

    if (ofertasJson == null || ofertasJson.isEmpty) {
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
        imagemUrl: 'https://picsum.photos/300/200?random=1',
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
        imagemUrl: 'https://picsum.photos/300/200?random=2',
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
        imagemUrl: 'https://picsum.photos/300/200?random=3',
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
  List<Oferta> _listaOfertas = [];
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

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> telas = [
      FeedOfertasTab(ofertas: _listaOfertas),
      CadastroOfertaTab(onCadastrar: _adicionarNovaOferta),
      const PerfilTab(),
    ];

    return Scaffold(
      body: telas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Minha Loja'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: FEED DE OFERTAS
// -----------------------------------------------------------------------------
class FeedOfertasTab extends StatefulWidget {
  final List<Oferta> ofertas;

  const FeedOfertasTab({super.key, required this.ofertas});

  @override
  State<FeedOfertasTab> createState() => _FeedOfertasTabState();
}

class _FeedOfertasTabState extends State<FeedOfertasTab> {
  String _filtroTexto = '';
  String _categoriaSelecionada = 'Todas';

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
    'Calçados': Icons.directions_walk,
    'Eletrônicos': Icons.devices_other,
    'Informática': Icons.computer_outlined,
    'Casa': Icons.home_outlined,
    'Beleza': Icons.face_retouching_natural,
    'Móveis': Icons.chair_alt_outlined,
    'Mais': Icons.grid_view_rounded,
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

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.white,
                                size: 26,
                              ),
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.orange,
                                  size: 15,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Achados do Comércio',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Encontre. Compare. Compre local.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.headerDetail,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Notificações',
                          onPressed: () {},
                          color: AppColors.white,
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none_rounded),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.headerSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.headerDetail),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.green,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SUA LOCALIZAÇÃO',
                                  style: TextStyle(
                                    color: AppColors.headerDetail,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Feira de Santana',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.location_city_outlined,
                            color: AppColors.headerDetail,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.storefront_outlined,
                            color: AppColors.headerDetail,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.expand_more,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextField(
                      onChanged: (val) => setState(() => _filtroTexto = val),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Busque produtos, lojas ou categorias...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton.filledTonal(
                    tooltip: 'Filtros',
                    onPressed: _abrirFiltros,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: Row(
              children: [
                Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 88,
            child: ListView.separated(
              key: const ValueKey('home-categories'),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categoriasHome.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = _categoriasHome[index];
                final categoriaExtra =
                    !_categoriasHome
                        .where((item) => item != 'Mais')
                        .contains(_categoriaSelecionada) &&
                    _categoriaSelecionada != 'Todas';
                final selecionada = categoria == 'Mais'
                    ? categoriaExtra
                    : categoria == _categoriaSelecionada;

                return SizedBox(
                  width: 72,
                  child: Semantics(
                    button: true,
                    selected: selecionada,
                    label: categoria,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _selecionarCategoria(categoria),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selecionada
                                  ? AppColors.green
                                  : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconesCategorias[categoria],
                              color: selecionada
                                  ? AppColors.white
                                  : AppColors.primary,
                              size: 23,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            categoria,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selecionada
                                  ? AppColors.green
                                  : AppColors.primary,
                              fontSize: 11,
                              fontWeight: selecionada
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ofertasFiltradas.isEmpty
                ? const Center(
                    child: Text('Nenhum achado encontrado no momento.'),
                  )
                : ListView.builder(
                    itemCount: ofertasFiltradas.length,
                    itemBuilder: (context, index) {
                      return ItemCardOferta(oferta: ofertasFiltradas[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ItemCardOferta extends StatelessWidget {
  final Oferta oferta;

  const ItemCardOferta({super.key, required this.oferta});

  @override
  Widget build(BuildContext context) {
    final desconto =
        (((oferta.precoOriginal - oferta.precoPromocional) /
                    oferta.precoOriginal) *
                100)
            .round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  oferta.imagemUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: AppColors.lightGreen,
                    child: const Icon(Icons.store, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-$desconto%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oferta.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      oferta.loja,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      oferta.distancia,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'De: R\$ ${oferta.precoOriginal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Por: R\$ ${oferta.precoPromocional.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Conectando ao WhatsApp da loja ${oferta.loja}...',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Tenho Interesse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
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

  const CadastroOfertaTab({super.key, required this.onCadastrar});

  @override
  State<CadastroOfertaTab> createState() => _CadastroOfertaTabState();
}

class _CadastroOfertaTabState extends State<CadastroOfertaTab> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _lojaController = TextEditingController();
  final _precoOriginalController = TextEditingController();
  final _precoPromocionalController = TextEditingController();
  final _whatsappController = TextEditingController();

  String _categoriaSelecionada = 'Roupas';
  final List<String> _categorias = [
    'Roupas',
    'Calçados',
    'Eletrônicos',
    'Utilidades',
  ];

  void _submeterFormulario() {
    if (_formKey.currentState!.validate()) {
      final novaOferta = Oferta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text,
        loja: _lojaController.text,
        precoOriginal: double.parse(_precoOriginalController.text),
        precoPromocional: double.parse(_precoPromocionalController.text),
        categoria: _categoriaSelecionada,
        imagemUrl:
            'https://picsum.photos/300/200?random=${DateTime.now().second}',
        distancia: '0.5 km',
        contatoWhatsapp: _whatsappController.text,
      );

      widget.onCadastrar(novaOferta);

      _tituloController.clear();
      _lojaController.clear();
      _precoOriginalController.clear();
      _precoPromocionalController.clear();
      _whatsappController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Novo Achado')),
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
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Loja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.storefront, size: 40),
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
              leading: const Icon(Icons.edit),
              title: const Text('Editar dados do estabelecimento'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Dados armazenados no LocalStorage'),
              subtitle: const Text('Comportamento offline ativo'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
