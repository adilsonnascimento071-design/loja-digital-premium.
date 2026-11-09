// Supabase Edge Function: create-checkout
// Esta função NÃO cobra pagamentos enquanto o provedor não estiver escolhido/configurado.
// Deploy: supabase functions deploy create-checkout
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("APP_ORIGIN") ?? "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const response = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return response({ error: "Método não permitido." }, 405);

  const provider = Deno.env.get("PAYMENT_PROVIDER");
  if (!provider) return response({
    error: "Pagamentos ainda não configurados.",
    code: "PAYMENT_PROVIDER_NOT_CONFIGURED",
    next_step: "Escolher Stripe, PayPal ou outro provedor e configurar as credenciais no Supabase Secrets."
  }, 503);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return response({ error: "Autenticação obrigatória." }, 401);
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } }
  );
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return response({ error: "Sessão inválida." }, 401);

  // Não aceitar preços enviados pelo navegador. O backend deve carregar os produtos
  // pelo ID, confirmar que estão ativos e calcular o total a partir da base de dados.
  let body: { items?: Array<{ product_id: string; quantity: number }> };
  try { body = await req.json(); } catch { return response({ error: "JSON inválido." }, 400); }
  if (!Array.isArray(body.items) || body.items.length < 1 || body.items.length > 30) {
    return response({ error: "Lista de produtos inválida." }, 400);
  }
  for (const item of body.items) {
    if (!item || typeof item.product_id !== "string" || !Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 20) {
      return response({ error: "Item ou quantidade inválida." }, 400);
    }
  }

  // A criação de sessão depende do provedor escolhido. Não criar encomenda como paga
  // nem devolver URL fictício. A implementação específica será adicionada após a escolha.
  return response({ error: "Adaptador do provedor ainda não implementado.", provider, code: "PROVIDER_ADAPTER_REQUIRED" }, 501);
});
