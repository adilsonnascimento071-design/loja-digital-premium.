# Loja Digital Premium

Loja responsiva de produtos digitais em USD, com catálogo, pesquisa, carrinho, checkout e painel administrativo.

## Estrutura
- `index.html` — loja pública ligada ao catálogo Supabase e checkout Stripe/PayPal.
- `admin.html` — painel administrativo com autenticação, gestão de produtos e consulta de encomendas.
- `config.js` — configuração pública Supabase; nunca incluir segredos.
- `supabase/schema.sql` — tabelas, políticas RLS, perfis e armazenamento privado.
- `supabase/functions/create-checkout/index.ts` — cria sessões de pagamento e calcula preços no servidor.
- `supabase/functions/capture-paypal/index.ts` — captura aprovações PayPal.
- `supabase/functions/payment-webhook/index.ts` — valida webhooks Stripe/PayPal e atualiza encomendas.
- `supabase/config.toml` — configuração das Edge Functions.
- `DEPLOYMENT.md` — instruções completas de configuração.

## Estado
Os adaptadores Stripe e PayPal e os respetivos webhooks estão no código, mas as funções ainda precisam de ser implantadas no teu projeto Supabase e configuradas com credenciais privadas. A ativação também depende de elegibilidade comercial no país de registo. Consulta `DEPLOYMENT.md`.

A entrega automática dos ficheiros por email ainda não está ativada; exige um serviço de email transacional e links de download assinados.
