"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform, useMotionValueEvent } from "framer-motion";

const PHRASES = [
  { text: "Pas de jugement.",  color: "#8B7FE8" },
  { text: "À ton rythme.",     color: "#00D4C8" },
  { text: "Ensemble.",         color: "#C4B5FD" },
  { text: "C'est ça, kolyb.", color: "#FF4D6A" },
] as const;

const IN  = 0.10;
const OUT = 0.08;

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
  const phraseRef = useRef<HTMLParagraphElement>(null);
  const glowRef   = useRef<HTMLDivElement>(null);

  const opacity = useTransform(scrollYProgress,
    [start, start + IN, end - OUT, end],
    [0, 1, 1, 0]
  );
  const scale = useTransform(scrollYProgress,
    [start, start + IN, end - OUT, end],
    [0.86, 1, 1, 1.07]
  );
  const y = useTransform(scrollYProgress,
    [start, start + IN, end - OUT, end],
    [64, 0, 0, -40]
  );
  const blurPx = useTransform(scrollYProgress,
    [start, start + IN, end - OUT, end],
    [16, 0, 0, 6]
  );
  const glowOp = useTransform(scrollYProgress,
    [start, start + IN * 0.8, end - OUT, end],
    [0, 0.6, 0.6, 0]
  );

  /* Propriétés non-transform appliquées en impératif (fix framer-motion v11) */
  useMotionValueEvent(opacity, "change", (v) => {
    if (phraseRef.current) phraseRef.current.style.opacity = String(v);
  });
  useMotionValueEvent(blurPx, "change", (v) => {
    if (phraseRef.current) phraseRef.current.style.filter = `blur(${v}px)`;
  });
  useMotionValueEvent(glowOp, "change", (v) => {
    if (glowRef.current) glowRef.current.style.opacity = String(v);
  });

  return (
    <>
      {/* Halo coloré réactif */}
      <div
        ref={glowRef}
        aria-hidden="true"
        style={{
          position: "absolute", inset: 0,
          background: `radial-gradient(ellipse 60% 45% at 50% 55%, ${phrase.color}28 0%, transparent 70%)`,
          opacity: 0,
          pointerEvents: "none",
          filter: "blur(50px)",
        }}
      />

      <motion.p
        ref={phraseRef}
        className="manifesto-phrase"
        style={{
          scale,
          y,
          opacity: 0,
          filter: "blur(16px)",
          color: phrase.color,
          position: "absolute",
          width: "100%",
          textAlign: "center",
          padding: "0 clamp(20px, 5vw, 80px)",
          willChange: "transform, opacity, filter",
        }}
      >
        {phrase.text}
      </motion.p>
    </>
  );
}

export default function ManifestoSection() {
  const containerRef  = useRef<HTMLDivElement>(null);
  const eyebrowRef    = useRef<HTMLParagraphElement>(null);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  const segment = 1 / PHRASES.length;

  const eyebrowOp = useTransform(scrollYProgress, [0, segment * 0.55], [1, 0]);
  useMotionValueEvent(eyebrowOp, "change", (v) => {
    if (eyebrowRef.current) eyebrowRef.current.style.opacity = String(v);
  });

  return (
    <section
      ref={containerRef}
      className="manifesto-outer"
      style={{ height: `${PHRASES.length * 140}dvh` }}
    >
      <div className="manifesto-inner">
        <div
          aria-hidden="true"
          style={{
            position: "absolute", inset: 0,
            background: "radial-gradient(ellipse 60% 60% at 50% 50%, rgba(109,40,217,0.08), transparent 70%)",
            pointerEvents: "none",
          }}
        />

        <p ref={eyebrowRef} className="manifesto-eyebrow" style={{ position: "relative", zIndex: 2 }}>
          Ne progresse plus seul
        </p>

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
