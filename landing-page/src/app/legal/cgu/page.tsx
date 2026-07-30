import type { Metadata } from "next";
import LegalPage from "@/components/LegalPage";

export const metadata: Metadata = {
  title: "Conditions générales d'utilisation · kolyb",
  description: "Conditions Générales d'Utilisation de l'application kolyb.",
  alternates: {
    canonical: "/legal/cgu",
  },
  openGraph: {
    title: "Conditions générales d'utilisation · kolyb",
    description: "Conditions Générales d'Utilisation de l'application kolyb.",
    url: "/legal/cgu",
    type: "website",
  },
};

export default function CguPage() {
  return (
    <LegalPage tag="Légal" title="Conditions générales d'utilisation" lastUpdated="avril 2026">
      <div className="legal-highlight">
        kolyb est un outil de bien-être, pas un dispositif médical. Si tu traverses une période difficile,
        n&apos;hésite pas à consulter un professionnel de santé.
      </div>

      <h2>1. Objet</h2>
      <p>
        Les présentes Conditions Générales d&apos;Utilisation (CGU) régissent l&apos;accès et l&apos;utilisation de
        l&apos;application mobile et du site web kolyb, édités par Cassandre Rollet, entreprise individuelle
        immatriculée en France.
      </p>
      <p>
        En téléchargeant, installant ou utilisant kolyb, tu acceptes sans réserve les présentes CGU. Si tu
        n&apos;acceptes pas ces conditions, tu ne dois pas utiliser le service.
      </p>

      <h2>2. Description du service</h2>
      <p>
        kolyb est une application de bien-être, de productivité et de mise en réseau dédiée aux entrepreneurs
        indépendants et freelances. Elle propose notamment :
      </p>
      <ul>
        <li>Un check-in émotionnel matin et soir</li>
        <li>Un planificateur de journée (3 priorités)</li>
        <li>Un outil Pomodoro</li>
        <li>Un suivi du sommeil</li>
        <li>Une communauté thématique (Le Salon)</li>
        <li>Un système de badges et de streaks</li>
      </ul>

      <h2>3. Accès et inscription</h2>
      <p>
        L&apos;accès à kolyb nécessite la création d&apos;un compte utilisateur. Tu dois avoir au moins 18 ans pour
        t&apos;inscrire. Tu t&apos;engages à fournir des informations exactes et à maintenir la confidentialité de
        tes identifiants.
      </p>
      <p>Kolyb se réserve le droit de suspendre ou de supprimer tout compte en cas de violation des présentes CGU.</p>

      <h2>4. Utilisation acceptable</h2>
      <p>Tu t&apos;engages à utiliser kolyb de manière licite et respectueuse. Il est notamment interdit de :</p>
      <ul>
        <li>Publier du contenu illicite, diffamatoire, haineux ou portant atteinte à la vie privée d&apos;autrui</li>
        <li>Utiliser kolyb à des fins commerciales non autorisées</li>
        <li>Tenter de contourner les mesures de sécurité de l&apos;application</li>
        <li>Partager les identifiants de ton compte avec des tiers</li>
        <li>Collecter des données sur d&apos;autres utilisateurs sans leur consentement</li>
      </ul>

      <h2>5. Contenu utilisateur</h2>
      <p>
        Tu restes propriétaire du contenu que tu publies sur kolyb (posts, check-ins, données personnelles). En
        publiant du contenu, tu accordes à kolyb une licence non-exclusive, mondiale et gratuite d&apos;utilisation
        dans le cadre du fonctionnement du service.
      </p>
      <p>
        Tu es seul·e responsable du contenu que tu publies. Kolyb ne saurait être tenu responsable du contenu généré
        par les utilisateurs.
      </p>

      <h2>6. Données personnelles</h2>
      <p>
        La collecte et le traitement de tes données personnelles sont décrits dans notre{" "}
        <a href="/legal/confidentialite">Politique de Confidentialité</a>. Kolyb respecte le Règlement Général sur
        la Protection des Données (RGPD).
      </p>

      <h2>7. Propriété intellectuelle</h2>
      <p>
        L&apos;application kolyb, son logo, ses textes, ses graphiques et son code source sont protégés par les
        droits de propriété intellectuelle. Toute reproduction, même partielle, est interdite sans autorisation
        préalable écrite.
      </p>

      <h2>8. Disponibilité du service</h2>
      <p>
        Kolyb s&apos;efforce d&apos;assurer la disponibilité du service 24h/24 et 7j/7, mais ne peut garantir une
        accessibilité ininterrompue. Des interruptions de service peuvent survenir pour maintenance ou pour des
        raisons indépendantes de notre volonté.
      </p>

      <h2>9. Modifications des CGU</h2>
      <p>
        Kolyb peut modifier les présentes CGU à tout moment. Les changements significatifs seront notifiés par
        email ou par notification dans l&apos;application. La poursuite de l&apos;utilisation du service après
        notification vaut acceptation des nouvelles CGU.
      </p>

      <h2>10. Résiliation</h2>
      <p>
        Tu peux supprimer ton compte à tout moment depuis les Paramètres de l&apos;application. La suppression
        entraîne l&apos;effacement définitif de tes données personnelles dans un délai de 30 jours.
      </p>

      <h2>11. Limitation de responsabilité</h2>
      <p>
        Kolyb est un outil de bien-être et de productivité. Il ne constitue en aucun cas un dispositif médical, un
        service de santé mentale ou un service de conseil professionnel. Kolyb décline toute responsabilité en cas
        de préjudice direct ou indirect résultant de l&apos;utilisation du service.
      </p>

      <h2>12. Droit applicable et juridiction</h2>
      <p>
        Les présentes CGU sont soumises au droit français. En cas de litige, une solution amiable sera recherchée en
        priorité. À défaut, les tribunaux compétents de Paris seront saisis.
      </p>

      <h2>13. Contact</h2>
      <p>
        Pour toute question relative aux présentes CGU, contacte-nous à :{" "}
        <a href="mailto:contact@kolyb.app">contact@kolyb.app</a>
      </p>
    </LegalPage>
  );
}
