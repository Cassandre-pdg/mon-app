import type { Metadata } from "next";
import FeaturePageLayout from "@/components/FeaturePageLayout";
import { getArticleBySlug } from "@/lib/blog";

export const metadata: Metadata = {
  title: "Le Salon : communauté d'entrepreneurs indépendants · kolyb",
  description:
    "Pas de réseau social anxiogène, pas de compteur de followers. Le Salon réunit des groupes thématiques d'indépendants qui s'entraident et avancent ensemble.",
  alternates: {
    canonical: "/fonctionnalites/le-salon",
  },
  openGraph: {
    title: "Le Salon : communauté d'entrepreneurs indépendants · kolyb",
    description: "Des groupes thématiques d'indépendants qui s'entraident, sans comparaison ni compétition.",
    url: "/fonctionnalites/le-salon",
    type: "website",
  },
};

const faqs = [
  {
    q: "Le Salon est-il un réseau social comme les autres ?",
    a: "Non. Il n'y a pas de compteur de followers public, pas de liste de contacts à exhiber, pas de fil infini pensé pour capter ton attention. Juste des groupes thématiques où des indépendants échangent sincèrement.",
  },
  {
    q: "Combien de posts puis-je publier gratuitement ?",
    a: "3 posts par semaine gratuitement, lecture illimitée. Le plan Pro débloque les posts illimités si tu en as besoin.",
  },
  {
    q: "Comment sont organisés les groupes ?",
    a: "Par thématique : freelance créatif, tech, consultant, et d'autres selon les besoins de la communauté. Tu rejoins ceux qui te ressemblent, tu peux en quitter à tout moment.",
  },
];

export default function CommunityFeaturePage() {
  const related = [getArticleBySlug("comment-lutter-contre-isolement-freelance")].filter(
    (a): a is NonNullable<typeof a> => Boolean(a)
  );

  return (
    <FeaturePageLayout
      color="#FF4D6A"
      emoji="👥"
      badgeLabel="Le Salon"
      h1="Une communauté qui te ressemble"
      subtitle="Pas de réseau social anxiogène, pas de compteur de followers. Le Salon, c'est des groupes thématiques où les entrepreneurs s'entraident, partagent et progressent ensemble, sans se comparer."
      problemParagraphs={[
        "L'isolement est l'un des angles morts les plus sous-estimés du travail en solo. On peut être entouré de clients, de prestataires, de contacts LinkedIn, et se sentir profondément seul·e face aux décisions du quotidien.",
        "Le Salon a été pensé comme l'inverse d'un réseau social classique : pas de course aux followers, pas de flux infini, pas de comparaison. Juste des groupes d'indépendants qui comprennent exactement ce que tu traverses, parce qu'ils le traversent aussi.",
      ]}
      details={[
        "Groupes thématiques : freelance créatif, tech, consultant, et plus",
        "Posts et échanges authentiques, sans pression de performance",
        "Aucun compteur de followers public, aucune liste de contacts affichée",
        "Défi communautaire mensuel pour avancer ensemble",
        "3 posts par semaine gratuits, lecture illimitée",
      ]}
      faqs={faqs}
      relatedArticles={related}
    />
  );
}
