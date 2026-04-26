"use client";

import { useRef } from "react";
import { motion, useInView, useScroll, useTransform } from "framer-motion";
import { Heart, Shield, Zap, Clock, Globe, Lock } from "lucide-react";

const benefits = [
  {
    icon: Heart,
    color: "#FF4D6A",
    title: "Bienveillant par design",
    description:
      "Pas de jugement, pas de comparaison forcée. kolyb célèbre ta régularité et t'encourage si tu rates un jour. Tu progresses à ton rythme.",
  },
  {
    icon: Zap,
    color: "#FFB800",
    title: "2 min suffisent",
    description:
      "Le check-in, le planificateur, le suivi sommeil : tout est conçu pour prendre le moins de temps possible. L'app travaille pour toi, pas l'inverse.",
  },
  {
    icon: Shield,
    color: "#00D4C8",
    title: "Tes données t'appartiennent",
    description:
      "Hébergement en France, RGPD respecté à la lettre, RLS sur chaque table. Tes check-ins et données de sommeil sont chiffrés. Point final.",
  },
  {
    icon: Clock,
    color: "#8B7FE8",
    title: "100% gratuit en V1",
    description:
      "Toutes les fonctionnalités essentielles sont gratuites. Pas de paywall surprise, pas de fonctionnalité cachée. Le Pro, c'est pour les extras en V2.",
  },
  {
    icon: Globe,
    color: "#6D28D9",
    title: "Communauté qualitative",
    description:
      "Le Salon, c'est l'anti-LinkedIn. Pas de compteur de followers, pas de personal branding. Juste des échanges vrais entre indépendants.",
  },
  {
    icon: Lock,
    color: "#C4B5FD",
    title: "Hors ligne quand tu veux",
    description:
      "Ton check-in, ton planificateur et ton tracker sommeil fonctionnent sans connexion. kolyb est là même dans le train ou à la montagne.",
  },
];

const cardVariants = {
  hidden: { opacity: 0, scale: 0.88, y: 28 },
  visible: (i: number) => ({
    opacity: 1,
    scale: 1,
    y: 0,
    transition: { duration: 0.55, delay: i * 0.09, ease: [0.22, 1, 0.36, 1] as [number, number, number, number] },
  }),
};

export default function Benefits() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] });
  const glowY = useTransform(scrollYProgress, [0, 1], ["20%", "-20%"]);

  return (
    <section ref={ref} id="benefits" className="section" style={{ position: "relative", overflow: "hidden" }}>
      <motion.div
        style={{ y: glowY }}
        className="absolute inset-0 pointer-events-none"
        aria-hidden="true"
      >
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-[#6D28D9]/10 rounded-full blur-[120px]" />
      </motion.div>

      <div className="wrap relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="section-header"
        >
          <p className="eyebrow">Pourquoi kolyb</p>
          <h2 className="section-title">
            Conçu avec les{" "}
            <span className="text-[#00D4C8]">valeurs qui comptent</span>
          </h2>
          <p className="section-sub">
            Pas une app de plus dans ton téléphone. Une app qui mérite sa place.
          </p>
        </motion.div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {benefits.map((benefit, i) => {
            const Icon = benefit.icon;
            return (
              <motion.div
                key={benefit.title}
                custom={i}
                variants={cardVariants}
                initial="hidden"
                animate={inView ? "visible" : "hidden"}
                whileHover={{
                  y: -8,
                  scale: 1.02,
                  boxShadow: `0 20px 56px ${benefit.color}18`,
                  borderColor: `${benefit.color}35`,
                }}
                transition={{ duration: 0.25 }}
                className="card group"
                style={{ cursor: "default" }}
              >
                <motion.div
                  whileHover={{ rotate: 12, scale: 1.15 }}
                  transition={{ duration: 0.3 }}
                  className="icon-box mb-6"
                  style={{
                    background: `${benefit.color}15`,
                    border: `1px solid ${benefit.color}22`,
                  }}
                >
                  <Icon size={18} style={{ color: benefit.color }} />
                </motion.div>
                <h3 className="text-[15px] font-semibold text-white mb-2.5 leading-snug">
                  {benefit.title}
                </h3>
                <p className="text-sm text-[#EDEDFF]/50 leading-relaxed">
                  {benefit.description}
                </p>

                {/* Animated bottom accent */}
                <motion.div
                  initial={{ scaleX: 0 }}
                  animate={inView ? { scaleX: 1 } : {}}
                  transition={{ duration: 0.4, delay: 0.4 + i * 0.08 }}
                  style={{
                    transformOrigin: "left",
                    height: "2px",
                    background: `linear-gradient(90deg, ${benefit.color}, transparent)`,
                    marginTop: "16px",
                    borderRadius: "1px",
                  }}
                />
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
