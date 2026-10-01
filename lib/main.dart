import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722),
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFF2196F3),
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
    final List<String> ofertasJson =
        ofertas.map((o) => jsonEncode(o.toMap())).toList();
    await prefs.setStringList(_keyOfertas, ofertasJson);
  }

  static Future<List<Oferta>> carregarOfertas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ofertasJson = prefs.getStringList(_keyOfertas);

    if (ofertasJson == null || ofertasJson.isEmpty) {
      return _getOfertasIniciais();
    }

    return ofertasJson
        .map((item) => Oferta.fromMap(jsonDecode(item)))
        .toList();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Minha Loja',
          ),
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

  final List<String> _categorias = [
    'Todas',
    'Roupas',
    'Calçados',
    'Eletrônicos',
    'Utilidades'
  ];

  @override
  Widget build(BuildContext context) {
    final ofertasFiltradas = widget.ofertas.where((oferta) {
      final bateNome =
          oferta.titulo.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
              oferta.loja.toLowerCase().contains(_filtroTexto.toLowerCase());
      final bateCategoria = _categoriaSelecionada == 'Todas' ||
          oferta.categoria == _categoriaSelecionada;
      return bateNome && bateCategoria;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achados do Comércio 🛍️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => _filtroTexto = val),
              decoration: InputDecoration(
                hintText: 'Buscar produtos ou lojas na cidade...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final selecionada = cat == _categoriaSelecionada;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selecionada,
                    onSelected: (bool value) {
                      setState(() {
                        _categoriaSelecionada = cat;
                      });
                    },
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
    final desconto = (((oferta.precoOriginal - oferta.precoPromocional) /
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  oferta.imagemUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.store, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-$desconto%',
                    style: const TextStyle(
                      color: Colors.white,
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
                    const Icon(Icons.storefront, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      oferta.loja,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    Text(
                      oferta.distancia,
                      style: const TextStyle(color: Colors.grey),
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
                            color: Colors.grey,
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
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
    'Utilidades'
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
      appBar: AppBar(
        title: const Text('Cadastrar Novo Achado'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Obrigatório'
                          : null,
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Obrigatório'
                          : null,
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
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
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
                  foregroundColor: Colors.white,
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
      appBar: AppBar(
        title: const Text('Minha Loja'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
              style: TextStyle(color: Colors.grey),
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