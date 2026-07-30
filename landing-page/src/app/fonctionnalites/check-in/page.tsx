import type { Metadata } from "next";
import FeaturePageLayout from "@/components/FeaturePageLayout";
import { getArticleBySlug } from "@/lib/blog";

export const metadata: Metadata = {
  title: "Check-in émotionnel quotidien pour indépendants · kolyb",
  description:
    "2 minutes le matin, 2 minutes le soir : le check-in émotionnel de kolyb t'aide à repérer tes patterns et prendre soin de toi, sans pression, sans jugement.",
  alternates: {
    canonical: "/fonctionnalites/check-in",
  },
  openGraph: {
    title: "Check-in émotionnel quotidien pour indépendants · kolyb",
    description:
      "2 minutes le matin, 2 minutes le soir pour prendre le pouls de ta journée, sans pression.",
    url: "/fonctionnalites/check-in",
    type: "website",
  },
};

const faqs = [
  {
    q: "En quoi consiste le check-in émotionnel de kolyb ?",
    a: "Trois questions simples, matin et soir : comment tu te sens, ce que tu veux retenir de ta journée, et ce dont tu as besoin. Deux minutes suffisent, aucune réponse n'est jugée.",
  },
  {
    q: "Que se passe-t-il si je rate un jour ?",
    a: "Rien de dramatique, c'est même prévu dans le système. kolyb ne punit jamais un jour manqué : tu reçois un message encourageant, jamais culpabilisant. Si tu te relèves dans les 48h, tu gagnes même un bonus de points.",
  },
  {
    q: "Mes réponses sont-elles vues par d'autres personnes ?",
    a: "Non. Ton check-in est strictement personnel et chiffré. Rien n'est partagé dans Le Salon ni visible par qui que ce soit d'autre.",
  },
];

export default function CheckinFeaturePage() {
  const related = [
    getArticleBySlug("comment-lutter-contre-isolement-freelance"),
    getArticleBySlug("signes-epuisement-entrepreneur-solo"),
  ].filter((a): a is NonNullable<typeof a> => Boolean(a));

  return (
    <FeaturePageLayout
      color="#FFB800"
      emoji="🌅"
      badgeLabel="Check-in émotionnel"
      h1="2 minutes le matin, 2 minutes le soir"
      subtitle="Commence ta journée avec clarté et termine-la avec du recul. Le check-in émotionnel de kolyb t'aide à repérer tes patterns et à prendre soin de toi, sans pression."
      problemParagraphs={[
        "Quand on est indépendant, personne ne demande comment on va. Pas de collègue pour le remarquer, pas de manager pour s'en inquiéter. Résultat : on avance souvent plusieurs jours, parfois plusieurs semaines, sans vraiment prendre le pouls de son propre état.",
        "Le check-in émotionnel de kolyb comble ce manque avec un rituel simple : deux minutes le matin pour te fixer une intention, deux minutes le soir pour prendre du recul sur ta journée. Rien de compliqué, juste assez pour repérer une tendance avant qu'elle ne s'installe.",
      ]}
      details={[
        "3 questions simples matin et soir, deux minutes suffisent",
        "Suivi de ton humeur dans le temps, pour repérer les tendances",
        "Inspirations du jour adaptées à ton état émotionnel",
        "Données sensibles chiffrées, hébergées en Europe (RGPD)",
        "Régularité récompensée, jamais de jugement si tu rates un jour",
      ]}
      faqs={faqs}
      relatedArticles={related}
    />
  );
}
