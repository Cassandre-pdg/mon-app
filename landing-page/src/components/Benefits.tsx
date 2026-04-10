"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";
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
      "Le check-in, le planificateur, le suivi sommeil — tout est conçu pour prendre le moins de temps possible. L'app travaille pour toi, pas l'inverse.",
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
      "Ma Tribu, c'est l'anti-LinkedIn. Pas de compteur de followers, pas de personal branding. Juste des échanges vrais entre indépendants.",
  },
  {
    icon: Lock,
    color: "#C4B5FD",
    title: "Hors ligne quand tu veux",
    description:
      "Ton check-in, ton planificateur et ton tracker sommeil fonctionnent sans connexion. kolyb est là même dans le train ou à la montagne.",
  },
];

export default function Benefits() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <section ref={ref} id="benefits" className="py-32 px-8 relative">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[700px] h-[400px] bg-[#6D28D9]/10 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="text-xs font-semibold text-[#8B7FE8] uppercase tracking-[0.1em] mb-4">
            Pourquoi kolyb
          </p>
          <h2
            className="text-4xl md:text-5xl font-bold text-white mb-4"
            style={{ letterSpacing: "-0.02em" }}
          >
            Conçu avec les{" "}
            <span className="text-[#00D4C8]">valeurs qui comptent</span>
          </h2>
          <p className="text-lg text-[#EDEDFF]/60 max-w-xl mx-auto">
            Pas une app de plus dans ton téléphone. Une app qui mérite sa place.
          </p>
        </motion.div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-7">
          {benefits.map((benefit, i) => {
            const Icon = benefit.icon;
            return (
              <motion.div
                key={benefit.title}
                initial={{ opacity: 0, y: 20 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className="card-hover p-8 rounded-2xl bg-[#1A1836] border border-[#22204A] group"
              >
                <div
                  className="w-11 h-11 rounded-xl flex items-center justify-center mb-5 transition-all duration-300 group-hover:scale-110"
                  style={{
                    background: `${benefit.color}15`,
                    border: `1px solid ${benefit.color}20`,
                  }}
                >
                  <Icon size={18} style={{ color: benefit.color }} />
                </div>
                <h3 className="text-base font-semibold text-white mb-2">
                  {benefit.title}
                </h3>
                <p className="text-sm text-[#EDEDFF]/50 leading-relaxed">
                  {benefit.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
