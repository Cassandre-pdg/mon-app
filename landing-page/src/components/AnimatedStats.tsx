"use client";

import { useRef, useEffect, useState } from "react";
import { motion, useInView } from "framer-motion";

const STATS = [
  { value: 5,    suffix: " apps",  label: "réunies en une seule",    color: "#8B7FE8" },
  { value: 3,    suffix: " min",   label: "par jour suffisent",       color: "#00D4C8" },
  { value: 100,  suffix: "%",      label: "gratuit en beta",          color: "#C4B5FD" },
  { value: 0,    suffix: "",       label: "algorithme de comparaison", color: "#FF4D6A" },
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
      className="section"
      style={{ padding: "80px 0", background: "#0D0B1E" }}
    >
      <div className="wrap">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          style={{ textAlign: "center", marginBottom: 56 }}
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

        <div ref={ref} className="stats-grid">
          {STATS.map((stat, i) => (
            <motion.div
              key={i}
              className="stat-cell"
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1, duration: 0.55 }}
            >
              <span className="stat-value" style={{ color: stat.color }}>
                <CountUp target={stat.value} trigger={inView} />
                {stat.suffix}
              </span>
              <span className="stat-label">{stat.label}</span>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
