# Publicar no Render com Neon

Esta configuração usa um serviço web **Free** no Render e um projeto **Free** no Neon. Rails, painel administrativo, Tailwind e editor são mantidos.

## 1. Criar o banco no Neon

1. Entre em https://console.neon.tech/ e crie um projeto no plano Free.
2. Escolha uma região dos Estados Unidos próxima à região Virginia do Render.
3. Abra **Connect**, selecione o banco do projeto e copie a conexão PostgreSQL com **sslmode=require**.
4. Use uma conexão **direta**, sem **-pooler** no hostname, para permitir as migrations do Rails.
5. Guarde essa conexão: ela contém a senha do banco. Cole-a somente no campo secreto **DATABASE_URL** do Render, nunca no GitHub ou em uma conversa.

É necessário apenas um banco. A aplicação guarda nele as notícias, os usuários, as capas e as tabelas dos adaptadores Solid.

## 2. Criar o serviço no Render

Use a configuração automática:

[**Publicar no Render**](https://render.com/deploy?repo=https://github.com/marcosBr-byte/Jornal_DM_2.0_Completo)

1. Entre com sua conta GitHub.
2. Confirme o repositório **marcosBr-byte/Jornal_DM_2.0_Completo**.
3. Confira que o serviço **jornal-dm** está no plano **Free**.
4. No campo **DATABASE_URL**, cole a conexão direta do Neon.
5. Confirme a criação do Blueprint e aguarde o deploy.

O arquivo render.yaml configura Docker, HTTPS pelo Render, verificação de saúde, conexão única de banco, jobs no mesmo processo e a geração dos segredos. Ele não cria um banco pago no Render nem adiciona um disco pago.

O deploy automático espera os testes do GitHub passarem. A primeira compilação da imagem pode levar alguns minutos.

### Se você já abriu “New Web Service”

A configuração automática pelo link acima evita preencher várias opções à mão. Se preferir continuar nessa tela, escolha:

| Campo | Valor |
| --- | --- |
| Repositório | marcosBr-byte/Jornal_DM_2.0_Completo |
| Branch | main |
| Language / Runtime | Docker |
| Dockerfile | ./Dockerfile |
| Instance Type | Free |
| Docker Command | ./bin/render-start |
| Health Check Path | /up |

Em **Environment**, configure DATABASE_URL, SINGLE_DATABASE=true, ACTIVE_STORAGE_SERVICE=database, RAILS_ENV=production, ADMIN_EMAIL=admin@jornaldm, SOLID_QUEUE_IN_PUMA=1 e SOLID_QUEUE_MODE=async. Gere valores aleatórios separados para SECRET_KEY_BASE e ADMIN_PASSWORD; a senha administrativa precisa ter pelo menos 12 caracteres. Para replicar os demais limites de memória e concorrência, use os valores de render.yaml. Não reutilize a senha curta da prévia local.

## 3. Acessar o site e o painel

Quando o deploy terminar, abra a URL **https://...onrender.com** exibida pelo Render.

- Portal: **/**
- Painel: **/admin**
- E-mail inicial: **admin@jornaldm**
- Senha: valor gerado para **ADMIN_PASSWORD**, visível somente na área **Environment** do serviço no Render.

O administrador é criado na primeira inicialização. Os seeds não substituem a senha de uma conta existente. Para recuperação por e-mail, configure um endereço real e SMTP; isso não é necessário para abrir o portal ou entrar no painel com a senha.

## Capas e persistência

O plano Free não oferece disco persistente. Por isso, ACTIVE_STORAGE_SERVICE=database guarda as capas no PostgreSQL do Neon. As imagens continuam limitadas a JPEG, PNG e WebP de até 1,5 MB e são entregues pelo controller que verifica as permissões dos rascunhos.

Os dados e as imagens usam a cota de armazenamento do Neon. Este modo foi preparado para uma prévia ou portal pequeno; para maior volume, configure um bucket privado S3 compatível. Capas já armazenadas em outros serviços continuam usando o serviço registrado em cada arquivo.

## Limites do plano gratuito

- O Render pode suspender o serviço após inatividade; o primeiro acesso pode demorar para responder.
- Enquanto o serviço estiver suspenso, os jobs em segundo plano também ficam parados. Eles retomam quando o processo volta.
- Neon e Render possuem cotas gratuitas de armazenamento, processamento e tráfego.
- O banco e as imagens não ficam no disco temporário do Render.
- Esta configuração declara **plan: free**; nenhum recurso pago foi provisionado.

## Solução de problemas

**Banco não conecta:** confira DATABASE_URL no Render, o nome do banco e a opção SSL na conexão do Neon.

**Migrations pendentes:** o bin/render-start executa db:prepare antes de iniciar o servidor. Consulte os logs para identificar a primeira falha da migration; não apague o banco.

**Sem administrador:** confira as variáveis ADMIN_EMAIL e ADMIN_PASSWORD. Uma conta existente não é redefinida por um redeploy.

**Host bloqueado:** o domínio padrão é detectado por RENDER_EXTERNAL_HOSTNAME. Para um domínio próprio, defina APP_HOST somente com o hostname, sem https://.

**Build da Cloudflare falhando:** este deploy utiliza o serviço Docker do Render. Não use Workers/Pages para executar este servidor Rails.

## Referências

- [Blueprints do Render](https://render.com/docs/blueprint-spec)
- [Docker no Render](https://render.com/docs/docker)
- [Limites do plano Free](https://render.com/docs/free)
- [Conexão do Neon](https://neon.com/docs/connect/connect-from-any-app)
