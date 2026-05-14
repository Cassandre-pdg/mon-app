"use client";

import { useRef, useEffect, useState } from "react";
import { motion, useInView } from "framer-motion";

const EASE: [number, number, number, number] = [0.16, 1, 0.3, 1];

const STATS = [
  { value: 5,    suffix: " apps",  label: "réunies en une seule",     color: "#8B7FE8", icon: "⚡" },
  { value: 3,    suffix: " min",   label: "par jour suffisent",        color: "#00D4C8", icon: "⏱" },
  { value: 100,  suffix: "%",      label: "gratuit en beta",           color: "#C4B5FD", icon: "✦" },
  { value: 0,    suffix: "",       label: "algorithme de comparaison", color: "#FF4D6A", icon: "🚫" },
] as const;

function CountUp({
  target,
  duration = 1.6,
  trigger,
}: {
  target: number;
  duration?: number;
  trigger: boolean;
}) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    if (!trigger) return;
    const start = performance.now();
    const step = (now: number) => {
      const elapsed = (now - start) / 1000;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCount(Math.round(eased * target));
      if (progress < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }, [trigger, target, duration]);

  return <>{count}</>;
}

export default function AnimatedStats() {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section
      style={{
        position: "relative",
        overflow: "hidden",
        paddingTop: "clamp(100px, 12vw, 140px)",
        paddingBottom: "clamp(100px, 12vw, 140px)",
        background: "#0D0B1E",
      }}
    >
      {/* Séparateur animé en haut — changement de sens */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", top: 0, left: 0, right: 0,
          height: 1,
          background: "linear-gradient(90deg, transparent 0%, rgba(139,127,232,0.4) 30%, rgba(0,212,200,0.3) 60%, transparent 100%)",
        }}
      />

      {/* Glows ambiants */}
      <div className="absolute inset-0 pointer-events-none" aria-hidden="true">
        <div style={{
          position: "absolute", top: "40%", left: "-5%",
          width: 500, height: 500,
          background: "radial-gradient(circle, rgba(139,127,232,0.06) 0%, transparent 70%)",
          filter: "blur(60px)",
        }} />
        <div style={{
          position: "absolute", top: "30%", right: "-5%",
          width: 400, height: 400,
          background: "radial-gradient(circle, rgba(0,212,200,0.05) 0%, transparent 70%)",
          filter: "blur(60px)",
        }} />
      </div>

      <div className="wrap">
        {/* En-tête — vient de la droite (direction opposée à HowItWorks) */}
        <motion.div
          initial={{ opacity: 0, x: 40 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, ease: EASE }}
          style={{ textAlign: "center", marginBottom: 72 }}
        >
          <span className="eyebrow">En chiffres</span>
          <h2
            className="section-title"
            style={{ fontSize: "clamp(1.75rem, 3.5vw, 2.5rem)" }}
          >
            Kolyb, conçu pour{" "}
            <span className="gradient-text" style={{ margin: 0 }}>
              l&apos;essentiel
            </span>
          </h2>
        </motion.div>

        {/* Grille — entrées alternées gauche/droite */}
        <div
          ref={ref}
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(2, 1fr)",
            gap: "clamp(12px, 2vw, 20px)",
            maxWidth: 900,
            margin: "0 auto",
          }}
        >
          {STATS.map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: i % 2 === 0 ? -48 : 48, y: 16 }}
              whileInView={{ opacity: 1, x: 0, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.10, duration: 0.65, ease: EASE }}
              whileHover={{
                scale: 1.035,
                boxShadow: `0 12px 48px ${stat.color}18, 0 0 0 1px ${stat.color}28`,
                borderColor: `${stat.color}45`,
                y: -4,
              }}
              style={{
                padding: "clamp(28px, 4vw, 44px) clamp(20px, 3vw, 32px)",
                background: "rgba(26,24,54,0.8)",
                border: "1px solid rgba(139,127,232,0.12)",
                borderRadius: 20,
                textAlign: "center",
                position: "relative",
                overflow: "hidden",
                cursor: "default",
                transition: "border-color 0.3s ease",
              }}
            >
              {/* Glow interne en hover */}
              <div
                aria-hidden="true"
                style={{
                  position: "absolute", inset: 0,
                  background: `radial-gradient(ellipse at 50% 100%, ${stat.color}09, transparent 70%)`,
                  pointerEvents: "none",
                }}
              />

              {/* Ligne lumineuse en haut */}
              <motion.div
                initial={{ scaleX: 0 }}
                whileInView={{ scaleX: 1 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.10 + 0.35, duration: 0.6, ease: EASE }}
                style={{
                  position: "absolute", top: 0, left: "20%", right: "20%", height: 1,
                  background: `linear-gradient(90deg, transparent, ${stat.color}55, transparent)`,
                  transformOrigin: "center",
                }}
              />

              {/* Icône */}
              <span style={{ fontSize: 22, display: "block", marginBottom: 12, opacity: 0.7 }}>
                {stat.icon}
              </span>

              <span
                style={{
                  fontSize: "clamp(36px, 5vw, 56px)",
                  fontWeight: 800,
                  letterSpacing: "-0.04em",
                  lineHeight: 1,
                  display: "block",
                  marginBottom: 8,
                  color: stat.color,
                }}
              >
                <CountUp target={stat.value} trigger={inView} />
                {stat.suffix}
              </span>
              <span style={{ fontSize: 12, color: "rgba(237,237,255,0.45)", fontWeight: 500, lineHeight: 1.4 }}>
                {stat.label}
              </span>
            </motion.div>
          ))}
        </div>

        {/* Tagline de clôture */}
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.5, ease: EASE }}
          style={{
            textAlign: "center",
            marginTop: 56,
            fontSize: 15,
            color: "rgba(237,237,255,0.28)",
            fontWeight: 400,
            letterSpacing: "-0.01em",
          }}
        >
          Pensé pour les indépendants qui veulent avancer.{" "}
          <span style={{ color: "rgba(237,237,255,0.55)", fontWeight: 600 }}>
            Pas pour tout le monde.
          </span>
        </motion.p>
      </div>
    </section>
  );
}
