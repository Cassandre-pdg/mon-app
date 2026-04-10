import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "kolyb — Ton élan, au quotidien.",
  description:
    "kolyb réunit check-in émotionnel, planificateur, suivi sommeil et communauté dans une seule app pour entrepreneurs indépendants. Avance à ton rythme, jamais seul.",
  keywords: [
    "entrepreneurs indépendants",
    "bien-être",
    "productivité",
    "communauté",
    "freelance",
    "kolyb",
  ],
  authors: [{ name: "Kolyb" }],
  creator: "Kolyb",
  openGraph: {
    type: "website",
    locale: "fr_FR",
    title: "kolyb — Ton élan, au quotidien.",
    description:
      "L'app compagnon des entrepreneurs indépendants. Check-in, planificateur, sommeil, communauté — tout en un.",
    siteName: "kolyb",
  },
  twitter: {
    card: "summary_large_image",
    title: "kolyb — Ton élan, au quotidien.",
    description:
      "L'app compagnon des entrepreneurs indépendants. Avance à ton rythme, jamais seul.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="antialiased">{children}</body>
    </html>
  );
}
