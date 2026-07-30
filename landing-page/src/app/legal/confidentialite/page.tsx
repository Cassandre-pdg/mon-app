import type { Metadata } from "next";
import LegalPage from "@/components/LegalPage";

export const metadata: Metadata = {
  title: "Politique de confidentialité · kolyb",
  description: "Politique de confidentialité et protection des données personnelles de l'application kolyb.",
  alternates: {
    canonical: "/legal/confidentialite",
  },
  openGraph: {
    title: "Politique de confidentialité · kolyb",
    description: "Politique de confidentialité et protection des données personnelles de l'application kolyb.",
    url: "/legal/confidentialite",
    type: "website",
  },
};

export default function ConfidentialitePage() {
  return (
    <LegalPage tag="RGPD" title="Politique de confidentialité" lastUpdated="avril 2026">
      <div className="legal-highlight">
        🇪🇺 Toutes tes données sont hébergées en Europe (Frankfurt, EU) et traitées conformément au RGPD. Nous ne
        vendons jamais tes données. Jamais.
      </div>

      <h2>1. Responsable du traitement</h2>
      <p>Le responsable du traitement des données à caractère personnel est :</p>
      <p>
        <strong>Cassandre Rollet</strong>
        <br />
        Entreprise individuelle, France
        <br />
        Email : <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>
      </p>

      <h2>2. Données collectées</h2>
      <p>Nous collectons uniquement les données nécessaires au fonctionnement du service :</p>

      <h3>Données d&apos;inscription</h3>
      <ul>
        <li>Adresse email</li>
        <li>Prénom (optionnel)</li>
        <li>Méthode d&apos;authentification (email, Google, Apple)</li>
      </ul>

      <h3>Données d&apos;utilisation</h3>
      <ul>
        <li>Check-ins émotionnels (matin et soir), <strong>données sensibles chiffrées</strong></li>
        <li>Tâches du planificateur</li>
        <li>Données de sommeil, <strong>données sensibles chiffrées</strong></li>
        <li>Posts et interactions dans la communauté</li>
        <li>Streaks et badges</li>
      </ul>

      <h3>Données techniques</h3>
      <ul>
        <li>Adresse IP (anonymisée)</li>
        <li>Type d&apos;appareil et version de l&apos;OS</li>
        <li>Logs d&apos;erreur anonymisés</li>
      </ul>

      <h2>3. Finalités du traitement</h2>
      <div className="tbl-scroll" style={{ overflowX: "auto" }}>
        <table className="legal-table">
          <thead>
            <tr>
              <th>Finalité</th>
              <th>Base légale</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Fourniture du service kolyb</td>
              <td>Exécution du contrat</td>
            </tr>
            <tr>
              <td>Personnalisation de l&apos;expérience</td>
              <td>Intérêt légitime</td>
            </tr>
            <tr>
              <td>Envoi de notifications push</td>
              <td>Consentement (opt-in)</td>
            </tr>
            <tr>
              <td>Amélioration du service</td>
              <td>Intérêt légitime</td>
            </tr>
            <tr>
              <td>Sécurité et prévention des fraudes</td>
              <td>Obligation légale</td>
            </tr>
          </tbody>
        </table>
      </div>

      <h2>4. Durée de conservation</h2>
      <ul>
        <li><strong>Données de compte :</strong> durée de vie du compte + 30 jours après suppression</li>
        <li><strong>Check-ins et données de bien-être :</strong> 12 mois glissants (suppression automatique des données de plus d&apos;un an)</li>
        <li><strong>Logs techniques :</strong> 90 jours maximum</li>
        <li><strong>Données de facturation :</strong> 10 ans (obligation légale)</li>
      </ul>

      <h2>5. Partage des données</h2>
      <p>
        Nous ne vendons, ne louons et ne partageons jamais tes données personnelles à des fins commerciales. Tes
        données peuvent être transmises à :
      </p>
      <ul>
        <li><strong>Supabase</strong> (hébergement BDD, EU Frankfurt), sous-traitant</li>
        <li><strong>Firebase / Google</strong> (notifications push), sous-traitant</li>
        <li><strong>Apple</strong> (authentification Sign in with Apple), sous-traitant</li>
      </ul>
      <p>Tous nos sous-traitants sont liés par des accords de traitement des données conformes au RGPD.</p>

      <h2>6. Tes droits</h2>
      <p>Conformément au RGPD, tu disposes des droits suivants :</p>
      <ul>
        <li><strong>Droit d&apos;accès :</strong> obtenir une copie de tes données</li>
        <li><strong>Droit de rectification :</strong> corriger des données inexactes</li>
        <li><strong>Droit à l&apos;effacement :</strong> supprimer ton compte et tes données (dans les 30 jours)</li>
        <li><strong>Droit à la portabilité :</strong> recevoir tes données dans un format structuré</li>
        <li><strong>Droit d&apos;opposition :</strong> t&apos;opposer à certains traitements</li>
        <li><strong>Droit à la limitation :</strong> limiter le traitement de tes données</li>
      </ul>
      <p>
        Pour exercer ces droits : <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>. Réponse sous 30 jours.
      </p>
      <p>
        Tu peux également introduire une réclamation auprès de la{" "}
        <a href="https://www.cnil.fr" target="_blank" rel="noopener noreferrer">
          CNIL
        </a>
        .
      </p>

      <h2>7. Sécurité</h2>
      <p>Nous mettons en œuvre des mesures de sécurité adaptées :</p>
      <ul>
        <li>Chiffrement des données sensibles (check-ins, sommeil) au repos et en transit (TLS)</li>
        <li>Row Level Security (RLS) activé sur toutes les tables de la base de données</li>
        <li>Accès aux données restreint au strict nécessaire</li>
        <li>Authentification forte requise pour l&apos;accès aux systèmes</li>
      </ul>

      <h2>8. Cookies et traceurs</h2>
      <p>
        L&apos;application mobile kolyb n&apos;utilise pas de cookies. Le site web landing page utilise uniquement
        des cookies techniques strictement nécessaires au fonctionnement du service. Aucun cookie publicitaire ou
        de tracking tiers n&apos;est utilisé.
      </p>

      <h2>9. Modifications de cette politique</h2>
      <p>
        Toute modification significative de cette politique sera notifiée par email avec un délai de préavis de 15
        jours. La date de mise à jour est toujours indiquée en haut de ce document.
      </p>

      <h2>10. Contact</h2>
      <p>
        Pour toute question relative à tes données personnelles :
        <br />
        <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>
      </p>
    </LegalPage>
  );
}
