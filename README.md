# Loja Digital Premium

Loja responsiva de produtos digitais, com catálogo em USD, carrinho e checkout demonstrativo.

## Estrutura
- `index.html` — loja pública.
- `admin.html` — painel administrativo com autenticação Supabase, gestão básica de produtos e consulta de encomendas.
- `config.js` — configuração pública do cliente Supabase (substituir os placeholders).
- `supabase/schema.sql` — tabelas, políticas RLS, perfis e bucket privado.
- `supabase/functions/create-checkout/index.ts` — endpoint seguro de checkout em modo bloqueado até configurar um provedor.
- `DEPLOYMENT.md` — instruções de configuração e publicação.

## Publicar
Consulta [DEPLOYMENT.md](./DEPLOYMENT.md) para configurar GitHub Pages e Supabase.

## Estado dos pagamentos
O checkout atual da loja continua demonstrativo. A base de dados e a estrutura segura para o backend estão preparadas, mas pagamentos reais, confirmação por webhook e entrega automática só podem ser ativados depois de escolher e configurar um provedor. Não coloques chaves secretas no frontend.
