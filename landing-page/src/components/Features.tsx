"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef, useState } from "react";
import { CheckSquare, Timer, Bed, Users, Trophy } from "lucide-react";

const features = [
  {
    id: "checkin",
    icon: CheckSquare,
    color: "#FFB800",
    label: "Mon Check-in",
    title: "2 minutes le matin, 2 minutes le soir",
    description:
      "Commence ta journée avec clarté et termine-la avec recul. Ton check-in émotionnel t'aide à repérer tes patterns, célébrer tes petites victoires et prendre soin de toi sans pression.",
    details: ["3 questions simples matin & soir", "Suivi de ton humeur dans le temps", "Inspirations du jour adaptées à ton état"],
    emoji: "🌅",
  },
  {
    id: "planner",
    icon: CheckSquare,
    iconRight: Timer,
    color: "#00D4C8",
    colorRight: "#6D28D9",
    label: "Ma Journée",
    title: "3 priorités, un Pomodoro — focus assuré",
    description:
      "Arrête de courir après 47 tâches. kolyb t'invite à choisir 3 priorités du jour et te donne un outil Pomodoro intégré pour avancer en douceur, sans te disperser.",
    details: ["Planificateur 3 tâches journalières", "Timer Pomodoro 25/5 min intégré", "Belle avancée ! célébré à chaque tâche cochée"],
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
    details: ["Saisie manuelle en quelques secondes", "Graphiques de tendance clairs", "Lien avec ton humeur du check-in"],
    emoji: "😴",
  },
  {
    id: "community",
    icon: Users,
    color: "#FF4D6A",
    label: "Ma Tribu",
    title: "Une communauté qui te ressemble",
    description:
      "Pas de réseau social anxiogène, pas de compteur de followers. Ma Tribu, c'est des groupes thématiques où les entrepreneurs s'entraident, partagent et progressent ensemble — sans se comparer.",
    details: ["Groupes thématiques (freelance, créatif, tech…)", "Posts & échanges authentiques", "Pas de followers publics, pas de compétition"],
    emoji: "👥",
  },
  {
    id: "rewards",
    icon: Trophy,
    color: "#FFB800",
    label: "Mes Badges",
    title: "La régularité récompensée, jamais punie",
    description:
      "Chaque jour où tu avances compte. kolyb célèbre ta régularité avec des badges et des streaks — et si tu rates un jour, le message est toujours bienveillant. Tu te relèves, kolyb est là.",
    details: ["Streaks 3j → 7j → 30j → 365j", "Niveaux Explorateur à Visionnaire", "+15 pts bonus si tu te relèves après un raté"],
    emoji: "🏆",
  },
];

export default function Features() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });
  const [active, setActive] = useState(0);

  return (
    <section ref={ref} id="features" className="py-32 px-8 relative">
      {/* BG */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/2 left-0 w-[500px] h-[500px] bg-[#6D28D9]/8 rounded-full blur-[120px]" />
      </div>

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="text-xs font-semibold text-[#8B7FE8] uppercase tracking-[0.1em] mb-4">
            Fonctionnalités
          </p>
          <h2
            className="text-4xl md:text-5xl font-bold text-white mb-4"
            style={{ letterSpacing: "-0.02em" }}
          >
            Tout ce qu&apos;il te faut,{" "}
            <span className="gradient-text">en un seul endroit</span>
          </h2>
          <p className="text-lg text-[#EDEDFF]/60 max-w-xl mx-auto">
            5 modules pensés pour le quotidien des indépendants. Simples, efficaces, bienveillants.
          </p>
        </motion.div>

        {/* Feature tabs */}
        <div className="flex flex-wrap justify-center gap-2.5 mb-14">
          {features.map((f, i) => {
            return (
              <motion.button
                key={f.id}
                initial={{ opacity: 0, y: 10 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: i * 0.08 }}
                onClick={() => setActive(i)}
                className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 ${
                  active === i
                    ? "bg-[#6D28D9] text-white shadow-lg shadow-purple-900/30"
                    : "bg-[#1A1836] text-[#EDEDFF]/60 hover:text-white border border-[#22204A] hover:border-[#6D28D9]/40"
                }`}
              >
                <span>{f.emoji}</span>
                {f.label}
              </motion.button>
            );
          })}
        </div>

        {/* Active feature detail */}
        <motion.div
          key={active}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="grid md:grid-cols-2 gap-8 items-center"
        >
          {/* Text */}
          <div className="order-2 md:order-1">
            <div
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold uppercase tracking-wider mb-6"
              style={{
                background: `${features[active].color}18`,
                color: features[active].color,
                border: `1px solid ${features[active].color}30`,
              }}
            >
              {features[active].label}
            </div>
            <h3
              className="text-3xl md:text-4xl font-bold text-white mb-4"
              style={{ letterSpacing: "-0.02em" }}
            >
              {features[active].title}
            </h3>
            <p className="text-[#EDEDFF]/60 leading-relaxed mb-8">
              {features[active].description}
            </p>
            <ul className="flex flex-col gap-3">
              {features[active].details.map((d) => (
                <li key={d} className="flex items-start gap-3 text-sm text-[#EDEDFF]/75">
                  <span
                    className="mt-0.5 w-5 h-5 rounded-full flex-shrink-0 flex items-center justify-center text-xs font-bold"
                    style={{
                      background: `${features[active].color}20`,
                      color: features[active].color,
                    }}
                  >
                    ✓
                  </span>
                  {d}
                </li>
              ))}
            </ul>
          </div>

          {/* Visual card */}
          <div className="order-1 md:order-2">
            <div
              className="relative rounded-3xl p-8 bg-[#1A1836] border border-[#22204A] overflow-hidden min-h-[320px] flex items-center justify-center"
              style={{
                boxShadow: `0 0 80px ${features[active].color}15`,
              }}
            >
              {/* Glow */}
              <div
                className="absolute inset-0 rounded-3xl opacity-20"
                style={{
                  background: `radial-gradient(circle at 50% 50%, ${features[active].color}, transparent 70%)`,
                }}
              />
              {/* Icon big */}
              <div className="relative z-10 text-center">
                <div
                  className="text-7xl mb-6 select-none"
                  style={{ filter: "drop-shadow(0 0 24px rgba(255,255,255,0.2))" }}
                >
                  {features[active].emoji}
                </div>
                <p
                  className="text-2xl font-bold"
                  style={{ color: features[active].color, letterSpacing: "-0.01em" }}
                >
                  {features[active].label}
                </p>
                <p className="text-[#EDEDFF]/40 text-sm mt-2">Disponible en V1</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
