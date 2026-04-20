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
    a: "kolyb est conçu pour les entrepreneurs indépendants : freelances, consultants, créateurs de contenu, artisans, solopreneurs. Si tu travailles seul·e et que tu veux avancer avec clarté, progresser avec bienveillance et te connecter à une communauté qui te ressemble, kolyb est pour toi.",
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
    a: "Rien de dramatique, c'est même prévu dans le système. kolyb ne te punit jamais. Si tu rates un jour, tu reçois un message encourageant (jamais culpabilisant). Si tu te relèves dans les 48h, tu gagnes même un bonus de 15 points \"Relevé 💪\". La régularité, pas la perfection.",
  },
  {
    q: "Comment fonctionne Le Salon ?",
    a: "Le Salon est organisé en groupes thématiques (freelance créatif, tech, consultant, etc.). Tu peux lire, réagir et poster (3 posts/semaine gratuit). Il n'y a pas de compteur de followers public, pas de liste de contacts, pas de comparaison. Juste des échanges sincères entre indépendants.",
  },
];

function FAQItem({ q, a, index }: { q: string; a: string; index: number }) {
  const [open, setOpen] = useState(false);

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05, duration: 0.4 }}
      className={`faq-item rounded-2xl border transition-all duration-300 overflow-hidden ${
        open
          ? "faq-item-open bg-[#1A1836] border-[#6D28D9]/40"
          : "bg-[#1A1836]/50 border-[#22204A] hover:border-[#6D28D9]/20"
      }`}
      style={open ? { boxShadow: "0 0 40px rgba(109,40,217,0.07)" } : {}}
    >
      <button
        onClick={() => setOpen(!open)}
        className="faq-btn w-full flex items-center gap-5 text-left group cursor-pointer"
      >
        <span className="faq-index">{String(index + 1).padStart(2, "0")}</span>
        <span
          className={`flex-1 text-[15px] font-medium leading-snug transition-colors ${
            open ? "text-white" : "text-[#EDEDFF]/75 group-hover:text-white"
          }`}
        >
          {q}
        </span>
        <span
          className="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-all duration-200"
          style={{
            background: open ? "rgba(109,40,217,0.35)" : "rgba(109,40,217,0.1)",
            border: `1px solid ${open ? "rgba(109,40,217,0.5)" : "rgba(109,40,217,0.2)"}`,
          }}
        >
          {open ? (
            <Minus size={14} className="text-[#C4B5FD]" />
          ) : (
            <Plus size={14} className="text-[#8B7FE8]" />
          )}
        </span>
      </button>

      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25, ease: [0.4, 0, 0.2, 1] }}
            className="overflow-hidden"
          >
            <div className="faq-separator" />
            <p className="faq-answer text-sm text-[#EDEDFF]/65 leading-relaxed">
              {a}
            </p>
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
    <section ref={ref} id="faq" className="section">
      <div className="wrap-md">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="section-header"
        >
          <p className="eyebrow">FAQ</p>
          <h2 className="section-title">
            Tes questions,{" "}
            <span className="text-[#C4B5FD]">nos réponses</span>
          </h2>
          <p className="section-sub">
            Tu as une autre question ? Écris-nous directement en bas de page.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="flex flex-col gap-4"
        >
          {faqs.map((faq, i) => (
            <FAQItem key={faq.q} q={faq.q} a={faq.a} index={i} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
