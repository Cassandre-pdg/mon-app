"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

const PHRASES = [
  { text: "Pas de jugement.",   color: "#8B7FE8" },
  { text: "À ton rythme.",      color: "#00D4C8" },
  { text: "Ensemble.",          color: "#C4B5FD" },
  { text: "C'est ça, kolyb.",   color: "#FF4D6A" },
] as const;

function ManifestoPhrase({
  phrase,
  scrollYProgress,
  start,
  end,
}: {
  phrase: (typeof PHRASES)[number];
  scrollYProgress: ReturnType<typeof useScroll>["scrollYProgress"];
  start: number;
  end: number;
}) {
  const opacity = useTransform(
    scrollYProgress,
    [start, start + 0.06, end - 0.06, end],
    [0, 1, 1, 0]
  );
  const scale = useTransform(
    scrollYProgress,
    [start, start + 0.06, end - 0.06, end],
    [0.85, 1, 1, 1.06]
  );
  const y = useTransform(
    scrollYProgress,
    [start, start + 0.06],
    [40, 0]
  );

  return (
    <motion.p
      className="manifesto-phrase"
      style={{
        opacity,
        scale,
        y,
        color: phrase.color,
        position: "absolute",
        width: "100%",
        textAlign: "center",
        padding: "0 clamp(20px, 5vw, 80px)",
      }}
    >
      {phrase.text}
    </motion.p>
  );
}

export default function ManifestoSection() {
  const containerRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  const segment = 1 / PHRASES.length;

  return (
    <section
      ref={containerRef}
      className="manifesto-outer"
      style={{ height: `${PHRASES.length * 120}vh` }}
    >
      <div className="manifesto-inner">
        {/* Ambient radial glow */}
        <div
          aria-hidden="true"
          style={{
            position: "absolute",
            inset: 0,
            background:
              "radial-gradient(ellipse 60% 60% at 50% 50%, rgba(109,40,217,0.12), transparent 70%)",
            pointerEvents: "none",
          }}
        />

        <p className="manifesto-eyebrow">Ne progresse plus seul</p>

        {PHRASES.map((phrase, i) => (
          <ManifestoPhrase
            key={phrase.text}
            phrase={phrase}
            scrollYProgress={scrollYProgress}
            start={i * segment}
            end={(i + 1) * segment}
          />
        ))}
      </div>
    </section>
  );
}
