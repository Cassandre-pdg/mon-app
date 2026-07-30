import type { Metadata } from "next";
import LegalPage from "@/components/LegalPage";

export const metadata: Metadata = {
  title: "Mentions légales · kolyb",
  description: "Mentions légales de l'application et du site web kolyb.",
  alternates: {
    canonical: "/legal/mentions-legales",
  },
  openGraph: {
    title: "Mentions légales · kolyb",
    description: "Mentions légales de l'application et du site web kolyb.",
    url: "/legal/mentions-legales",
    type: "website",
  },
};

export default function MentionsLegalesPage() {
  return (
    <LegalPage tag="Légal" title="Mentions légales" lastUpdated="avril 2026">
      <h2>Éditeur de l&apos;application</h2>
      <div className="legal-info-row">
        <span className="legal-info-label">Dénomination</span>
        <span className="legal-info-value">Cassandre Rollet</span>
      </div>
      <div className="legal-info-row">
        <span className="legal-info-label">Forme juridique</span>
        <span className="legal-info-value">Entreprise individuelle</span>
      </div>
      <div className="legal-info-row">
        <span className="legal-info-label">Pays</span>
        <span className="legal-info-value">France</span>
      </div>
      <div className="legal-info-row">
        <span className="legal-info-label">Email</span>
        <span className="legal-info-value">
          <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>
        </span>
      </div>

      <h2>Directeur de la publication</h2>
      <p>Cassandre Rollet</p>

      <h2>Hébergement</h2>
      <div className="legal-info-row">
        <span className="legal-info-label">Application mobile</span>
        <span className="legal-info-value">Supabase (Frankfurt, EU)</span>
      </div>
      <div className="legal-info-row">
        <span className="legal-info-label">Site web</span>
        <span className="legal-info-value">Vercel Inc., 340 Pine Street, San Francisco, CA</span>
      </div>
      <div className="legal-info-row">
        <span className="legal-info-label">Données</span>
        <span className="legal-info-value">Hébergement EU uniquement (RGPD)</span>
      </div>

      <h2>Propriété intellectuelle</h2>
      <p>
        L&apos;ensemble du contenu présent sur l&apos;application et le site web kolyb (textes, graphiques, logo,
        icônes, illustrations, code source) est protégé par le droit de la propriété intellectuelle et appartient
        à Cassandre Rollet, sauf mention contraire.
      </p>
      <p>
        Toute reproduction, représentation, modification, publication ou adaptation de tout ou partie des éléments
        du site, quel que soit le moyen ou le procédé utilisé, est interdite sans autorisation préalable écrite.
      </p>

      <h2>Données personnelles</h2>
      <p>
        Le traitement de tes données personnelles est décrit dans notre{" "}
        <a href="/legal/confidentialite">Politique de Confidentialité</a>. Conformément au RGPD, tu peux exercer
        tes droits en contactant : <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>.
      </p>

      <h2>Cookies</h2>
      <p>
        L&apos;application mobile kolyb n&apos;utilise pas de cookies. Le site web utilise uniquement des cookies
        techniques nécessaires à son fonctionnement, sans tracking ni publicité.
      </p>

      <h2>Loi applicable</h2>
      <p>
        Le présent site et l&apos;application kolyb sont soumis au droit français. Tout litige relatif à
        l&apos;utilisation du service relève de la compétence exclusive des tribunaux français.
      </p>

      <h2>Contact</h2>
      <p>
        Pour toute question : <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>
      </p>
    </LegalPage>
  );
}
