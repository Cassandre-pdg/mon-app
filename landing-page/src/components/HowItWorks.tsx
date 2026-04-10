"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";
import { Download, UserCircle, Rocket } from "lucide-react";

const steps = [
  {
    number: "01",
    icon: Download,
    color: "#6D28D9",
    title: "Tu télécharges kolyb",
    description:
      "Disponible sur iOS et Android. En 2 minutes, tu crées ton compte et tu personnalises ton profil selon ton activité d'indépendant·e.",
  },
  {
    number: "02",
    icon: UserCircle,
    color: "#00D4C8",
    title: "Tu l'intègres à ta routine",
    description:
      "Le matin, ton check-in de 2 minutes. En journée, tes 3 priorités + Pomodoro. Le soir, le bilan. Chaque semaine, tu vois ta progression.",
  },
  {
    number: "03",
    icon: Rocket,
    color: "#FFB800",
    title: "Tu avances, jamais seul·e",
    description:
      "Ma Tribu t'attend : une communauté d'indépendants qui comprennent ta réalité. Tu partages, tu échanges, tu progresses ensemble — à ton rythme.",
  },
];

export default function HowItWorks() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <section ref={ref} id="how-it-works" className="py-32 px-8 relative">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-[#00D4C8]/6 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-5xl mx-auto relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="text-xs font-semibold text-[#8B7FE8] uppercase tracking-[0.1em] mb-4">
            Comment ça marche
          </p>
          <h2
            className="text-4xl md:text-5xl font-bold text-white mb-4"
            style={{ letterSpacing: "-0.02em" }}
          >
            Simple comme bonjour
          </h2>
          <p className="text-lg text-[#EDEDFF]/60 max-w-xl mx-auto">
            Pas de onboarding de 45 minutes, pas de formation requise.
            Tu ouvres l&apos;app — tu avances.
          </p>
        </motion.div>

        <div className="relative">
          {/* Connector line */}
          <div className="hidden md:block absolute top-12 left-[calc(50%-1px)] w-0.5 h-[calc(100%-48px)] bg-gradient-to-b from-[#6D28D9] via-[#00D4C8] to-[#FFB800] opacity-20" />

          <div className="flex flex-col gap-12">
            {steps.map((step, i) => {
              const Icon = step.icon;
              return (
                <motion.div
                  key={step.number}
                  initial={{ opacity: 0, x: i % 2 === 0 ? -30 : 30 }}
                  animate={inView ? { opacity: 1, x: 0 } : {}}
                  transition={{ duration: 0.6, delay: i * 0.2 }}
                  className={`flex items-center gap-8 md:gap-16 ${
                    i % 2 === 0 ? "md:flex-row" : "md:flex-row-reverse"
                  }`}
                >
                  {/* Content */}
                  <div className="flex-1">
                    <div
                      className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider mb-4"
                      style={{
                        background: `${step.color}15`,
                        color: step.color,
                        border: `1px solid ${step.color}25`,
                      }}
                    >
                      Étape {step.number}
                    </div>
                    <h3
                      className="text-2xl md:text-3xl font-bold text-white mb-3"
                      style={{ letterSpacing: "-0.02em" }}
                    >
                      {step.title}
                    </h3>
                    <p className="text-[#EDEDFF]/60 leading-relaxed">{step.description}</p>
                  </div>

                  {/* Icon circle */}
                  <div className="flex-shrink-0">
                    <div
                      className="w-24 h-24 rounded-3xl flex items-center justify-center"
                      style={{
                        background: `${step.color}15`,
                        border: `2px solid ${step.color}30`,
                        boxShadow: `0 0 40px ${step.color}20`,
                      }}
                    >
                      <Icon size={36} style={{ color: step.color }} />
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
