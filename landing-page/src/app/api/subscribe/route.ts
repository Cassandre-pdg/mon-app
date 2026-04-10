import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { supabaseServer } from "@/lib/supabase";

// ─── Schéma de validation ─────────────────────────────────────────────────────

const subscribeSchema = z.object({
  email: z.string().email("Email invalide"),
  firstName: z.string().min(1).max(50).optional(),
  source: z.string().max(100).optional(),
});

// ─── POST /api/subscribe ───────────────────────────────────────────────────────
// Inscrit un email dans la table waitlist Supabase.
// Gère les doublons sans exposer si l'email existait déjà (privacy).

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = subscribeSchema.safeParse(body);

    if (!parsed.success) {
      return NextResponse.json(
        { error: parsed.error.errors[0].message },
        { status: 400 }
      );
    }

    const { email, firstName, source } = parsed.data;

    // Tentative d'insertion dans Supabase
    const { error } = await supabaseServer
      .from("waitlist")
      .insert({
        email: email.toLowerCase().trim(),
        first_name: firstName?.trim() ?? null,
        source: source ?? "landing",
      });

    if (error) {
      // Code 23505 = violation d'unicité (email déjà existant)
      if (error.code === "23505") {
        return NextResponse.json(
          { message: "Tu es déjà inscrit·e ! On te tient au courant 🚀" },
          { status: 200 }
        );
      }

      console.error("[subscribe] Erreur Supabase:", error.message);
      return NextResponse.json(
        { error: "Une erreur est survenue. Réessaie dans quelques instants." },
        { status: 500 }
      );
    }

    // Récupérer le nombre total d'inscrits (pour affichage éventuel)
    const { count } = await supabaseServer
      .from("waitlist")
      .select("*", { count: "exact", head: true });

    console.log(`[subscribe] Nouvel inscrit: ${email} (total: ${count})`);

    return NextResponse.json(
      {
        message: "Bienvenue dans l'aventure kolyb ! 🚀",
        count: count ?? 0,
      },
      { status: 201 }
    );
  } catch (err) {
    console.error("[subscribe] Erreur inattendue:", err);
    return NextResponse.json(
      { error: "Erreur serveur. Réessaie dans quelques instants." },
      { status: 500 }
    );
  }
}

// ─── GET /api/subscribe ────────────────────────────────────────────────────────
// Retourne le nombre d'inscrits (utile pour le compteur hero).

export async function GET() {
  try {
    const { count, error } = await supabaseServer
      .from("waitlist")
      .select("*", { count: "exact", head: true });

    if (error) {
      return NextResponse.json({ count: 0 });
    }

    return NextResponse.json({ count: count ?? 0 });
  } catch {
    return NextResponse.json({ count: 0 });
  }
}
