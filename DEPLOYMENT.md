# Configuração e publicação — Loja Digital Premium

## 1. Pré-requisitos da empresa brasileira
O código está preparado para uma empresa registada no Brasil. Antes de ativar pagamentos reais, confirma que cada conta foi aberta com os dados verdadeiros da mesma entidade.

### Stripe Brasil
- CPF/CNPJ e razão social compatíveis com os registos oficiais.
- Endereço comercial no Brasil.
- Representante legal residente no Brasil com CPF, devidamente autorizado a representar a entidade.
- Conta bancária brasileira em BRL vinculada ao CPF/CNPJ da conta Stripe.
- Website funcional com produtos, preços, contactos e políticas de reembolso/privacidade.

### PayPal Brasil
- Conta PayPal Business brasileira verificada.
- CNPJ, dados da entidade e conta bancária empresarial solicitados durante o onboarding.
- Aplicação REST criada no Developer Dashboard para obter Client ID e Secret.

A empresa estar registada no Brasil é um requisito importante, mas não substitui a aprovação e a verificação do Stripe/PayPal. Não uses dados fiscais, endereço ou conta bancária de terceiros.

## 2. Supabase
1. Cria/abre o projeto em https://supabase.com/.
2. Executa supabase/schema.sql no SQL Editor.
3. Coloca Project URL e chave publishable/anon em config.js. Nunca publiques a chave service_role.
4. Cria a conta do proprietário e promove-a a administrador:
   update public.profiles set role='admin' where id=(select id from auth.users where email='TEU_EMAIL');
5. Em Authentication → URL Configuration, adiciona o domínio da loja.

## 3. Segredos das Edge Functions
Configura no Supabase → Edge Functions → Secrets:
- APP_ORIGIN — URL HTTPS exata da loja, sem barra final.
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY — segredo apenas no servidor.
- STRIPE_SECRET_KEY — começa por sk_test_ para testes; sk_live_ só depois da aprovação.
- STRIPE_WEBHOOK_SECRET — segredo de assinatura do endpoint Stripe.
- STRIPE_MERCHANT_COUNTRY=BR
- STRIPE_MERCHANT_COUNTRY_ELIGIBLE=false inicialmente; muda para true somente depois de a conta Stripe Brasil estar aprovada e apta a receber.
- PAYPAL_CLIENT_ID
- PAYPAL_CLIENT_SECRET
- PAYPAL_WEBHOOK_ID
- PAYPAL_ENV=sandbox para testes; live apenas em produção.
- PAYPAL_MERCHANT_COUNTRY=BR
- PAYPAL_MERCHANT_COUNTRY_ELIGIBLE=false inicialmente; muda para true somente depois de a conta PayPal Business Brasil estar verificada e apta a receber.

Nunca coloques chaves secretas em config.js, index.html, GitHub ou mensagens de chat.

## 4. Configurar Stripe
1. Acede a https://dashboard.stripe.com/ e conclui o onboarding da entidade brasileira.
2. Em Developers → API keys, copia a Secret key de teste para STRIPE_SECRET_KEY.
3. Em Developers → Webhooks, cria o endpoint:
   https://TEU_PROJECT_REF.supabase.co/functions/v1/payment-webhook
4. Seleciona checkout.session.completed, checkout.session.async_payment_succeeded e checkout.session.async_payment_failed.
5. Copia o Signing secret (whsec_...) para STRIPE_WEBHOOK_SECRET.
6. A loja apresenta e cobra os produtos em USD. Confirma no Dashboard Stripe a moeda de liquidação, conversão e taxas da tua conta brasileira; o banco de recebimento no Brasil pode receber em BRL.

## 5. Configurar PayPal
1. Acede a https://developer.paypal.com/dashboard/ com a conta PayPal Business.
2. Em Apps & Credentials, cria uma REST API App no ambiente Sandbox.
3. Copia Client ID e Secret para os secrets Supabase.
4. Em Webhooks, regista o mesmo endpoint Supabase:
   https://TEU_PROJECT_REF.supabase.co/functions/v1/payment-webhook
5. Subscreve PAYMENT.CAPTURE.COMPLETED e PAYMENT.CAPTURE.DENIED; guarda o Webhook ID em PAYPAL_WEBHOOK_ID.
6. A integração cria ordens em USD. No PayPal Brasil, confirma em Payment Receiving Preferences que a conta pode receber e manter/aceitar USD; se USD não estiver configurado como saldo de recebimento, o pagamento pode ficar pendente até aprovação manual ou conversão.

## 6. Deploy
No terminal com Supabase CLI:
```bash
supabase login
supabase link --project-ref TEU_PROJECT_REF
supabase secrets set APP_ORIGIN=https://TEU_DOMINIO SUPABASE_URL=https://TEU_PROJECT_REF.supabase.co SUPABASE_SERVICE_ROLE_KEY=TEU_SERVICE_ROLE_KEY
supabase functions deploy create-checkout
supabase functions deploy capture-paypal
supabase functions deploy payment-webhook
```
Define os restantes secrets no painel Supabase. Para testes, mantém ambos os flags *_MERCHANT_COUNTRY_ELIGIBLE=false até teres concluído o onboarding e os testes.

## 7. Testes antes de Live
- Stripe: usa cartões de teste oficiais e confirma o evento webhook, moeda USD, valor e atualização da encomenda.
- PayPal: usa contas Sandbox de comprador e vendedor; testa aprovação, cancelamento, captura, valor divergente e webhook repetido.
- Confirma que uma encomenda só passa a paid depois de a API/webhook validar o valor e a moeda.
- Nunca uses dinheiro real para testes de integração.

## 8. Produção e entrega digital
Depois da aprovação comercial, substitui as chaves de teste pelas chaves Live, cria os webhooks Live correspondentes e define os flags de elegibilidade para true. Não mistures credenciais Sandbox com webhooks Live (ou vice-versa).

A confirmação de pagamento atualiza o estado da encomenda. A entrega automática dos ficheiros por email ainda não está ativa; exige um serviço transacional, links assinados de curta duração e testes de segurança no bucket privado.