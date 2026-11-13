<div align="center">
  <img src="app/assets/images/logo_escola.jpeg" alt="Brasão da Escola Dom Marcelo" width="112" />

  <h1>Jornal DM</h1>
  <p><strong>Informação que aproxima.</strong></p>
  <p>Portal de notícias da comunidade escolar, com painel administrativo e publicação de conteúdo.</p>

  <img src="https://img.shields.io/badge/Ruby-3.3.6-CC342D?style=flat-square&amp;logo=ruby&amp;logoColor=white" alt="Ruby 3.3.6" />
  <img src="https://img.shields.io/badge/Rails-8.1-CC0000?style=flat-square&amp;logo=rubyonrails&amp;logoColor=white" alt="Ruby on Rails 8.1" />
  <img src="https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?style=flat-square&amp;logo=tailwindcss&amp;logoColor=white" alt="Tailwind CSS 4" />
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&amp;logo=postgresql&amp;logoColor=white" alt="PostgreSQL 16" />
  <img src="https://img.shields.io/badge/Hotwire-Turbo_%2B_Stimulus-244E72?style=flat-square" alt="Hotwire: Turbo e Stimulus" />
</div>

---

**[Sobre](#sobre-o-projeto)** · **[Entregas](#o-que-foi-realizado)** · **[Tecnologias](#tecnologias)** · **[Executar](#executar-localmente)** · **[Estrutura](#estrutura-do-projeto)** · **[Testes](#testes-e-verificações)**

## Sobre o projeto

O **Jornal DM** é um portal para compartilhar notícias, projetos, eventos e conquistas da Escola Dom Marcelo. A aplicação reúne uma área pública de leitura e um ambiente restrito para a equipe responsável pelas publicações.

O projeto evoluiu de um protótipo em HTML, CSS e JavaScript, com dados no navegador, para uma aplicação **Ruby on Rails com PostgreSQL**. As páginas foram separadas por responsabilidade, o visual foi migrado para **Tailwind CSS** e o painel passou a trabalhar com autenticação e dados persistidos no servidor.

A identidade visual original foi preservada: paleta azul, tipografia, organização do dashboard e modos claro e escuro. O brasão da escola foi incorporado ao portal, ao login e à administração.

## O que foi realizado

### Portal de notícias

- Página inicial com manchete automática e últimas publicações.
- Páginas independentes para notícias, escola e agenda.
- Busca textual, filtros por categoria e paginação.
- Reportagens com endereço próprio, notícias relacionadas e compartilhamento pelo WhatsApp.
- Imagens de capa e apresentação adaptada a diferentes tamanhos de tela.

### Dashboard administrativo

- Restauração da estrutura visual original: barra superior, menu lateral, saudação e data.
- Indicadores de publicações, destaques e categorias em uso.
- Editor e publicações recentes reunidos na visão geral.
- Páginas próprias para criar, editar e gerenciar notícias.
- Salvamento de rascunhos, publicação e exclusão com confirmação.
- Pré-visualização do texto sem salvar ou publicar.
- Detecção de alterações simultâneas para evitar sobrescrever a edição de outra pessoa.

### Editor de texto

O painel utiliza **Trix**, com barra de ferramentas estilizada em Tailwind:

| Formatação | Organização | Edição |
| --- | --- | --- |
| Negrito, itálico e tachado | Títulos de seção | Desfazer e refazer |
| Links | Listas com marcadores e numeradas | Atalhos de teclado |
| Citações e blocos de código | Parágrafos | Contagem de palavras |

A formatação é preservada em rascunhos, na edição, na prévia e na reportagem publicada. Textos anteriores mantêm seu conteúdo e suas quebras de parágrafo.

### Backend e acesso

- Autenticação com **Devise** e senhas protegidas com **Argon2**.
- Acesso administrativo verificado no servidor, sem cadastro público.
- Sessões com expiração e bloqueio temporário após tentativas inválidas.
- Notícias e usuários persistidos no **PostgreSQL**.
- Capas gerenciadas pelo **Active Storage**, com validação de tipo e tamanho.
- Sanitização do conteúdo formatado e rejeição de textos vazios.
- Proteção dos rascunhos contra acesso pelas páginas públicas.

### Visual e organização

- Telas Rails estilizadas com **Tailwind CSS 4**, sem carregar o CSS legado.
- Cores, fontes e sombras centralizadas em tokens de tema.
- Layouts separados para portal, autenticação e administração.
- Componentes compartilhados por partials e helpers.
- Modo escuro com preferência visual salva no navegador.
- Brasão oficial aplicado ao cabeçalho, rodapé, login, painel e apresentação da escola.

## Tecnologias

| Camada | Tecnologia | Uso no projeto |
| --- | --- | --- |
| Linguagem | Ruby 3.3.6 | Regras e funcionamento da aplicação |
| Framework | Ruby on Rails 8.1 | Rotas, controllers, models e views |
| Banco de dados | PostgreSQL 16 | Persistência dos dados |
| Interface | ERB + Tailwind CSS 4 | Páginas, componentes e responsividade |
| Interações | Turbo + Stimulus | Navegação, tema e comportamento do editor |
| JavaScript | Importmap | Carregamento dos módulos sem um bundler JavaScript |
| Editor | Trix | Edição de conteúdo formatado |
| Autenticação | Devise + devise-argon2 | Login e proteção das senhas |
| Arquivos | Active Storage | Upload e armazenamento das capas |
| Assets e servidor | Propshaft + Puma | Entrega dos arquivos estáticos e execução do Rails |
| Infraestrutura Rails | Solid Cache, Solid Queue e Solid Cable | Adaptadores persistentes para cache, jobs e canais em produção |
| Ambiente local | Docker Compose + dotenv-rails | Banco isolado e configuração por ambiente |
| Qualidade | Minitest, RuboCop e Brakeman | Testes, padronização e análise estática |

O [Gemfile](Gemfile) reúne as dependências, e o [Gemfile.lock](Gemfile.lock) registra as versões resolvidas. A versão Rails atualmente fixada no lockfile é **8.1.4**, compatível com a faixa solicitada no Gemfile.

## Executar localmente

### Prévia já configurada neste ambiente

Com as dependências instaladas e o arquivo `.env` configurado:

```sh
bin/preview
```

| Acesso | Endereço |
| --- | --- |
| Portal | http://localhost:3001 |
| Painel administrativo | http://localhost:3001/admin |

O comando inicia o PostgreSQL isolado no Docker, prepara o banco, executa os seeds, compila o Tailwind e abre o Rails em `127.0.0.1:3001`. O banco usa a porta local `55433` na configuração da prévia e um volume próprio para preservar os dados.

As credenciais administrativas estão nas variáveis `ADMIN_EMAIL` e `ADMIN_PASSWORD` do arquivo local `.env`. Esse arquivo é ignorado pelo Git; as senhas não fazem parte da documentação.

### Primeira instalação

**Requisitos:** Ruby 3.3.6, Bundler, PostgreSQL 16 ou Docker com Compose. Para variantes de imagens, instale também a biblioteca `libvips`.

```sh
# Execute na raiz da aplicação, ao lado do Gemfile.
bundle install
cp .env.example .env
```

Edite o `.env` com a conexão do banco e os dados do primeiro administrador. Para usar o PostgreSQL isolado do Docker:

```dotenv
PGHOST=127.0.0.1
PGPORT=55433
PGUSER=jornal_dm
PGPASSWORD='DEFINA_UMA_SENHA_PARA_O_BANCO'
ADMIN_EMAIL=admin@jornaldm
ADMIN_PASSWORD='DEFINA_A_SENHA_DO_ADMINISTRADOR'
SEED_DEMO=true
```

Substitua os exemplos pelas credenciais desejadas e execute `bin/preview`. O administrador aceita senha a partir de **6 caracteres**. O seed cria a conta inicial e não altera contas existentes.

Com `SEED_DEMO=true`, notícias identificadas como demonstração são criadas para apresentar o portal. Elas podem ser editadas ou excluídas pelo painel.

### Desenvolvimento com PostgreSQL instalado

Configure no `.env` o host, a porta, o usuário e a senha do seu PostgreSQL. Em seguida:

```sh
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

O portal fica em http://localhost:3000. O `bin/dev` prepara o banco antes de iniciar o Rails e acompanha as alterações do Tailwind. O usuário PostgreSQL precisa ter permissão para criar os bancos de desenvolvimento e teste.

> Abrir o `index.html` do protótipo executa apenas a demonstração antiga. Para usar o backend, abra a aplicação pelo servidor Rails.

## Páginas disponíveis

| Página | Rota |
| --- | --- |
| Início | `/` |
| Notícias e busca | `/noticias` |
| Reportagem | `/noticias/:id` |
| Nossa escola | `/escola` |
| Agenda de eventos e avisos | `/agenda` |
| Login | `/acesso/sign_in` |
| Dashboard administrativo | `/admin` |
| Gestão de publicações | `/admin/articles` |
| Nova publicação | `/admin/articles/new` |
| Edição de publicação | `/admin/articles/:id/edit` |

## Estrutura do projeto

```text
app/
├── assets/
│   ├── images/             # Brasão da escola
│   └── tailwind/           # Tema e entrada do Tailwind
├── controllers/
│   ├── admin/              # Dashboard e gestão de notícias
│   └── users/              # Retornos dos provedores de autenticação
├── helpers/                # Formatação e classes compartilhadas
├── javascript/
│   └── controllers/        # Stimulus: tema e editor
├── models/                 # Usuários, notícias e validações
└── views/
    ├── admin/              # Dashboard, editor e publicações
    ├── articles/           # Listagem e leitura das notícias
    ├── devise/             # Login e recuperação de senha
    ├── layouts/            # Portal, autenticação e administração
    ├── pages/              # Início, escola e agenda
    └── shared/             # Cabeçalho, rodapé e logo
config/                     # Rotas, banco e serviços
db/                         # Migrations, schemas e seeds
docs/                       # Configuração e operação
test/                       # Testes de models e integração
compose.preview.yml         # PostgreSQL isolado para a prévia
Dockerfile                  # Preparação da aplicação para produção
```

O protótipo original permanece em `Jornal_DM_2.0_Completo/Jornal_DM_Front_Completo` como referência. Os dados antigos do `localStorage` não são importados automaticamente para o PostgreSQL.

## Testes e verificações

```sh
bin/rails test
bin/rails zeitwerk:check
bin/rails tailwindcss:build
bundle exec rubocop
bundle exec brakeman --no-threads --no-pager
bundle exec bundler-audit check --update
```

Na última execução registrada, a suíte passou com **17 testes e 147 verificações**, sem falhas. A cobertura inclui acesso administrativo, rascunhos privados, publicação, edição, prévia, busca, conflitos de edição e preservação do conteúdo formatado e dos textos antigos.

O projeto também possui um workflow de integração contínua no GitHub com PostgreSQL, testes e análises. A auditoria atualizada das gems depende de acesso à internet; ela não foi concluída no ambiente utilizado. A interação visual do editor não foi validada por teste automatizado em navegador.

## Integrações e produção

A aplicação possui configuração para **Google/Facebook via OmniAuth**, **e-mail via SMTP** e **armazenamento S3**. Esses recursos precisam das respectivas credenciais para serem ativados; não são necessários para visualizar o portal localmente.

Dockerfile, adaptadores Solid e a gem Kamal estão disponíveis para preparar uma implantação. Publicar o sistema ainda exige configurar domínio, HTTPS, variáveis de ambiente, bancos e armazenamento persistente.

Consulte o **[guia de configuração e operação](docs/CONFIGURACAO.md)** para autenticação externa, e-mail, S3, produção e solução dos erros de conexão ou migrations.

---

<div align="center">
  <strong>Jornal DM</strong><br />
  <sub>Informação, educação e comunidade.</sub>
</div>
