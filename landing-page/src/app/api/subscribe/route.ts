import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

const subscribeSchema = z.object({
  email: z.string().email("Email invalide"),
  firstName: z.string().min(1).max(50).optional(),
  source: z.string().max(100).optional(),
});

const WAITLIST_ID = "cmo78oimu08j901png9bqw4xb";

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

    const res = await fetch(
      `https://api.freewaitlists.com/waitlists/${WAITLIST_ID}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          meta: {
            name: firstName ?? "",
            source: source ?? "landing",
          },
        }),
      }
    );

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      // 409 = already registered
      if (res.status === 409) {
        return NextResponse.json(
          { message: "Tu es déjà inscrit·e ! On te tient au courant 🚀" },
          { status: 200 }
        );
      }
      console.error("[subscribe] freewaitlists error:", err);
      return NextResponse.json(
        { error: "Une erreur est survenue. Réessaie dans quelques instants." },
        { status: 500 }
      );
    }

    const data = await res.json();
    console.log(`[subscribe] Nouvel inscrit: ${email}`, data);

    return NextResponse.json(
      { message: "Bienvenue dans l'aventure kolyb ! 🚀" },
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
