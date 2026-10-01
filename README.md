# 🛍️ Achados do Comércio

O **Achados do Comércio** é um aplicativo mobile desenvolvido em Flutter que tem como objetivo conectar consumidores a ofertas e promoções de lojas físicas de sua cidade, funcionando como um feed local de achados.

## 🎯 Objetivo

O objetivo principal deste projeto é criar uma plataforma simples e direta para impulsionar o comércio local. Muitas lojas físicas possuem excelentes ofertas que não chegam ao conhecimento de potenciais clientes nas proximidades. O Achados do Comércio preenche essa lacuna permitindo que lojistas divulguem promoções e consumidores descubram os melhores preços na sua região, com integração fácil via WhatsApp.

## 🏗️ Arquitetura e Tecnologias

O projeto foi construído utilizando **Flutter** e **Dart**, focado na simplicidade e na experiência do usuário. 

### Principais Componentes:
- **Interface e Navegação (UI/UX):** O layout é projetado seguindo as melhores práticas de Material Design, com um esquema de cores personalizado para transmitir uma sensação premium. A navegação ocorre por meio de um `NavigationBar` (abas) que gerencia as transições entre Feed, Busca, Favoritos e Perfil, todas controladas de forma centralizada pelo widget `MainNavigationScreen`.
- **Armazenamento de Dados:** Utiliza persistência local através do pacote `shared_preferences`. Todas as ofertas e configurações (incluindo imagens base64) são salvas diretamente no dispositivo, garantindo que o aplicativo funcione e preserve o estado do usuário mesmo após o fechamento.
- **Gerenciamento de Estado:** A aplicação utiliza os mecanismos nativos do Flutter (`setState` em `StatefulWidgets`) para controlar o estado da interface de usuário, filtros, ordenação e itens favoritados, mantendo o fluxo de dados simples e eficiente.
- **Manipulação de Mídia:** Faz uso do pacote `image_picker` para permitir que lojistas capturem imagens diretamente da câmera ou da galeria para o cadastro de novos "achados". As imagens são tratadas localmente.

## 🚀 Como Executar

1. Clone este repositório: `git clone https://github.com/brenoctorres-alt/Achados-do-Comercio.git`
2. Instale as dependências: `flutter pub get`
3. Execute o projeto: `flutter run`
