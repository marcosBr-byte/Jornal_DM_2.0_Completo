# Configuração e operação

[← Voltar ao README](../README.md)

Este guia complementa a apresentação do Jornal DM com os detalhes de ambiente e serviços opcionais.

## Credenciais e ambiente local

O arquivo `.env` fica na raiz da aplicação, ao lado do Gemfile. Ele é carregado por `dotenv-rails` em desenvolvimento e teste e está incluído no `.gitignore`.

- `PGHOST`, `PGPORT`, `PGUSER` e `PGPASSWORD`: conexão PostgreSQL.
- `ADMIN_EMAIL` e `ADMIN_PASSWORD`: criação do primeiro administrador pelo seed.
- `SEED_DEMO=true`: permite criar notícias de demonstração fora de produção.

O seed não substitui a senha nem o e-mail de contas existentes. Depois de criar a conta, é possível remover `ADMIN_PASSWORD` do ambiente; a autenticação utiliza a senha protegida no banco.

Variáveis já exportadas no terminal têm prioridade sobre `.env`. Uma `DATABASE_URL` definida também pode sobrepor os valores individuais da conexão. Deixe as URLs de produção comentadas ao usar o exemplo de desenvolvimento.

## PostgreSQL da prévia

```sh
# Iniciar o banco e a aplicação.
bin/preview

# Parar somente o banco, preservando seu volume.
docker compose -f compose.preview.yml stop

# Iniciar novamente somente o banco.
docker compose -f compose.preview.yml up -d --wait
```

Para parar o Rails, use `Ctrl+C` no terminal que está executando o servidor. O script da prévia faz uma compilação do Tailwind na inicialização; após alterações nas classes, execute `bin/rails tailwindcss:build` ou use `bin/dev` para acompanhar mudanças durante o desenvolvimento.

## Erro: migrations pendentes

Execute na raiz da aplicação e no mesmo ambiente do servidor:

```sh
bin/rails db:migrate
```

Depois, atualize a página. Tanto `bin/dev` quanto `bin/preview` executam `db:prepare` antes de iniciar o Rails.

A migration `20261113200013_add_body_format_to_articles` adiciona a identificação de texto simples ou formatado. Os conteúdos existentes permanecem no banco sem conversão destrutiva.

## Erro: fe_sendauth: no password supplied

O PostgreSQL foi localizado, mas o Rails não recebeu uma senha. Preencha a conexão no `.env`:

```dotenv
PGHOST=127.0.0.1
PGPORT=5432
PGUSER=postgres
PGPASSWORD='SUA_SENHA_REAL_DO_POSTGRESQL'
```

A senha é a do usuário PostgreSQL, não a senha do administrador do portal. Se o banco for o contêiner da prévia, use os valores configurados para esse contêiner, incluindo sua porta local.

Confira se alguma variável exportada ou `DATABASE_URL` está sobrepondo a configuração. Pare o servidor, execute `bin/rails db:prepare` e inicie novamente. Se não souber a senha de um PostgreSQL existente, será necessário recuperá-la ou redefini-la nesse banco.

## Editor e imagens

O editor Trix utiliza assets locais do Rails e não exige chave de API. A barra é estilizada em Tailwind, assim como o restante do painel.

O servidor sanitiza o HTML por uma lista de tags e atributos permitidos. A prévia usa a mesma formatação da reportagem e abre em outra aba, sem persistir o conteúdo. O texto pode ser conferido antes de salvar; uma nova capa é exibida depois do salvamento.

As imagens continuam no campo separado de capa. Anexos dentro do editor não estão habilitados. As capas aceitam JPEG, PNG ou WebP de até 1,5 MB, com armazenamento pelo Active Storage.

## Google e Facebook

Os botões de login externo aparecem quando o respectivo par de credenciais está preenchido:

| Provedor | Variáveis |
| --- | --- |
| Google | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
| Facebook | `FACEBOOK_APP_ID`, `FACEBOOK_APP_SECRET` |

Cadastre no aplicativo de cada provedor o callback correspondente:

```text
https://SEU_DOMINIO/acesso/auth/google_oauth2/callback
https://SEU_DOMINIO/acesso/auth/facebook/callback
```

Uma conta externa precisa ser vinculada explicitamente a um administrador existente. No console Rails:

```ruby
user = User.find_by!(email: "email-do-administrador")
user.update!(provider: "google_oauth2", uid: "identificador-fornecido-pelo-google")
```

Para Facebook, use `provider: "facebook"`. Cada usuário suporta um vínculo externo. Não há criação automática de administradores nem vinculação por coincidência de e-mail.

## E-mail

Em desenvolvimento, o Letter Opener apresenta localmente as mensagens. Para envio real em produção, configure:

```text
SMTP_ADDRESS
SMTP_PORT
SMTP_USERNAME
SMTP_PASSWORD
MAIL_FROM
APP_HOST
```

A recuperação de senha em produção depende de um remetente e de um servidor SMTP válidos.

## Produção

A produção exige senhas de pelo menos **12 caracteres**, inclusive ao autenticar uma conta copiada de desenvolvimento. A senha curta da prévia é aceita somente fora de produção; cadastre uma credencial exclusiva antes da implantação. Login e recuperação de senha possuem limites de tentativas por IP.

As capas são entregues pelo Rails com autorização: leitores acessam capas de notícias publicadas, e administradores também acessam rascunhos. O bucket deve continuar privado. Os uploads de capa usam o formulário do painel.

O Dockerfile prepara as dependências e pré-compila os assets. Configure as variáveis na hospedagem: o `.env` de desenvolvimento não é carregado automaticamente em produção.

| Variável | Finalidade |
| --- | --- |
| `RAILS_ENV=production` | Ativa a configuração de produção |
| `APP_HOST` | Domínio, sem o protocolo |
| `SECRET_KEY_BASE` | Segredo gerado com `bin/rails secret` |
| `DATABASE_URL` | Banco principal |
| `CACHE_DATABASE_URL` | Banco do Solid Cache |
| `QUEUE_DATABASE_URL` | Banco do Solid Queue |
| `CABLE_DATABASE_URL` | Banco do Solid Cable |

Prepare os bancos:

```sh
RAILS_ENV=production bin/rails db:prepare
```

Os schemas dos adaptadores Solid estão em `db/*_schema.rb`. A preparação inicial requer bancos previamente provisionados ou permissão de criação para o usuário PostgreSQL.

Use HTTPS no proxy; cookies seguros e redirecionamento HTTPS estão ativos na configuração de produção. Execute os jobs com `bin/jobs` ou defina `SOLID_QUEUE_IN_PUMA=1`. A gem Kamal está instalada, mas a configuração da infraestrutura de implantação depende do ambiente escolhido.

### Armazenamento S3

```dotenv
ACTIVE_STORAGE_SERVICE=amazon
AWS_REGION=us-east-1
S3_BUCKET=nome-do-bucket
```

Forneça as credenciais AWS pelo mecanismo padrão do SDK, como uma IAM role. Com armazenamento local, mantenha um volume persistente em `/rails/storage`.

Mantenha backups dos bancos e das imagens. Google, Facebook, SMTP, S3 e a imagem Docker completa da aplicação ainda precisam de validação com as credenciais e a infraestrutura reais de produção.
