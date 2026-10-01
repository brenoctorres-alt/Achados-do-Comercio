# 🛍️ Achados do Comércio

Aplicativo mobile desenvolvido em **Flutter** como projeto acadêmico. A proposta é conectar consumidores a ofertas e promoções de lojas físicas da sua cidade, funcionando como um **feed local de achados**.

---

## 📋 Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Estrutura de Arquivos](#estrutura-de-arquivos)
- [Como Funciona a Navegação](#como-funciona-a-navegação)
- [Modelo de Dados](#modelo-de-dados)
- [Armazenamento Local e Imagens](#armazenamento-local-e-imagens)
- [Pacotes Utilizados](#pacotes-utilizados)
- [Como Rodar o Projeto](#como-rodar-o-projeto)

---

## Sobre o Projeto

O **Achados do Comércio** é um app Flutter de arquivo único (`lib/main.dart`) que simula uma plataforma onde:

- Lojas cadastram ofertas com foto, preço original, preço promocional e contato WhatsApp
- Consumidores visualizam as ofertas próximas, filtram por categoria e favoritam o que gostam
- Toda informação é salva **localmente no dispositivo** — sem necessidade de internet para dados cadastrados

---

## Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| 📋 Feed de Ofertas | Carrossel horizontal com cards de produtos em promoção |
| 🔍 Busca | Campo de pesquisa por nome do produto ou loja |
| 🏷️ Filtro por Categoria | Modal com categorias: Roupas, Calçados, Eletrônicos, Informática, Casa, Beleza, Móveis |
| ↕️ Ordenação | Por relevância, menor preço, maior preço ou mais próximo |
| ❤️ Favoritos | Salva ofertas favoritas durante a sessão |
| ➕ Cadastro de Oferta | Lojista preenche título, loja, preços, categoria, distância, WhatsApp e foto |
| 📷 Foto do Produto | Captura via câmera ou galeria usando `image_picker` |
| 🗑️ Exclusão de Oferta | Remoção de publicações na aba de Perfil |
| 💾 Persistência Local | Dados salvos em `SharedPreferences` — permanecem após fechar o app |
| 🏪 Lojas Próximas | Seção com cards de lojas da região |

---

## Estrutura de Arquivos

```
Achados-do-Comercio/
│
├── lib/
│   └── main.dart              ← TODO o código do app (único arquivo Dart)
│
├── assets/
│   └── images/
│       └── logoAchados.png    ← Logo do app (exibida no cabeçalho)
│
├── pubspec.yaml               ← Dependências e configuração de assets
├── analysis_options.yaml      ← Regras de lint
│
├── android/                   ← Configurações nativas Android
├── ios/                       ← Configurações nativas iOS
├── windows/                   ← Configurações nativas Windows
├── linux/                     ← Configurações nativas Linux
├── macos/                     ← Configurações nativas macOS
└── web/                       ← Configurações para Flutter Web
```

> **Arquivos relevantes do projeto são:**
> - `lib/main.dart` — contém toda a lógica e interface
> - `assets/images/logoAchados.png` — logo do aplicativo
> - `pubspec.yaml` — lista de dependências

---

## Como Funciona a Navegação

O app usa **navegação por abas** com um `NavigationBar` fixo no rodapé, gerenciado pelo widget `MainNavigationScreen`.

### Diagrama da Navegação

```
AchadosDoComercioApp (MaterialApp)
└── MainNavigationScreen (StatefulWidget)
    │
    ├── [0] Início       → FeedOfertasTab
    │                       ├── Cabeçalho (logo + localização + ícones)
    │                       ├── Barra de busca + botão filtro
    │                       ├── Seção "Produtos perto de você" (carrossel)
    │                       └── Seção "Lojas próximas"
    │
    ├── [1] Buscar       → FeedOfertasTab (com foco automático no campo de busca)
    │
    ├── [2] Favoritos    → FavoriteOffersTab
    │                       └── Lista das ofertas favoritadas
    │
    ├── [3] Interesses   → EmptyDestinationTab (tela placeholder)
    │
    ├── [4] Perfil       → PerfilTab
    │                       ├── Lista de ofertas cadastradas
    │                       └── Botão para nova oferta
    │
    └── [*] Cadastro     → CadastroOfertaTab (sobrepõe as abas ao clicar em "Nova oferta")
                            ├── Formulário completo
                            └── Seleção de foto (câmera ou galeria)
```

### Como o índice de aba é controlado

```dart
// Em _MainNavigationScreenState:
int _currentIndex = 0;  // controla qual aba está ativa

// O switch decide qual widget renderizar:
switch (_currentIndex) {
  0 => FeedOfertasTab(...)     // Início
  1 => FeedOfertasTab(focusSearch: true, ...)  // Buscar
  2 => FavoriteOffersTab(...)  // Favoritos
  3 => EmptyDestinationTab(...)// Interesses
  _ => PerfilTab(...)          // Perfil (índice 4)
}
```

O `_cadastroAberto` é um booleano separado: quando `true`, o widget de cadastro substitui qualquer aba ativa, sem alterar o `_currentIndex`.

---

## Modelo de Dados

A classe `Oferta` representa cada publicação no feed:

```dart
class Oferta {
  final String id;                 // Identificador único
  final String titulo;             // Nome do produto
  final String loja;               // Nome da loja
  final double precoOriginal;      // Preço antes da promoção
  final double precoPromocional;   // Preço com desconto
  final String categoria;          // Ex: "Roupas", "Eletrônicos"
  final String imagemUrl;          // URL da web OU base64 (foto local)
  final String distancia;          // Ex: "1.2 km"
  final String contatoWhatsapp;    // Número para contato
}
```

O percentual de desconto é calculado dinamicamente no `ItemCardOferta`:

```dart
final desconto = (((precoOriginal - precoPromocional) / precoOriginal) * 100).round();
// Ex: de R$ 299,90 por R$ 149,90 → "-50%"
```

---

## Armazenamento Local e Imagens

### Persistência das ofertas

O app utiliza o pacote `shared_preferences` para salvar e recuperar as ofertas entre sessões.

```
Fluxo de salvamento:
Usuário cadastra oferta
    ↓
Oferta.toMap() → converte para Map<String, dynamic>
    ↓
jsonEncode() → converte para String JSON
    ↓
SharedPreferences.setStringList('ofertas_locais_v1', [...])
    ↓
Dados gravados no armazenamento interno do dispositivo
```

```
Fluxo de carregamento (ao abrir o app):
SharedPreferences.getStringList('ofertas_locais_v1')
    ↓
Se null → carrega 3 ofertas de exemplo (dados iniciais)
Se não null → jsonDecode() + Oferta.fromMap() para cada item
    ↓
Lista exibida no FeedOfertasTab
```

### Como as imagens são armazenadas

O campo `imagemUrl` da `Oferta` suporta **dois formatos**:

| Tipo | Formato | Quando é usado |
|---|---|---|
| **URL da web** | `https://images.unsplash.com/...` | Nas 3 ofertas de exemplo iniciais |
| **Base64** | `data:image/jpeg;base64,/9j/4AAQ...` | Quando o usuário tira foto ou escolhe da galeria |

```
Quando o usuário seleciona uma foto:
image_picker captura a imagem
    ↓
Arquivo lido como bytes (Uint8List)
    ↓
base64Encode(bytes) → String base64
    ↓
Salvo no campo imagemUrl como "data:image/jpeg;base64,..."
    ↓
Salvo no SharedPreferences junto com a oferta
```

No widget `ItemCardOferta`, a imagem é exibida detectando o formato:

```dart
// Se começa com "data:image/" → usa Image.memory (base64)
// Se é URL http → usa Image.network
// Se está vazio → exibe ícone de imagem indisponível
```

### Logo do app

A logo `assets/images/logoAchados.png` é um **asset local** declarado no `pubspec.yaml` e carregada com `Image.asset()` no cabeçalho da tela inicial.

---

## Pacotes Utilizados

| Pacote | Versão | Finalidade |
|---|---|---|
| `shared_preferences` | ^2.2.2 | Salvar ofertas no armazenamento local do dispositivo |
| `image_picker` | ^1.2.3 | Capturar fotos pela câmera ou escolher da galeria |
| `cupertino_icons` | ^1.0.8 | Ícones no estilo iOS (opcional) |

---

## Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK instalado (`flutter --version`)
- Um emulador Android/iOS ou dispositivo físico conectado
- VS Code ou Android Studio

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/brenoctorres-alt/Achados-do-Comercio.git
cd Achados-do-Comercio

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run
```

> Para rodar no **Chrome** (Flutter Web): `flutter run -d chrome`
>
> Para rodar no **Windows**: `flutter run -d windows`

---

## 🎨 Paleta de Cores

| Nome | Cor | Hexadecimal |
|---|---|---|
| Primary (Azul-verde escuro) | 🟦 | `#123C4A` |
| Green (Verde principal) | 🟢 | `#2AD08B` |
| Green Text | 🌿 | `#117653` |
| Light Green (Fundo verde claro) | 💚 | `#E7FBF3` |
| Orange (Destaque de desconto) | 🟠 | `#F47B20` |
| Text Secondary | ⬜ | `#64748B` |

---

*Projeto desenvolvido para a disciplina de Desenvolvimento Mobile — Flutter*
