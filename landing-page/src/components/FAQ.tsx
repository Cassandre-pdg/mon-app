"use client";

import { useState, useRef } from "react";
import { motion, AnimatePresence, useInView } from "framer-motion";
import { Plus, Minus } from "lucide-react";

const EASE: [number, number, number, number] = [0.22, 1, 0.36, 1];

const faqs = [
  {
    q: "kolyb est-il vraiment gratuit ?",
    a: "Oui, entièrement. En V1, toutes les fonctionnalités essentielles sont gratuites : check-in, planificateur, Pomodoro, communauté (lecture + 3 posts/semaine), badges et streaks. Le plan Pro (fonctionnalités avancées) arrivera en V2, sans toucher aux fonctions de base.",
  },
  {
    q: "Sur quels appareils puis-je utiliser kolyb ?",
    a: "kolyb est disponible sur iOS (iPhone) et Android. Une version web est prévue pour la V2. Les fonctionnalités essentielles (check-in, planificateur) fonctionnent même hors connexion.",
  },
  {
    q: "Mes données sont-elles en sécurité ?",
    a: "La confidentialité est au cœur de kolyb. Tes données sont hébergées en EU (Frankfurt), conformément au RGPD. Les données sensibles (check-ins émotionnels) sont chiffrées. Nous n'avons jamais revendu et ne revendrons jamais tes données. Tu peux demander la suppression totale de ton compte à tout moment.",
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
    a: "Rien de dramatique, c'est même prévu dans le système. kolyb ne te punit jamais. Si tu rates un jour, tu reçois un message encourageant (jamais culpabilisant). Si tu te relèves dans les 48h, tu gagnes même un bonus de 15 points \"Relevé\". La régularité, pas la perfection.",
  },
  {
    q: "Comment fonctionne Le Salon ?",
    a: "Le Salon est organisé en groupes thématiques (freelance créatif, tech, consultant, etc.). Tu peux lire, réagir et poster (3 posts/semaine gratuit). Il n'y a pas de compteur de followers public, pas de liste de contacts, pas de comparaison. Juste des échanges sincères entre indépendants.",
  },
];

function FAQItem({ q, a, index, isOpen, onToggle }: { q: string; a: string; index: number; isOpen: boolean; onToggle: () => void }) {
  /* Entrée alternée gauche / droite */
  const fromLeft = index % 2 === 0;

  return (
    <motion.div
      initial={{ opacity: 0, x: fromLeft ? -32 : 32, y: 8 }}
      whileInView={{ opacity: 1, x: 0, y: 0 }}
      viewport={{ once: true, margin: "-60px" }}
      transition={{ delay: index * 0.045, duration: 0.55, ease: EASE }}
      className={`faq-item rounded-2xl border transition-all duration-300 overflow-hidden ${
        isOpen
          ? "faq-item-open bg-[#1A1836] border-[#6D28D9]/40"
          : "bg-[#1A1836]/50 border-[#22204A] hover:border-[#6D28D9]/20"
      }`}
      style={isOpen ? { boxShadow: "0 0 40px rgba(109,40,217,0.07)" } : {}}
    >
      <button
        onClick={onToggle}
        className="faq-btn w-full flex items-center gap-5 text-left group cursor-pointer"
      >
        <span className="faq-index">{String(index + 1).padStart(2, "0")}</span>
        <span
          className={`flex-1 text-[15px] font-medium leading-snug transition-colors ${
            isOpen ? "text-white" : "text-[#EDEDFF]/75 group-hover:text-white"
          }`}
        >
          {q}
        </span>
        <motion.span
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.25 }}
          className="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center"
          style={{
            background: isOpen ? "rgba(109,40,217,0.35)" : "rgba(109,40,217,0.1)",
            border: `1px solid ${isOpen ? "rgba(109,40,217,0.5)" : "rgba(109,40,217,0.2)"}`,
          }}
        >
          {isOpen ? (
            <Minus size={14} className="text-[#C4B5FD]" />
          ) : (
            <Plus size={14} className="text-[#8B7FE8]" />
          )}
        </motion.span>
      </button>

      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.28, ease: [0.4, 0, 0.2, 1] }}
            className="overflow-hidden"
          >
            <div className="faq-separator" />
            <p className="faq-answer text-sm text-[#EDEDFF]/65 leading-relaxed">{a}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default function FAQ() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section
      ref={ref}
      id="faq"
      style={{
        position: "relative",
        overflow: "hidden",
        paddingTop: "clamp(100px, 12vw, 140px)",
        paddingBottom: "clamp(100px, 12vw, 140px)",
      }}
    >
      {/* Séparateur — direction inversée encore une fois */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", top: 0, left: 0, right: 0,
          height: 1,
          background: "linear-gradient(90deg, transparent 0%, rgba(0,212,200,0.2) 20%, rgba(109,40,217,0.4) 60%, transparent 100%)",
        }}
      />

      {/* Glow pulsé */}
      <div className="absolute inset-0 pointer-events-none" aria-hidden="true">
        <motion.div
          animate={{ scale: [1, 1.15, 1], opacity: [0.4, 0.85, 0.4] }}
          transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
          style={{
            position: "absolute", top: "50%", left: "50%",
            transform: "translate(-50%,-50%)",
            width: 700, height: 350,
            background: "radial-gradient(ellipse, rgba(109,40,217,0.06) 0%, transparent 70%)",
            filter: "blur(80px)",
          }}
        />
      </div>

      <div className="wrap-md relative z-10">
        {/* En-tête — depuis le centre (centré = pas de direction, effet de centrage) */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: EASE }}
          className="section-header"
        >
          {/* Compteur visuel */}
          <div style={{ display: "flex", justifyContent: "center", marginBottom: 20 }}>
            <div
              style={{
                display: "inline-flex", alignItems: "center", gap: 10,
                padding: "8px 20px", borderRadius: 9999,
                background: "rgba(109,40,217,0.1)",
                border: "1px solid rgba(109,40,217,0.25)",
              }}
            >
              <span style={{ fontSize: 22, fontWeight: 800, color: "#8B7FE8", letterSpacing: "-0.04em" }}>
                {faqs.length}
              </span>
              <span style={{ fontSize: 11, fontWeight: 600, color: "rgba(139,127,232,0.6)", letterSpacing: "0.1em", textTransform: "uppercase" }}>
                questions
              </span>
            </div>
          </div>

          <p className="eyebrow">FAQ</p>
          <h2 className="section-title">
            Tes questions,{" "}
            <span className="text-[#C4B5FD]">nos réponses</span>
          </h2>
          <p className="section-sub">
            Tu as une autre question ? Écris-nous directement en bas de page.
          </p>
        </motion.div>

        <div className="flex flex-col gap-4">
          {faqs.map((faq, i) => (
            <FAQItem
              key={faq.q}
              q={faq.q}
              a={faq.a}
              index={i}
              isOpen={openIndex === i}
              onToggle={() => setOpenIndex(openIndex === i ? null : i)}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
