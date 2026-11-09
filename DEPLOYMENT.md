# Configuração e publicação — Loja Digital Premium

A loja pública atual está em `index.html`. O painel de administração está em `admin.html`.

## 1. Publicar a loja
1. No GitHub, abre o repositório e entra em **Settings → Pages**.
2. Em **Build and deployment**, escolhe **Deploy from a branch**.
3. Seleciona `main` e a pasta `/(root)`; guarda.
4. O endereço será apresentado pelo GitHub Pages quando a publicação terminar.

## 2. Criar o backend Supabase
1. Cria um projeto em https://supabase.com/.
2. Abre **SQL Editor** e executa todo o conteúdo de `supabase/schema.sql`.
3. Em **Project Settings → API**, copia Project URL e a chave publishable/anon.
4. Coloca esses dois valores em `config.js`. São valores públicos; nunca uses a chave `service_role` no browser.
5. Em **Authentication → URL Configuration**, adiciona o domínio publicado à lista de URLs permitidos.
6. Cria a tua conta em **Authentication → Users**.
7. No SQL Editor, promove apenas a tua conta a administrador:
   `update public.profiles set role = 'admin' where id = (select id from auth.users where email = 'TEU_EMAIL');`
8. Abre `/admin.html`, inicia sessão e adiciona produtos.

## 3. Ficheiros digitais
- Usa o bucket privado `digital-products` criado pelo SQL.
- Faz upload dos ficheiros pelo painel Storage do Supabase.
- Guarda o caminho do ficheiro no campo `file_path` do produto.
- Não tornes o bucket público e não coloques links permanentes de download no catálogo.
- A entrega automática exige uma função backend que confirme o pagamento e emita links assinados de curta duração.

## 4. Pagamentos reais — ainda pendente de escolha
O endpoint `supabase/functions/create-checkout` é um bloqueio seguro: não inventa pagamentos nem marca encomendas como pagas. O adaptador do provedor e o webhook só devem ser implementados depois de escolher o método de pagamento e confirmar a disponibilidade da conta comercial no país de operação.

Nunca guardes chaves secretas no `index.html`, `config.js` ou noutro ficheiro público do GitHub. Guarda-as em **Supabase → Edge Functions → Secrets**.

## 5. Checklist antes de vender
- [ ] Configurar URL e chave pública do Supabase em `config.js`
- [ ] Executar `supabase/schema.sql`
- [ ] Criar conta e atribuir papel de administrador
- [ ] Cadastrar produtos reais, preços e capas
- [ ] Carregar os ficheiros para o bucket privado
- [ ] Escolher e configurar o provedor de pagamento
- [ ] Implementar e testar webhook de confirmação
- [ ] Implementar entrega segura após pagamento
- [ ] Testar compra, falha, reembolso e acesso ao download
- [ ] Publicar termos, política de privacidade e política de reembolso

**Estado atual:** catálogo e checkout demonstrativo; backend e painel administrativo preparados para configuração; cobrança e entrega automática ainda não ativadas.
