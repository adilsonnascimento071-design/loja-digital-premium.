// Configuração pública do Supabase.
// Substitui os valores depois de criares o projeto Supabase.
// A chave anon/publishable pode estar no frontend quando as políticas RLS estão corretas.
// NUNCA coloques service_role, Stripe secret ou outras chaves privadas neste ficheiro.
window.STORE_CONFIG = {
  SUPABASE_URL: "https://YOUR_PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY"
};
