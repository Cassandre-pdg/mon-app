"use client";

import { motion, useInView } from "framer-motion";
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
    <section ref={ref} id="how-it-works" className="section">
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-[#00D4C8]/6 rounded-full blur-[100px]" />
      </div>

      <div className="wrap relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="section-header"
        >
          <p className="eyebrow">Comment ça marche</p>
          <h2 className="section-title">Simple comme bonjour</h2>
          <p className="section-sub">
            Pas de onboarding de 45 minutes, pas de formation requise.
            Tu ouvres l&apos;app — tu avances.
          </p>
        </motion.div>

        <div className="flex flex-col gap-8 max-w-3xl mx-auto">
          {steps.map((step, i) => {
            const Icon = step.icon;
            return (
              <motion.div
                key={step.number}
                initial={{ opacity: 0, y: 24 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.55, delay: i * 0.18 }}
                className="card flex items-start gap-6"
              >
                {/* Step number + icon */}
                <div className="flex-shrink-0 flex flex-col items-center gap-3">
                  <div
                    className="w-14 h-14 rounded-2xl flex items-center justify-center"
                    style={{
                      background: `${step.color}18`,
                      border: `1.5px solid ${step.color}35`,
                      boxShadow: `0 0 32px ${step.color}20`,
                    }}
                  >
                    <Icon size={24} style={{ color: step.color }} />
                  </div>
                  {i < steps.length - 1 && (
                    <div
                      className="w-0.5 h-8 rounded-full opacity-25"
                      style={{ background: step.color }}
                    />
                  )}
                </div>

                {/* Content */}
                <div className="flex-1 pt-1">
                  <span
                    className="badge mb-3"
                    style={{
                      background: `${step.color}15`,
                      color: step.color,
                      border: `1px solid ${step.color}28`,
                      fontSize: "11px",
                      letterSpacing: "0.08em",
                      textTransform: "uppercase",
                      fontWeight: 700,
                    }}
                  >
                    Étape {step.number}
                  </span>
                  <h3
                    className="text-xl font-bold text-white mb-2.5 leading-snug"
                    style={{ letterSpacing: "-0.02em" }}
                  >
                    {step.title}
                  </h3>
                  <p className="text-sm text-[#EDEDFF]/58 leading-relaxed">
                    {step.description}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
