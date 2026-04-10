import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

const subscribeSchema = z.object({
  email: z.string().email("Email invalide"),
  firstName: z.string().min(1, "Prénom requis").max(50).optional(),
  source: z.string().optional(),
});

// In-memory store (replace with DB/Supabase in production)
const subscribers: Array<{ email: string; firstName?: string; createdAt: string; source?: string }> = [];

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

    // Check for duplicate
    if (subscribers.find((s) => s.email === email)) {
      return NextResponse.json(
        { message: "Tu es déjà inscrit·e ! On te tient au courant 🚀" },
        { status: 200 }
      );
    }

    // Store subscriber
    subscribers.push({
      email,
      firstName,
      source: source || "landing",
      createdAt: new Date().toISOString(),
    });

    console.log(`New subscriber: ${email} (total: ${subscribers.length})`);

    return NextResponse.json(
      {
        message: "Bienvenue dans l'aventure kolyb ! 🚀",
        count: subscribers.length,
      },
      { status: 201 }
    );
  } catch {
    return NextResponse.json(
      { error: "Une erreur est survenue. Réessaie dans quelques instants." },
      { status: 500 }
    );
  }
}

export async function GET() {
  return NextResponse.json({ count: subscribers.length });
}
