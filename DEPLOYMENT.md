# Configuração e publicação — Loja Digital Premium

## Supabase
1. Cria um projeto em https://supabase.com/ e executa `supabase/schema.sql` no SQL Editor.
2. Coloca Project URL e chave publishable/anon em `config.js`. Nunca publiques a chave service_role.
3. Cria a tua conta e promove-a a administrador:
   `update public.profiles set role='admin' where id=(select id from auth.users where email='TEU_EMAIL');`
4. Adiciona o domínio da loja em Authentication → URL Configuration.

## Pagamentos Stripe e PayPal
O código contém checkout Stripe Checkout, PayPal Orders, captura PayPal e webhook com validação de assinatura. O servidor calcula os preços a partir do Supabase; o navegador não determina os valores cobrados.

**Atenção se a empresa estiver registada em Angola:** a lista oficial do Stripe não inclui Angola. A documentação PayPal classifica Angola como “Send only” para integrações de vendedores. Não declares país, morada ou empresa falsos. Usa estes adaptadores apenas se tiveres entidade comercial real, documentação fiscal/bancária e aprovação do provedor numa jurisdição elegível.

Configura como Supabase Edge Function Secrets:
- `APP_ORIGIN` — URL HTTPS da loja
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY` — segredo apenas no servidor
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`
- `STRIPE_MERCHANT_COUNTRY_ELIGIBLE` — manter false até elegibilidade comprovada
- `PAYPAL_CLIENT_ID`, `PAYPAL_CLIENT_SECRET`, `PAYPAL_WEBHOOK_ID`
- `PAYPAL_ENV` — sandbox ou live
- `PAYPAL_MERCHANT_COUNTRY_ELIGIBLE` — manter false até autorização para receber pagamentos

## Webhooks
Ambos usam:
`https://TEU_PROJECT_REF.supabase.co/functions/v1/payment-webhook`

Stripe: subscreve `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `checkout.session.async_payment_failed`; guarda o signing secret em `STRIPE_WEBHOOK_SECRET`.

PayPal: subscreve `PAYMENT.CAPTURE.COMPLETED` e `PAYMENT.CAPTURE.DENIED`; guarda o Webhook ID em `PAYPAL_WEBHOOK_ID`.

## Deploy
```bash
supabase login
supabase link --project-ref TEU_PROJECT_REF
supabase secrets set APP_ORIGIN=https://TEU_DOMINIO SUPABASE_URL=https://TEU_PROJECT_REF.supabase.co SUPABASE_SERVICE_ROLE_KEY=TEU_SERVICE_ROLE_KEY
supabase functions deploy create-checkout
supabase functions deploy capture-paypal
supabase functions deploy payment-webhook
```
Define os restantes secrets no painel ou com `supabase secrets set`.

## Entrega digital
Os webhooks atualizam o estado para paid apenas depois da confirmação do provedor. A entrega automática por email ainda depende de configurar um serviço transacional, como Resend, e implementar links assinados de curta duração no bucket privado. Não está ativada.

## Testes
Testa primeiro em Sandbox/Test: sucesso, cancelamento, recusa, webhook repetido e alteração fraudulenta de preço. Só ativa Live após aprovação comercial, fiscal e bancária.
