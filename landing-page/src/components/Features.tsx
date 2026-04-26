"use client";

import { useRef, useState } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";
import { CheckSquare, Timer, Bed, Users, Trophy } from "lucide-react";

const features = [
  {
    id: "checkin",
    icon: CheckSquare,
    color: "#FFB800",
    label: "Mon Check-in",
    title: "2 minutes le matin, 2 minutes le soir",
    description:
      "Commence ta journée avec clarté et termine-la avec recul. Ton check-in émotionnel t'aide à repérer tes patterns, célébrer les petites victoires et prendre soin de toi sans pression.",
    details: [
      "3 questions simples matin & soir",
      "Suivi de ton humeur dans le temps",
      "Inspirations du jour adaptées à ton état",
    ],
    emoji: "🌅",
  },
  {
    id: "planner",
    icon: CheckSquare,
    color: "#00D4C8",
    label: "Ma Journée",
    title: "3 priorités, un Pomodoro : focus assuré",
    description:
      "Arrête de courir après 47 tâches. kolyb t'invite à choisir 3 priorités du jour et te donne un outil Pomodoro intégré pour avancer en douceur, sans te disperser.",
    details: [
      "Planificateur 3 tâches journalières",
      "Timer Pomodoro 25/5 min intégré",
      "Belle avancée ! célébré à chaque tâche cochée",
    ],
    emoji: "✅",
  },
  {
    id: "sleep",
    icon: Bed,
    color: "#C4B5FD",
    label: "Mon Sommeil",
    title: "Ton sommeil, ton carburant",
    description:
      "Les indépendants sous-estiment l'impact du sommeil sur leur créativité et leur énergie. kolyb te permet de suivre tes nuits simplement, sans gadget, et de voir les tendances qui font la différence.",
    details: [
      "Saisie manuelle en quelques secondes",
      "Graphiques de tendance clairs",
      "Lien avec ton humeur du check-in",
    ],
    emoji: "😴",
  },
  {
    id: "community",
    icon: Users,
    color: "#FF4D6A",
    label: "Le Salon",
    title: "Une communauté qui te ressemble",
    description:
      "Pas de réseau social anxiogène, pas de compteur de followers. Le Salon, c'est des groupes thématiques où les entrepreneurs s'entraident, partagent et progressent ensemble, sans se comparer.",
    details: [
      "Groupes thématiques (freelance, créatif, tech…)",
      "Posts & échanges authentiques",
      "Pas de followers publics, pas de compétition",
    ],
    emoji: "👥",
  },
  {
    id: "rewards",
    icon: Trophy,
    color: "#FFB800",
    label: "Mes Badges",
    title: "La régularité récompensée, jamais punie",
    description:
      "Chaque jour où tu avances compte. kolyb célèbre ta régularité avec des badges et des streaks, et si tu rates un jour, le message est toujours bienveillant. Tu te relèves, kolyb est là.",
    details: [
      "Streaks 3j → 7j → 30j → 365j",
      "Niveaux Explorateur à Visionnaire",
      "+15 pts bonus si tu te relèves après un raté",
    ],
    emoji: "🏆",
  },
];

export default function Features() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });
  const [active, setActive] = useState(0);
  const [direction, setDirection] = useState(1);
  const [prev, setPrev] = useState(0);

  const handleTabClick = (i: number) => {
    setDirection(i > active ? 1 : -1);
    setPrev(active);
    setActive(i);
  };

  const f = features[active];

  return (
    <section ref={ref} id="features" className="section" style={{ position: "relative", overflow: "hidden" }}>
      {/* BG glow */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden" aria-hidden="true">
        <motion.div
          animate={{ x: [0, 30, 0], y: [0, -20, 0] }}
          transition={{ duration: 12, repeat: Infinity, ease: "easeInOut" }}
          className="absolute top-1/2 left-0 w-[600px] h-[600px] bg-[#6D28D9]/8 rounded-full blur-[130px]"
        />
      </div>

      <div className="wrap relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="section-header"
        >
          <p className="eyebrow">Fonctionnalités</p>
          <h2 className="section-title">
            Tout ce qu&apos;il te faut,{" "}
            <span className="gradient-text">en un seul endroit</span>
          </h2>
          <p className="section-sub">
            5 modules pensés pour le quotidien des indépendants. Simples, efficaces, bienveillants.
          </p>
        </motion.div>

        {/* Tab pills */}
        <div className="badge-feat flex flex-wrap justify-center gap-2.5 mb-14">
          {features.map((feat, i) => (
            <motion.button
              key={feat.id}
              initial={{ opacity: 0, y: 10 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: i * 0.08, ease: [0.22, 1, 0.36, 1] }}
              onClick={() => handleTabClick(i)}
              whileHover={{ scale: 1.04 }}
              whileTap={{ scale: 0.97 }}
              className={`feature-tab flex items-center gap-2.5 text-sm font-medium transition-all duration-200 cursor-pointer ${
                active === i
                  ? "bg-[#6D28D9] text-white shadow-lg shadow-purple-900/30"
                  : "bg-[#1A1836] text-[#EDEDFF]/55 hover:text-white border border-[#22204A] hover:border-[#6D28D9]/40"
              }`}
            >
              <span>{feat.emoji}</span>
              {feat.label}
            </motion.button>
          ))}
        </div>

        {/* Feature detail — animated on tab switch */}
        <AnimatePresence mode="wait">
          <motion.div
            key={active}
            initial={{ opacity: 0, x: direction * 40 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: direction * -40 }}
            transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
            className="grid md:grid-cols-2 gap-10 items-center"
          >
            {/* Text side */}
            <div className="order-2 md:order-1 flex flex-col gap-6">
              <div>
                <motion.span
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.1 }}
                  className="badge mb-5"
                  style={{
                    background: `${f.color}18`,
                    color: f.color,
                    border: `1px solid ${f.color}30`,
                    fontSize: "11px",
                    letterSpacing: "0.08em",
                    textTransform: "uppercase",
                    fontWeight: 600,
                  }}
                >
                  {f.label}
                </motion.span>
                <motion.h3
                  initial={{ opacity: 0, y: 12 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.15 }}
                  className="text-3xl md:text-4xl font-bold text-white leading-tight mt-4"
                  style={{ letterSpacing: "-0.02em" }}
                >
                  {f.title}
                </motion.h3>
              </div>
              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.2 }}
                className="text-[#EDEDFF]/60 leading-relaxed text-[15px]"
              >
                {f.description}
              </motion.p>
              <ul className="flex flex-col gap-3.5">
                {f.details.map((d, di) => (
                  <motion.li
                    key={d}
                    initial={{ opacity: 0, x: -16 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.25 + di * 0.08 }}
                    className="flex items-start gap-3 text-sm text-[#EDEDFF]/75"
                  >
                    <span
                      className="mt-0.5 w-5 h-5 rounded-full flex-shrink-0 flex items-center justify-center text-xs font-bold"
                      style={{ background: `${f.color}20`, color: f.color }}
                    >
                      ✓
                    </span>
                    {d}
                  </motion.li>
                ))}
              </ul>
            </div>

            {/* Visual card side */}
            <div className="order-1 md:order-2">
              <motion.div
                whileHover={{ scale: 1.02, rotate: 1 }}
                transition={{ duration: 0.35 }}
                className="relative rounded-3xl p-10 bg-[#1A1836] border border-[#22204A] overflow-hidden min-h-[320px] flex items-center justify-center"
                style={{ boxShadow: `0 0 80px ${f.color}18` }}
              >
                {/* Radial glow */}
                <motion.div
                  animate={{ opacity: [0.15, 0.3, 0.15] }}
                  transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                  className="absolute inset-0 rounded-3xl"
                  style={{
                    background: `radial-gradient(circle at 50% 50%, ${f.color}, transparent 70%)`,
                  }}
                />
                {/* Orbiting ring */}
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                  className="absolute w-48 h-48 rounded-full"
                  style={{
                    border: `1px dashed ${f.color}30`,
                  }}
                />
                <div className="relative z-10 text-center">
                  <motion.div
                    animate={{ y: [0, -8, 0] }}
                    transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                    className="text-7xl mb-6 select-none"
                    style={{ filter: "drop-shadow(0 0 24px rgba(255,255,255,0.2))" }}
                  >
                    {f.emoji}
                  </motion.div>
                  <p
                    className="text-2xl font-bold"
                    style={{ color: f.color, letterSpacing: "-0.01em" }}
                  >
                    {f.label}
                  </p>
                  <p className="text-[#EDEDFF]/35 text-sm mt-2">Disponible en V1</p>
                </div>
              </motion.div>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>
    </section>
  );
}
