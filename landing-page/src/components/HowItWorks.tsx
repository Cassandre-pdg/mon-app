"use client";

import { useRef, useEffect, useState } from "react";
import { motion, useInView, useMotionValue, useSpring, useTransform } from "framer-motion";

const EASE = [0.16, 1, 0.3, 1] as const;

/* ── 3D card hook ─────────────────────────────────────────── */
function use3DCard() {
  const ref = useRef<HTMLDivElement>(null);
  const mx = useMotionValue(0);
  const my = useMotionValue(0);
  const rotX = useSpring(useTransform(my, [-0.5, 0.5], [7, -7]), { stiffness: 260, damping: 26 });
  const rotY = useSpring(useTransform(mx, [-0.5, 0.5], [-7, 7]), { stiffness: 260, damping: 26 });
  return {
    ref,
    rotX,
    rotY,
    onMove: (e: React.MouseEvent<HTMLDivElement>) => {
      const r = ref.current?.getBoundingClientRect();
      if (!r) return;
      mx.set((e.clientX - r.left) / r.width - 0.5);
      my.set((e.clientY - r.top) / r.height - 0.5);
    },
    onLeave: () => { mx.set(0); my.set(0); },
  };
}

/* ── Step 1 visual : toggle ON → dashboard apparaît ─────── */
function VisualStart({ live }: { live: boolean }) {
  const [on, setOn] = useState(false);
  const [rows, setRows] = useState(0);

  useEffect(() => {
    if (!live) return;
    let stopped = false;
    const t: ReturnType<typeof setTimeout>[] = [];
    const sched = (fn: () => void, ms: number) =>
      t.push(setTimeout(() => { if (!stopped) fn(); }, ms));

    function cycle() {
      setOn(false); setRows(0);
      sched(() => setOn(true), 900);
      sched(() => setRows(1), 1600);
      sched(() => setRows(2), 2100);
      sched(cycle, 5200);
    }
    cycle();
    return () => { stopped = true; t.forEach(clearTimeout); };
  }, [live]);

  return (
    <div style={{ height: 128, display: "flex", flexDirection: "column", gap: 10, paddingTop: 4 }}>
      {/* Toggle row */}
      <div style={{ display: "flex", alignItems: "center" }}>
        <span style={{
          fontSize: 10, color: "rgba(237,237,255,0.28)",
          textTransform: "uppercase", letterSpacing: "0.1em", flexGrow: 1,
        }}>
          kolyb
        </span>
        <motion.div
          animate={{ background: on ? "#6D28D9" : "rgba(139,127,232,0.1)" }}
          transition={{ duration: 0.35 }}
          style={{
            width: 36, height: 20, borderRadius: 10,
            border: "1px solid rgba(139,127,232,0.18)",
            position: "relative", flexShrink: 0,
          }}
        >
          <motion.div
            animate={{ x: on ? 18 : 2 }}
            transition={{ type: "spring", stiffness: 450, damping: 30 }}
            style={{
              position: "absolute", top: 3,
              width: 14, height: 14, borderRadius: "50%", background: "#fff",
            }}
          />
        </motion.div>
      </div>

      {/* Dashboard rows appearing */}
      {[
        { label: "Streak", val: "Jour 1 🔥", col: "#6D28D9" },
        { label: "Mon espace", val: "Prêt", col: "#8B7FE8" },
      ].map((row, i) => (
        <motion.div
          key={row.label}
          animate={{ opacity: rows > i ? 1 : 0, y: rows > i ? 0 : 8 }}
          transition={{ duration: 0.35, ease: EASE }}
          style={{
            background: "rgba(18,16,42,0.9)",
            border: "1px solid rgba(139,127,232,0.1)",
            borderRadius: 10, padding: "8px 14px",
            display: "flex", justifyContent: "space-between",
          }}
        >
          <span style={{ fontSize: 11, color: "rgba(237,237,255,0.38)" }}>{row.label}</span>
          <span style={{ fontSize: 11, fontWeight: 700, color: row.col }}>{row.val}</span>
        </motion.div>
      ))}
    </div>
  );
}

/* ── Step 2 visual : actions qui apparaissent + compteur ─── */
const ACTS = [
  { label: "Check-in matin", pts: "+5 pts", col: "#6D28D9" },
  { label: "3 tâches cochées", pts: "+10 pts", col: "#00D4C8" },
  { label: "Sommeil renseigné", pts: "+3 pts", col: "#FFB800" },
];

function VisualAct({ live }: { live: boolean }) {
  const [vis, setVis] = useState(0);
  const [sum, setSum] = useState(0);

  useEffect(() => {
    if (!live) return;
    let stopped = false;
    const t: ReturnType<typeof setTimeout>[] = [];
    const sched = (fn: () => void, ms: number) =>
      t.push(setTimeout(() => { if (!stopped) fn(); }, ms));
    const pts = [5, 10, 3];

    function cycle() {
      setVis(0); setSum(0);
      let cum = 0;
      pts.forEach((p, i) => sched(() => {
        cum += p;
        setVis(i + 1);
        setSum(cum);
      }, 500 + i * 950));
      sched(cycle, 5400);
    }
    cycle();
    return () => { stopped = true; t.forEach(clearTimeout); };
  }, [live]);

  return (
    <div style={{ height: 128, display: "flex", flexDirection: "column", gap: 7, position: "relative" }}>
      {ACTS.map((a, i) => (
        <motion.div
          key={a.label}
          animate={{ opacity: vis > i ? 1 : 0, x: vis > i ? 0 : -14 }}
          transition={{ duration: 0.32, ease: EASE }}
          style={{
            background: "rgba(18,16,42,0.9)",
            border: `1px solid ${a.col}18`,
            borderRadius: 10, padding: "7px 12px",
            display: "flex", justifyContent: "space-between", alignItems: "center",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 5, height: 5, borderRadius: "50%", background: a.col, flexShrink: 0 }} />
            <span style={{ fontSize: 11, color: "rgba(237,237,255,0.5)" }}>{a.label}</span>
          </div>
          <span style={{ fontSize: 11, fontWeight: 700, color: a.col }}>{a.pts}</span>
        </motion.div>
      ))}
      <motion.div
        animate={{ opacity: sum > 0 ? 1 : 0 }}
        transition={{ duration: 0.3 }}
        style={{
          position: "absolute", bottom: -2, right: 0,
          fontSize: 10, color: "rgba(237,237,255,0.25)",
          fontVariantNumeric: "tabular-nums",
        }}
      >
        {sum} pts captés
      </motion.div>
    </div>
  );
}

/* ── Step 3 visual : score monte + glow sur niveau ──────── */
function VisualSee({ live }: { live: boolean }) {
  const [score, setScore] = useState(0);
  const [glow, setGlow] = useState(false);
  const TARGET = 247;

  useEffect(() => {
    if (!live) return;
    let stopped = false;
    let raf: number;
    const t: ReturnType<typeof setTimeout>[] = [];
    const sched = (fn: () => void, ms: number) =>
      t.push(setTimeout(() => { if (!stopped) fn(); }, ms));

    function runScore(from: number) {
      let cur = from;
      const tick = () => {
        if (stopped) return;
        cur = Math.min(cur + 5, TARGET);
        setScore(cur);
        if (cur < TARGET) {
          raf = requestAnimationFrame(tick);
        } else {
          sched(() => setGlow(true), 200);
          sched(() => {
            setScore(0);
            setGlow(false);
            sched(() => runScore(0), 400);
          }, 3600);
        }
      };
      raf = requestAnimationFrame(tick);
    }

    sched(() => runScore(0), 500);
    return () => { stopped = true; t.forEach(clearTimeout); cancelAnimationFrame(raf); };
  }, [live]);

  const pct = (score / 300) * 100;
  const level = score >= 101 ? "Indépendant" : "Explorateur";
  const next = score >= 101 ? "Entrepreneur" : "Indépendant";

  return (
    <div style={{ height: 128, display: "flex", flexDirection: "column", gap: 12, position: "relative" }}>
      {/* Score + badge niveau */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div>
          <div style={{
            fontSize: 10, color: "rgba(237,237,255,0.28)",
            textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 3,
          }}>
            Score
          </div>
          <div style={{
            fontSize: 34, fontWeight: 800, letterSpacing: "-0.04em", lineHeight: 1,
            color: glow ? "#8B7FE8" : "#EDEDFF",
            transition: "color 0.4s ease",
          }}>
            {score}
          </div>
        </div>
        <motion.div
          animate={{
            boxShadow: glow
              ? "0 0 0 1px rgba(0,212,200,0.45), 0 0 20px rgba(0,212,200,0.35)"
              : "0 0 0 1px rgba(139,127,232,0.12)",
            color: glow ? "#00D4C8" : "#8B7FE8",
            background: glow ? "rgba(0,212,200,0.1)" : "rgba(139,127,232,0.08)",
          }}
          transition={{ duration: 0.5 }}
          style={{ fontSize: 11, fontWeight: 600, padding: "5px 11px", borderRadius: 20, marginTop: 4 }}
        >
          {level}
        </motion.div>
      </div>

      {/* Barre XP */}
      <div>
        <div style={{
          background: "rgba(139,127,232,0.1)", borderRadius: 3, height: 4,
          overflow: "hidden", marginBottom: 5,
        }}>
          <motion.div
            animate={{ width: `${pct}%` }}
            transition={{ duration: 0.06 }}
            style={{
              height: "100%", borderRadius: 3,
              background: "linear-gradient(90deg, #6D28D9, #8B7FE8)",
            }}
          />
        </div>
        <div style={{ display: "flex", justifyContent: "space-between" }}>
          <span style={{ fontSize: 10, color: "rgba(237,237,255,0.22)" }}>0</span>
          <span style={{ fontSize: 10, color: "rgba(237,237,255,0.22)" }}>→ {next}</span>
        </div>
      </div>

      {/* Pulse ring au level-up */}
      {glow && (
        <motion.div
          initial={{ opacity: 0.55, scale: 1 }}
          animate={{ opacity: 0, scale: 1.9 }}
          transition={{ duration: 1.1, ease: "easeOut", repeat: Infinity, repeatDelay: 0.4 }}
          style={{
            position: "absolute", top: 6, right: 8,
            width: 44, height: 44, borderRadius: "50%",
            border: "1.5px solid rgba(0,212,200,0.5)",
            pointerEvents: "none",
          }}
        />
      )}
    </div>
  );
}

/* ── Step card ────────────────────────────────────────────── */
interface StepDef {
  num: string;
  accentColor: string;
  label: string;
  title: string;
  micro: string;
  Visual: React.FC<{ live: boolean }>;
}

function StepCard({ step, index, inView }: { step: StepDef; index: number; inView: boolean }) {
  const { ref, rotX, rotY, onMove, onLeave } = use3DCard();
  const { num, accentColor, label, title, micro, Visual } = step;

  return (
    <motion.div
      initial={{ opacity: 0, y: 44 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.65, delay: 0.2 + index * 0.14, ease: EASE }}
      style={{ perspective: "900px" }}
    >
      <motion.div
        ref={ref}
        style={{
          rotateX: rotX,
          rotateY: rotY,
          transformStyle: "preserve-3d",
          background: "rgba(20,18,46,0.72)",
          backdropFilter: "blur(18px)",
          borderWidth: "2px 1px 1px 1px",
          borderStyle: "solid",
          borderColor: `${accentColor}55 rgba(139,127,232,0.1) rgba(139,127,232,0.1) rgba(139,127,232,0.1)`,
          borderRadius: 22,
          padding: 28,
          position: "relative",
          overflow: "hidden",
          cursor: "default",
          height: "100%",
        }}
        whileHover={{
          borderColor: `${accentColor}70 ${accentColor}22 ${accentColor}22 ${accentColor}22`,
          boxShadow: `0 20px 60px ${accentColor}14, 0 0 0 1px ${accentColor}12`,
        }}
        transition={{ duration: 0.25 }}
        onMouseMove={onMove}
        onMouseLeave={onLeave}
      >
        {/* Grand numéro en filigrane */}
        <div style={{
          position: "absolute", top: -10, right: 18,
          fontSize: 100, fontWeight: 800, letterSpacing: "-0.06em",
          color: `${accentColor}09`, lineHeight: 1,
          userSelect: "none", pointerEvents: "none",
        }}>
          {num}
        </div>

        {/* Ligne lumineuse en haut */}
        <div style={{
          position: "absolute", top: 0, left: "15%", right: "15%", height: 1,
          background: `linear-gradient(90deg, transparent, ${accentColor}50, transparent)`,
          borderRadius: 1,
        }} />

        {/* Visual animé */}
        <div style={{ marginBottom: 22 }}>
          <Visual live={inView} />
        </div>

        {/* Séparateur */}
        <div style={{
          height: 1,
          background: `linear-gradient(90deg, ${accentColor}22, rgba(139,127,232,0.06), transparent)`,
          marginBottom: 20,
        }} />

        {/* Badge étape */}
        <div style={{
          display: "inline-flex", alignItems: "center", gap: 6,
          fontSize: 10, fontWeight: 700, letterSpacing: "0.1em",
          textTransform: "uppercase", color: accentColor, marginBottom: 10,
        }}>
          <div style={{ width: 4, height: 4, borderRadius: "50%", background: accentColor }} />
          Étape {num} · {label}
        </div>

        {/* Titre */}
        <h3 style={{
          fontSize: 16, fontWeight: 700, color: "#EDEDFF",
          letterSpacing: "-0.02em", lineHeight: 1.35, marginBottom: 10,
        }}>
          {title}
        </h3>

        {/* Micro-texte */}
        <p style={{ fontSize: 12, color: "rgba(237,237,255,0.35)", lineHeight: 1.55, margin: 0 }}>
          {micro}
        </p>
      </motion.div>
    </motion.div>
  );
}

/* ── Composant principal ──────────────────────────────────── */
const STEPS: StepDef[] = [
  {
    num: "01",
    accentColor: "#6D28D9",
    label: "Démarrer",
    title: "Tu décides de progresser",
    micro: "Crée ton point de départ en 30 secondes",
    Visual: VisualStart,
  },
  {
    num: "02",
    accentColor: "#00D4C8",
    label: "Agir",
    title: "Chaque action est comptabilisée",
    micro: "Chaque signal construit ton score",
    Visual: VisualAct,
  },
  {
    num: "03",
    accentColor: "#FFB800",
    label: "Voir",
    title: "Ton niveau reflète ta progression",
    micro: "Ta discipline devient visible",
    Visual: VisualSee,
  },
];

export default function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null);
  const inView = useInView(sectionRef, { once: true, margin: "-80px" });

  return (
    <section
      ref={sectionRef}
      id="how-it-works"
      className="section"
      style={{ position: "relative", overflow: "hidden" }}
    >
      {/* Ambient glows */}
      <div className="absolute inset-0 pointer-events-none" aria-hidden="true">
        <div style={{
          position: "absolute", top: "15%", left: "5%",
          width: 480, height: 480,
          background: "radial-gradient(circle, rgba(109,40,217,0.09) 0%, transparent 70%)",
          filter: "blur(70px)",
        }} />
        <div style={{
          position: "absolute", bottom: "10%", right: "5%",
          width: 380, height: 380,
          background: "radial-gradient(circle, rgba(0,212,200,0.07) 0%, transparent 70%)",
          filter: "blur(70px)",
        }} />
        <div style={{
          position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)",
          width: 600, height: 300,
          background: "radial-gradient(ellipse, rgba(109,40,217,0.04) 0%, transparent 70%)",
          filter: "blur(40px)",
        }} />
      </div>

      <div className="wrap relative z-10">
        {/* En-tête */}
        <motion.div
          className="section-header"
          initial={{ opacity: 0, y: 24 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: EASE }}
        >
          <p className="eyebrow">Comment ça marche</p>
          <h2 className="section-title">
            Simple.{" "}
            <span className="gradient-text" style={{ display: "inline", margin: 0 }}>
              Mesurable.
            </span>{" "}
            Actif.
          </h2>
          <p className="section-sub">3 étapes. Ton niveau devient visible.</p>
        </motion.div>

        {/* Grille de cards */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            gap: 20,
            alignItems: "stretch",
          }}
          className="hiw-grid"
        >
          {STEPS.map((step, i) => (
            <StepCard key={step.num} step={step} index={i} inView={inView} />
          ))}
        </div>

        {/* Conclusion */}
        <motion.p
          initial={{ opacity: 0, y: 14 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.75, ease: EASE }}
          style={{
            textAlign: "center",
            marginTop: 52,
            fontSize: 16,
            color: "rgba(237,237,255,0.32)",
            fontWeight: 400,
            letterSpacing: "-0.01em",
          }}
        >
          C&apos;est tout.{" "}
          <span style={{ color: "rgba(237,237,255,0.58)", fontWeight: 600 }}>
            Le reste est automatique.
          </span>
        </motion.p>
      </div>
    </section>
  );
}
