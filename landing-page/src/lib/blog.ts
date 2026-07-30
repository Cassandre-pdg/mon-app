export type BlogBlock =
  | { type: "p"; text: string }
  | { type: "h2"; text: string }
  | { type: "h3"; text: string }
  | { type: "list"; items: string[] }
  | { type: "quote"; text: string };

export interface BlogArticle {
  slug: string;
  title: string;
  description: string;
  category: string;
  readingTime: string;
  publishedAt: string;
  content: BlogBlock[];
  relatedFeatureHref?: string;
  relatedFeatureLabel?: string;
}

export const blogArticles: BlogArticle[] = [
  {
    slug: "comment-lutter-contre-isolement-freelance",
    title: "Comment lutter contre l'isolement quand on est freelance",
    description:
      "L'isolement touche la majorité des indépendants, tôt ou tard. Voici pourquoi il s'installe, comment le repérer, et des pistes concrètes pour reconnecter sans sacrifier ta liberté.",
    category: "Bien-être",
    readingTime: "6 min",
    publishedAt: "2026-07-30",
    relatedFeatureHref: "/fonctionnalites/le-salon",
    relatedFeatureLabel: "Découvrir Le Salon",
    content: [
      {
        type: "p",
        text: "Tu t'es lancé·e en solo pour la liberté : choisir tes horaires, tes clients, ton rythme. Personne ne te prévient qu'avec cette liberté vient souvent un autre invité, plus discret : l'isolement. Il ne frappe pas à la porte le premier jour. Il s'installe petit à petit, entre deux appels clients et trois soirées passées seul·e devant ton ordinateur.",
      },
      {
        type: "h2",
        text: "Pourquoi l'isolement s'installe aussi vite",
      },
      {
        type: "p",
        text: "En entreprise, la vie sociale se construit presque toute seule : pause café, déjeuner en équipe, débrief du vendredi. En solo, rien de tout ça n'existe par défaut. Il faut le créer, et c'est justement ce qu'on oublie de faire quand on est débordé·e.",
      },
      {
        type: "list",
        items: [
          "Aucun collègue pour partager une victoire ou une galère du jour",
          "Des journées entières sans une seule interaction non professionnelle",
          "Toute la charge mentale de l'activité portée seul·e, sans relais",
          "Une comparaison permanente aux réussites affichées des autres sur les réseaux",
        ],
      },
      {
        type: "h2",
        text: "Les signaux à repérer avant que ça pèse trop",
      },
      {
        type: "p",
        text: "L'isolement ne se présente pas toujours comme de la solitude évidente. Il se cache souvent derrière d'autres symptômes, plus faciles à ignorer.",
      },
      {
        type: "list",
        items: [
          "Ta motivation baisse sans raison précise",
          "Tu procrastines plus qu'avant sur des tâches simples",
          "Tu repousses les sorties ou les appels, même avec des proches",
          "Tu ne partages plus tes réussites avec personne, elles restent dans ta tête",
        ],
      },
      {
        type: "h2",
        text: "Des pistes concrètes, à ton rythme",
      },
      {
        type: "h3",
        text: "Structurer un minimum de rituel social",
      },
      {
        type: "p",
        text: "Pas besoin de réinventer ta semaine. Un déjeuner récurrent avec un autre indépendant, une session de coworking hebdomadaire, ou simplement un appel vocal avec un proche pendant ta pause : l'objectif est la régularité, pas l'intensité.",
      },
      {
        type: "h3",
        text: "Rejoindre une communauté qui te ressemble",
      },
      {
        type: "p",
        text: "Ce qui manque le plus en solo, ce n'est pas du contenu ou des conseils, c'est un endroit où d'autres indépendants comprennent exactement ce que tu traverses, sans avoir à tout expliquer depuis le début. C'est exactement ce que Le Salon propose dans kolyb : des groupes thématiques d'indépendants, sans compteur de followers ni comparaison, juste des échanges sincères.",
      },
      {
        type: "h3",
        text: "Se tenir responsable sans se juger",
      },
      {
        type: "p",
        text: "Un rituel simple aide à rompre l'isolement intérieur avant même de sortir de chez toi : prendre deux minutes matin et soir pour nommer où tu en es, ce qui va et ce qui coince. C'est le principe du check-in émotionnel de kolyb. Rien de dramatique si tu rates un jour, l'idée est la régularité, pas la perfection.",
      },
      {
        type: "quote",
        text: "Tu n'as pas à choisir entre ta liberté d'indépendant·e et le besoin d'être entouré·e. Les deux peuvent avancer ensemble.",
      },
      {
        type: "h2",
        text: "Avancer, mais jamais seul·e",
      },
      {
        type: "p",
        text: "L'isolement n'est pas une fatalité du statut d'indépendant, c'est un angle mort qu'on peut corriger avec quelques habitudes simples et le bon entourage. kolyb a été pensé pour ça : réunir la structure dont tu as besoin pour avancer et la communauté qui te rappelle que tu n'es pas seul·e à vivre ce que tu vis.",
      },
    ],
  },
  {
    slug: "notion-vs-kolyb-independant",
    title: "Notion vs kolyb : quelle différence pour un indépendant ?",
    description:
      "Notion est puissant, mais généraliste. Voici ce qui différencie vraiment kolyb pour un entrepreneur solo qui cherche à avancer sans passer des heures à construire son propre système.",
    category: "Comparatif",
    readingTime: "5 min",
    publishedAt: "2026-07-30",
    relatedFeatureHref: "/fonctionnalites/planificateur",
    relatedFeatureLabel: "Découvrir le planificateur",
    content: [
      {
        type: "p",
        text: "Notion revient dans presque toutes les conversations sur l'organisation des indépendants, et pour de bonnes raisons. Mais Notion et kolyb ne répondent pas au même besoin, et comprendre la différence t'évite de perdre du temps à comparer deux outils qui ne jouent pas dans la même catégorie.",
      },
      {
        type: "h2",
        text: "Deux outils, deux philosophies",
      },
      {
        type: "p",
        text: "Notion part d'une page blanche. C'est un espace de travail entièrement modulable : tu construis toi-même tes bases de données, tes vues, tes automatisations. kolyb part de l'inverse : une structure déjà pensée pour la réalité d'un indépendant, prête à l'emploi dès le premier jour.",
      },
      {
        type: "h2",
        text: "Ce que Notion fait très bien",
      },
      {
        type: "list",
        items: [
          "Une flexibilité quasi infinie pour documenter, planifier, archiver",
          "Un bon outil pour centraliser des notes, contrats, bases de connaissances",
          "Un écosystème de templates créés par la communauté",
        ],
      },
      {
        type: "h2",
        text: "Là où Notion demande du travail en plus",
      },
      {
        type: "p",
        text: "Cette flexibilité a un prix : il faut construire son propre système avant de pouvoir s'en servir. Beaucoup d'indépendants passent des heures, parfois des semaines, à ajuster leur Notion plutôt qu'à avancer sur leur activité. Et surtout, Notion reste un outil de productivité pure : rien pour le suivi émotionnel, rien pour la communauté, rien pour prévenir l'épuisement.",
      },
      {
        type: "h2",
        text: "Ce que kolyb propose différemment",
      },
      {
        type: "h3",
        text: "Une structure déjà prête",
      },
      {
        type: "p",
        text: "Check-in du matin et du soir, planificateur du jour, projets, habitudes : tout est déjà en place. Tu n'as rien à construire, tu commences à avancer dès l'installation.",
      },
      {
        type: "h3",
        text: "Le bien-être intégré, pas ajouté après coup",
      },
      {
        type: "p",
        text: "Dans kolyb, le suivi émotionnel n'est pas une extension bricolée, c'est le point de départ. La régularité est valorisée, jamais punie : un jour raté n'efface rien de ta progression.",
      },
      {
        type: "h3",
        text: "Une communauté d'indépendants, pas un réseau social anxiogène",
      },
      {
        type: "p",
        text: "Notion n'a pas de communauté intégrée. kolyb, si : Le Salon réunit des indépendants par thématique, sans compteur de followers ni comparaison, pour échanger sur ce qu'on vit vraiment en solo.",
      },
      {
        type: "h2",
        text: "Faut-il choisir l'un ou l'autre ?",
      },
      {
        type: "p",
        text: "Pas forcément. Beaucoup d'indépendants gardent Notion pour la documentation longue (contrats, bases de connaissances, archives) et utilisent kolyb pour le rythme quotidien : ce qui doit avancer aujourd'hui, comment tu te sens, et qui peut te comprendre quand ça devient difficile.",
      },
      {
        type: "quote",
        text: "kolyb n'est pas une app de productivité générique, c'est un compagnon pensé pour la réalité des indépendants : l'isolement, la gestion de l'énergie, le besoin de reconnaissance.",
      },
    ],
  },
  {
    slug: "signes-epuisement-entrepreneur-solo",
    title: "Les signes d'épuisement à repérer quand on est entrepreneur solo",
    description:
      "Le surmenage chez les indépendants s'installe progressivement, sans collègue ni manager pour tirer la sonnette d'alarme. Voici les signaux à ne pas ignorer, et comment reprendre pied.",
    category: "Bien-être",
    readingTime: "6 min",
    publishedAt: "2026-07-30",
    relatedFeatureHref: "/fonctionnalites/check-in",
    relatedFeatureLabel: "Découvrir le check-in",
    content: [
      {
        type: "p",
        text: "En entreprise, quelqu'un finit toujours par remarquer que tu tiens moins bien le rythme : un manager, un collègue, les RH. En solo, ce filet de sécurité n'existe pas. L'épuisement s'installe en silence, et c'est souvent toi-même, bien plus tard que tu ne le voudrais, qui finis par t'en rendre compte.",
      },
      {
        type: "h2",
        text: "Les signaux physiques",
      },
      {
        type: "list",
        items: [
          "Une fatigue qui ne part pas, même après une nuit correcte",
          "Un sommeil qui se dégrade, avec du mal à décrocher le soir",
          "Des tensions physiques nouvelles : mâchoire serrée, maux de tête, dos noué",
          "Une baisse d'appétit ou, à l'inverse, un grignotage compulsif",
        ],
      },
      {
        type: "h2",
        text: "Les signaux mentaux et émotionnels",
      },
      {
        type: "list",
        items: [
          "Une irritabilité qui ressort pour des détails habituellement insignifiants",
          "Une difficulté à te concentrer plus de quelques minutes d'affilée",
          "Un sentiment de ne jamais vraiment souffler, même en pause",
          "Une perte de sens progressive sur des tâches que tu aimais avant",
        ],
      },
      {
        type: "h2",
        text: "Pourquoi c'est plus difficile à voir en solo",
      },
      {
        type: "p",
        text: "Sans horaires imposés, la frontière entre travail et repos s'efface facilement. Sans collègue, personne ne compare ton rythme d'aujourd'hui à celui d'il y a trois mois. Et sans revenu garanti, la tentation de pousser encore un peu plus fort est presque toujours plus forte que celle de ralentir.",
      },
      {
        type: "h2",
        text: "Que faire concrètement",
      },
      {
        type: "h3",
        text: "Remettre un rituel d'écoute de soi",
      },
      {
        type: "p",
        text: "Prendre deux minutes chaque matin et chaque soir pour nommer honnêtement comment tu te sens change beaucoup de choses. C'est plus facile de repérer une tendance qui se dégrade sur plusieurs jours quand elle est notée quelque part, plutôt que gardée uniquement dans ta tête.",
      },
      {
        type: "h3",
        text: "Accepter de ralentir sans culpabiliser",
      },
      {
        type: "p",
        text: "Ralentir n'est pas un échec. Un jour où tu avances moins n'efface rien de ce que tu as déjà construit. La régularité compte plus que l'intensité d'une seule journée.",
      },
      {
        type: "h3",
        text: "Ne pas rester seul·e avec ça",
      },
      {
        type: "p",
        text: "Parler de ce que tu traverses à d'autres indépendants qui vivent la même réalité aide à remettre les choses en perspective, sans jugement. C'est souvent plus simple avec des pairs qu'avec un entourage qui ne connaît pas les codes du solo.",
      },
      {
        type: "quote",
        text: "Si tu rates un jour, rien de dramatique. kolyb ne punit jamais : tu reçois un message encourageant, jamais culpabilisant. La régularité, pas la perfection.",
      },
      {
        type: "h2",
        text: "Un dernier mot important",
      },
      {
        type: "p",
        text: "kolyb est un outil de bien-être, pas un dispositif médical. Si tu traverses une période difficile qui dure, n'hésite pas à en parler à un professionnel de santé : c'est une étape complémentaire, pas un aveu d'échec.",
      },
    ],
  },
];

export function getAllArticles(): BlogArticle[] {
  return [...blogArticles].sort(
    (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime()
  );
}

export function getArticleBySlug(slug: string): BlogArticle | undefined {
  return blogArticles.find((a) => a.slug === slug);
}
