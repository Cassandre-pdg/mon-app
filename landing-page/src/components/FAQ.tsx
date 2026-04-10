"use client";

import { useState, useRef } from "react";
import { motion, AnimatePresence, useInView } from "framer-motion";
import { Plus, Minus } from "lucide-react";

const faqs = [
  {
    q: "kolyb est-il vraiment gratuit ?",
    a: "Oui, entièrement. En V1, toutes les fonctionnalités essentielles sont gratuites : check-in, planificateur, Pomodoro, tracker sommeil, communauté (lecture + 3 posts/semaine), badges et streaks. Le plan Pro (fonctionnalités avancées) arrivera en V2, sans toucher aux fonctions de base.",
  },
  {
    q: "Sur quels appareils puis-je utiliser kolyb ?",
    a: "kolyb est disponible sur iOS (iPhone) et Android. Une version web est prévue pour la V2. Les fonctionnalités essentielles (check-in, planificateur, sommeil) fonctionnent même hors connexion.",
  },
  {
    q: "Mes données sont-elles en sécurité ?",
    a: "La confidentialité est au cœur de kolyb. Tes données sont hébergées en France (EU Frankfurt), conformément au RGPD. Les données sensibles (check-ins émotionnels, sommeil) sont chiffrées. Nous n'avons jamais revendu et ne revendrons jamais tes données. Tu peux demander la suppression totale de ton compte à tout moment.",
  },
  {
    q: "À qui s'adresse kolyb exactement ?",
    a: "kolyb est conçu pour les entrepreneurs indépendants : freelances, consultants, créateurs de contenu, artisans, solopreneurs. Si tu travailles seul·e et que tu veux avancer avec clarté, progresser avec bienveillance et te connecter à une communauté qui te ressemble — kolyb est pour toi.",
  },
  {
    q: "Qu'est-ce qui différencie kolyb d'autres apps de productivité ?",
    a: "kolyb n'est pas une app de productivité générique. C'est un compagnon pensé pour la réalité des indépendants : l'isolement, la gestion de l'énergie, le besoin de connection et de reconnaissance. L'approche est bienveillante (jamais punitive), les fonctions sont intégrées (pas 5 apps différentes), et la communauté est qualitative (pas de réseau social anxiogène).",
  },
  {
    q: "Quand kolyb sera-t-il disponible ?",
    a: "La beta est prévue pour mi-2025. Les premiers inscrits sur la liste d'attente auront un accès prioritaire. En t'inscrivant maintenant, tu rejoins les pionniers qui vont façonner l'app avec nous.",
  },
  {
    q: "Que se passe-t-il si je rate un jour de check-in ?",
    a: "Rien de dramatique — c'est même prévu dans le système. kolyb ne te punit jamais. Si tu rates un jour, tu reçois un message encourageant (jamais culpabilisant). Si tu te relèves dans les 48h, tu gagnes même un bonus de 15 points \"Relevé 💪\". La régularité, pas la perfection.",
  },
  {
    q: "Comment fonctionne la communauté Ma Tribu ?",
    a: "Ma Tribu est organisée en groupes thématiques (freelance créatif, tech, consultant, etc.). Tu peux lire, réagir et poster (3 posts/semaine gratuit). Il n'y a pas de compteur de followers public, pas de liste de contacts, pas de comparaison. Juste des échanges sincères entre indépendants.",
  },
];

function FAQItem({ q, a, index }: { q: string; a: string; index: number }) {
  const [open, setOpen] = useState(false);

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05, duration: 0.4 }}
      className="border-b border-[#22204A] last:border-0"
    >
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between py-5 text-left gap-4 group"
      >
        <span className="text-base font-medium text-[#EDEDFF]/90 group-hover:text-white transition-colors">
          {q}
        </span>
        <span
          className="flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center transition-all duration-200"
          style={{
            background: open ? "rgba(109,40,217,0.3)" : "rgba(109,40,217,0.12)",
            border: "1px solid rgba(109,40,217,0.3)",
          }}
        >
          {open ? (
            <Minus size={14} className="text-[#8B7FE8]" />
          ) : (
            <Plus size={14} className="text-[#8B7FE8]" />
          )}
        </span>
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25, ease: [0.4, 0, 0.2, 1] }}
            className="overflow-hidden"
          >
            <p className="text-sm text-[#EDEDFF]/55 leading-relaxed pb-5">{a}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default function FAQ() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <section ref={ref} id="faq" className="py-32 px-8 relative">
      <div className="max-w-3xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="text-xs font-semibold text-[#8B7FE8] uppercase tracking-[0.1em] mb-4">
            FAQ
          </p>
          <h2
            className="text-4xl md:text-5xl font-bold text-white mb-4"
            style={{ letterSpacing: "-0.02em" }}
          >
            Tes questions,{" "}
            <span className="text-[#C4B5FD]">nos réponses</span>
          </h2>
          <p className="text-lg text-[#EDEDFF]/60">
            Tu as une autre question ? Écris-nous directement en bas de page.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="rounded-2xl bg-[#1A1836] border border-[#22204A] px-6 divide-y-0"
        >
          {faqs.map((faq, i) => (
            <FAQItem key={faq.q} q={faq.q} a={faq.a} index={i} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
