"use client";

import { useRef } from "react";
import { motion, useInView, useScroll, useTransform } from "framer-motion";
import { Layers, Users, TrendingDown } from "lucide-react";

const problems = [
  {
    icon: Layers,
    color: "#FF4D6A",
    bgColor: "rgba(255,77,106,0.1)",
    title: "Trop d'apps, pas assez de clarté",
    description:
      "Tu jongles entre Notion, Todoist, Apple Health, Slack et ton journal papier. Résultat : tu passes plus de temps à organiser qu'à avancer.",
    from: { x: -60, opacity: 0 },
  },
  {
    icon: Users,
    color: "#FFB800",
    bgColor: "rgba(255,184,0,0.1)",
    title: "L'isolement qui s'installe",
    description:
      "Sans collègues, sans machine à café, les journées se ressemblent. L'enthousiasme du début s'effrite. Tu travailles seul·e, tu avances seul·e.",
    from: { y: 60, opacity: 0 },
  },
  {
    icon: TrendingDown,
    color: "#8B7FE8",
    bgColor: "rgba(139,127,232,0.1)",
    title: "Le fil de la progression qui se perd",
    description:
      "Les semaines passent, les projets avancent, mais tu ne vois pas vraiment où tu en es. Aucune satisfaction durable. Juste une to-do list qui grandit.",
    from: { x: 60, opacity: 0 },
  },
];

export default function Problem() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });

  const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] });
  const bgScale = useTransform(scrollYProgress, [0, 0.5], [0.85, 1.1]);

  return (
    <section ref={ref} id="problem" className="section" style={{ position: "relative", overflow: "hidden" }}>
      {/* Parallax background accent */}
      <motion.div
        style={{ scale: bgScale }}
        className="absolute inset-0 pointer-events-none"
        aria-hidden="true"
      >
        <div className="absolute -top-20 -left-20 w-[500px] h-[500px] bg-[#FF4D6A]/5 rounded-full blur-[120px]" />
      </motion.div>

      <div className="wrap relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="section-header"
        >
          <p className="eyebrow">Le vrai problème</p>
          <h2 className="section-title">
            Indépendant ne veut pas dire{" "}
            <span className="text-[#FF4D6A]">seul·e.</span>
          </h2>
          <p className="section-sub">
            Les entrepreneurs indépendants ont les mêmes besoins que tout le monde :
            organisation, connexion, progression, sans les outils adaptés à leur réalité.
          </p>
        </motion.div>

        {/* Cards with directional entrances */}
        <div className="grid md:grid-cols-3 gap-6">
          {problems.map((problem, i) => {
            const Icon = problem.icon;
            return (
              <motion.div
                key={problem.title}
                initial={problem.from}
                animate={inView ? { x: 0, y: 0, opacity: 1 } : {}}
                transition={{ duration: 0.7, delay: i * 0.15, ease: [0.22, 1, 0.36, 1] }}
                whileHover={{
                  y: -8,
                  boxShadow: `0 24px 64px ${problem.color}22`,
                  borderColor: `${problem.color}44`,
                }}
                className="card"
                style={{ cursor: "default" }}
              >
                <div
                  className="icon-box icon-box-lg mb-6"
                  style={{ background: problem.bgColor }}
                >
                  <Icon size={22} style={{ color: problem.color }} />
                </div>
                <h3 className="text-lg font-semibold text-white mb-3 leading-snug">
                  {problem.title}
                </h3>
                <p className="text-sm text-[#EDEDFF]/55 leading-relaxed">
                  {problem.description}
                </p>
                <motion.div
                  initial={{ scaleX: 0 }}
                  animate={inView ? { scaleX: 1 } : {}}
                  transition={{ duration: 0.6, delay: 0.45 + i * 0.15 }}
                  style={{
                    transformOrigin: "left",
                    height: "2px",
                    background: `linear-gradient(90deg, ${problem.color}, transparent)`,
                    marginTop: "20px",
                    borderRadius: "1px",
                  }}
                />
              </motion.div>
            );
          })}
        </div>

        {/* Bridge callout */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={inView ? { opacity: 1, scale: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="mt-14 text-center"
        >
          <div className="badge-pbm inline-flex items-center gap-3 px-7 py-4 rounded-2xl bg-[#6D28D9]/15 border border-[#6D28D9]/30">
            <span className="text-2xl">💡</span>
            <p className="text-[#C4B5FD] font-medium text-sm sm:text-base">
              kolyb réunit tout en un, conçu pour ton quotidien d&apos;indépendant·e.
            </p>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
