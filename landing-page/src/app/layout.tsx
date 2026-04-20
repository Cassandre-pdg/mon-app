import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://kolyb.app"),
  title: "kolyb : Ton élan, au quotidien.",
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
    title: "kolyb : Ton élan, au quotidien.",
    description:
      "L'app compagnon des entrepreneurs indépendants. Check-in, planificateur, sommeil, communauté, tout en un.",
    siteName: "kolyb",
  },
  twitter: {
    card: "summary_large_image",
    title: "kolyb : Ton élan, au quotidien.",
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
      <body className={`${inter.variable} antialiased`}>{children}</body>
    </html>
  );
}
