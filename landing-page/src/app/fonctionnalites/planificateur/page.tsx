import type { Metadata } from "next";
import FeaturePageLayout from "@/components/FeaturePageLayout";
import { getArticleBySlug } from "@/lib/blog";

export const metadata: Metadata = {
  title: "Planificateur et Pomodoro pour freelances · kolyb",
  description:
    "3 priorités par jour, un Pomodoro intégré : le planificateur de kolyb t'aide à avancer sur ce qui compte vraiment, sans te disperser entre 47 tâches.",
  alternates: {
    canonical: "/fonctionnalites/planificateur",
  },
  openGraph: {
    title: "Planificateur et Pomodoro pour freelances · kolyb",
    description: "3 priorités, un Pomodoro intégré : focus assuré pour ta journée d'indépendant.",
    url: "/fonctionnalites/planificateur",
    type: "website",
  },
};

const faqs = [
  {
    q: "Pourquoi seulement 3 priorités par jour ?",
    a: "Parce qu'une liste de 20 tâches ne fait que déplacer la charge mentale, pas l'alléger. En te limitant à 3 priorités réalistes, tu termines tes journées avec le sentiment d'avoir vraiment avancé, pas juste coché des cases.",
  },
  {
    q: "Le Pomodoro est-il obligatoire ?",
    a: "Non, il est là si tu en as besoin. Certaines tâches se font mieux avec un minuteur 25/5 minutes, d'autres non. Tu choisis ce qui te convient au moment où tu en as besoin.",
  },
  {
    q: "Est-ce que ça remplace un outil comme Notion ou Trello ?",
    a: "Ça dépend de ton usage. Le planificateur kolyb n'est pas fait pour documenter ou archiver, il est fait pour structurer ta journée. Beaucoup d'indépendants gardent un outil comme Notion pour la documentation longue et utilisent kolyb pour le rythme quotidien.",
  },
];

export default function PlannerFeaturePage() {
  const related = [getArticleBySlug("notion-vs-kolyb-independant")].filter(
    (a): a is NonNullable<typeof a> => Boolean(a)
  );

  return (
    <FeaturePageLayout
      color="#00D4C8"
      emoji="✅"
      badgeLabel="Ma Journée"
      h1="3 priorités, un Pomodoro : focus assuré"
      subtitle="Arrête de courir après 47 tâches. kolyb t'invite à choisir 3 priorités du jour et te donne un outil Pomodoro intégré pour avancer en douceur, sans te disperser."
      problemParagraphs={[
        "Sans structure imposée de l'extérieur, la journée d'un indépendant se remplit vite d'une liste de tâches qui ne finit jamais. Tout semble urgent, rien ne se termine vraiment, et le sentiment de ne pas avancer s'installe malgré des journées bien chargées.",
        "Le planificateur de kolyb part d'un principe simple : mieux vaut terminer 3 choses qui comptent qu'en commencer 15 sans en finir aucune. Un outil Pomodoro intégré t'aide à tenir le cap sur chacune, sans te forcer à l'utiliser si tu n'en as pas besoin.",
      ]}
      details={[
        "3 tâches prioritaires par jour, pas une de plus",
        "Timer Pomodoro 25/5 minutes intégré, en un clic",
        "Lien possible avec tes projets Kanban en cours",
        "Chaque tâche cochée est célébrée, jamais culpabilisante",
        "Fonctionne même hors connexion",
      ]}
      faqs={faqs}
      relatedArticles={related}
    />
  );
}
