import { createClient } from "@supabase/supabase-js";

// ─── Types ────────────────────────────────────────────────────────────────────

export type WaitlistEntry = {
  id: string;
  email: string;
  first_name: string | null;
  source: string;
  created_at: string;
};

// ─── Client Supabase (server-side uniquement — SERVICE ROLE) ──────────────────
// Ce fichier ne doit JAMAIS être importé côté client (composant "use client").
// La clé service role contourne le RLS → usage réservé aux API routes Next.js.

function createSupabaseServerClient() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      "❌ Variables Supabase manquantes : SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont requises."
    );
  }

  return createClient(url, key, {
    auth: {
      // Pas de session côté serveur pour les API routes
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

// Client instancié de façon lazy pour éviter un crash au build si les vars d'env sont absentes
let _supabaseServer: ReturnType<typeof createSupabaseServerClient> | null = null;

export function getSupabaseServer() {
  if (!_supabaseServer) {
    _supabaseServer = createSupabaseServerClient();
  }
  return _supabaseServer;
}
