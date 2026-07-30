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
    "entrepreneurs & indépendants",
    "bien-être",
    "productivité",
    "communauté",
    "freelance",
    "kolyb",
  ],
  authors: [{ name: "Kolyb" }],
  creator: "Kolyb",
  alternates: {
    canonical: "/",
  },
  icons: {
    icon: [
      { url: "/kolyb_icon.png", type: "image/png", sizes: "512x512" },
    ],
    apple: "/kolyb_icon.png",
  },
  openGraph: {
    type: "website",
    url: "/",
    locale: "fr_FR",
    title: "kolyb : Ton élan, au quotidien.",
    description:
      "L'app compagnon des entrepreneurs indépendants. Check-in, planificateur, sommeil, communauté, tout en un.",
    siteName: "kolyb",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "kolyb : Ton élan, au quotidien.",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "kolyb : Ton élan, au quotidien.",
    description:
      "L'app compagnon des entrepreneurs indépendants. Avance à ton rythme, jamais seul.",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
};

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "https://kolyb.app/#organization",
      name: "kolyb",
      url: "https://kolyb.app",
      logo: "https://kolyb.app/kolyb_icon.png",
      sameAs: [
        "https://www.instagram.com/kolybapp/",
        "https://www.linkedin.com/in/cassandrerollet/",
      ],
    },
    {
      "@type": "SoftwareApplication",
      name: "kolyb",
      applicationCategory: "LifestyleApplication",
      operatingSystem: "iOS",
      url: "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978",
      description:
        "kolyb réunit check-in émotionnel, planificateur et communauté dans une seule app pour entrepreneurs indépendants.",
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "EUR",
      },
      publisher: {
        "@id": "https://kolyb.app/#organization",
      },
    },
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <body className={`${inter.variable} antialiased`}>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {children}
      </body>
    </html>
  );
}
