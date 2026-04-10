"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";
import { Layers, Users, TrendingDown } from "lucide-react";

const problems = [
  {
    icon: Layers,
    color: "#FF4D6A",
    bgColor: "rgba(255,77,106,0.1)",
    title: "Trop d'apps, pas assez de clarté",
    description:
      "Tu jonglais entre Notion, Todoist, Apple Health, Slack et ton journal papier. Résultat : tu passes plus de temps à organiser qu'à avancer.",
  },
  {
    icon: Users,
    color: "#FFB800",
    bgColor: "rgba(255,184,0,0.1)",
    title: "L'isolement qui s'installe",
    description:
      "Sans collègues, sans machine à café, les journées se ressemblent. L'enthousiasme du début s'effrite. Tu travailles seul·e, tu avances seul·e.",
  },
  {
    icon: TrendingDown,
    color: "#8B7FE8",
    bgColor: "rgba(139,127,232,0.1)",
    title: "Le fil de la progression qui se perd",
    description:
      "Les semaines passent, les projets avancent — mais tu ne vois pas vraiment où tu en es. Aucune satisfaction durable. Juste une to-do list qui grandit.",
  },
];

export default function Problem() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section ref={ref} id="problem" className="py-32 px-8 relative">
      <div className="max-w-5xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="text-xs font-semibold text-[#8B7FE8] uppercase tracking-[0.1em] mb-4">
            Le vrai problème
          </p>
          <h2
            className="text-4xl md:text-5xl font-bold text-white mb-6"
            style={{ letterSpacing: "-0.02em" }}
          >
            Indépendant ne veut pas dire{" "}
            <span className="text-[#FF4D6A]">seul·e.</span>
          </h2>
          <p className="text-lg text-[#EDEDFF]/60 max-w-2xl mx-auto">
            Les entrepreneurs indépendants ont les mêmes besoins que tout le monde —
            organisation, connexion, progression — sans les outils adaptés à leur réalité.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8">
          {problems.map((problem, i) => {
            const Icon = problem.icon;
            return (
              <motion.div
                key={problem.title}
                initial={{ opacity: 0, y: 30 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.6, delay: i * 0.15 }}
                className="card-hover p-8 rounded-2xl bg-[#1A1836] border border-[#22204A]"
              >
                <div
                  className="w-12 h-12 rounded-2xl flex items-center justify-center mb-6"
                  style={{ background: problem.bgColor }}
                >
                  <Icon size={22} style={{ color: problem.color }} />
                </div>
                <h3 className="text-lg font-semibold text-white mb-4">
                  {problem.title}
                </h3>
                <p className="text-sm text-[#EDEDFF]/55 leading-relaxed">
                  {problem.description}
                </p>
              </motion.div>
            );
          })}
        </div>

        {/* Bridge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="mt-16 text-center"
        >
          <div className="inline-flex items-center gap-3 px-6 py-4 rounded-2xl bg-[#6D28D9]/15 border border-[#6D28D9]/30">
            <span className="text-2xl">💡</span>
            <p className="text-[#C4B5FD] font-medium">
              kolyb réunit tout en un — conçu pour ton quotidien d&apos;indépendant·e.
            </p>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
