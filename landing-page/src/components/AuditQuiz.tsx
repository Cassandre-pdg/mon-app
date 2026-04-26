"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, ArrowLeft, Lock, Zap, Brain, Layers } from "lucide-react";
import KolybIcon from "./KolybIcon";

/* ─── Constants ─────────────────────────────────────────────────────────── */

const EASE: [number, number, number, number] = [0.16, 1, 0.3, 1];

// Deterministic orbs — no Math.random() to avoid hydration mismatch
const ORBS = [
  { w: 520, h: 520, x: "-14%", y: "-8%",  color: "rgba(109,40,217,0.18)",  dur: "14s", del: "0s"  },
  { w: 380, h: 380, x: "72%",  y: "55%",  color: "rgba(0,212,200,0.10)",   dur: "18s", del: "-6s" },
  { w: 260, h: 260, x: "62%",  y: "10%",  color: "rgba(255,77,106,0.07)",  dur: "11s", del: "-3s" },
  { w: 200, h: 200, x: "8%",   y: "72%",  color: "rgba(109,40,217,0.08)",  dur: "15s", del: "-9s" },
];

/* ─── Types ──────────────────────────────────────────────────────────────── */

type Phase = "hero" | "quiz" | "scanning" | "email" | "results";
type Status = "idle" | "loading" | "success" | "error";

interface Scores {
  focus: number;
  execution: number;
  structure: number;
  global: number;
}

interface Profile {
  id: string;
  emoji: string;
  color: string;
  colorBg: string;
  colorBorder: string;
  label: string;
  tagline: string;
  problem: string;
  insight: string;
  solution: string;
  ctaText: string;
}

/* ─── Data ───────────────────────────────────────────────────────────────── */

const QUESTIONS = [
  {
    id: 1, dimension: "focus", emoji: "🧠", dimLabel: "Focus",
    question: "Quand tu travailles, à quelle fréquence tu te déconcentres ?",
    options: [
      { letter: "A", text: "Toutes les 5-10 min", score: 1 },
      { letter: "B", text: "Régulièrement, toutes les 20-30 min", score: 2 },
      { letter: "C", text: "Rarement, j'arrive à tenir", score: 3 },
      { letter: "D", text: "Je suis en deep focus la plupart du temps", score: 4 },
    ],
  },
  {
    id: 2, dimension: "execution", emoji: "⚡", dimLabel: "Exécution",
    question: "Combien de tes tâches prévues sont réellement terminées chaque jour ?",
    options: [
      { letter: "A", text: "Moins de 30%", score: 1 },
      { letter: "B", text: "Entre 30 et 60%", score: 2 },
      { letter: "C", text: "Entre 60 et 80%", score: 3 },
      { letter: "D", text: "80 à 100%", score: 4 },
    ],
  },
  {
    id: 3, dimension: "structure", emoji: "🧩", dimLabel: "Organisation",
    question: "Comment tu gères tes tâches au quotidien ?",
    options: [
      { letter: "A", text: "Tout dans ma tête", score: 1 },
      { letter: "B", text: "Notes dispersées et apps multiples", score: 2 },
      { letter: "C", text: "Liste structurée mais pas toujours suivie", score: 3 },
      { letter: "D", text: "Système clair et suivi quotidien", score: 4 },
    ],
  },
  {
    id: 4, dimension: "focus", emoji: "📱", dimLabel: "Distraction",
    question: "Ton téléphone te détourne combien de fois par heure de travail ?",
    options: [
      { letter: "A", text: "+10 fois par heure", score: 1 },
      { letter: "B", text: "5 à 10 fois", score: 2 },
      { letter: "C", text: "2 à 5 fois", score: 3 },
      { letter: "D", text: "Presque jamais", score: 4 },
    ],
  },
  {
    id: 5, dimension: "execution", emoji: "🎯", dimLabel: "Clarté",
    question: "Tu sais exactement sur quoi te concentrer cette semaine ?",
    options: [
      { letter: "A", text: "Pas vraiment, je navigue à vue", score: 1 },
      { letter: "B", text: "Globalement oui, sans précision", score: 2 },
      { letter: "C", text: "Oui mais sans vraie priorisation", score: 3 },
      { letter: "D", text: "Ultra clair, mes priorités sont définies", score: 4 },
    ],
  },
  {
    id: 6, dimension: "structure", emoji: "🔥", dimLabel: "Constance",
    question: "Ton niveau de régularité sur les 7 derniers jours ?",
    options: [
      { letter: "A", text: "Très irrégulier, beaucoup de hauts et bas", score: 1 },
      { letter: "B", text: "2 à 3 jours vraiment productifs", score: 2 },
      { letter: "C", text: "4 à 5 jours plutôt stables", score: 3 },
      { letter: "D", text: "Très stable, ma routine tient", score: 4 },
    ],
  },
  {
    id: 7, dimension: "focus", emoji: "💭", dimLabel: "Charge mentale",
    question: "En ce moment, ton esprit est plutôt :",
    options: [
      { letter: "A", text: "Saturé en permanence, je suis débordé", score: 1 },
      { letter: "B", text: "Chargé mais gérable", score: 2 },
      { letter: "C", text: "Assez calme, j'ai de l'espace", score: 3 },
      { letter: "D", text: "Très clair, je suis ancré", score: 4 },
    ],
  },
  {
    id: 8, dimension: "structure", emoji: "⚙️", dimLabel: "Système",
    question: "Tu utilises un système pour organiser ta vie pro ?",
    options: [
      { letter: "A", text: "Aucun système, je fais au feeling", score: 1 },
      { letter: "B", text: "Basique : notes et reminders épars", score: 2 },
      { letter: "C", text: "Partiellement structuré", score: 3 },
      { letter: "D", text: "Système complet et cohérent", score: 4 },
    ],
  },
  {
    id: 9, dimension: "execution", emoji: "🔍", dimLabel: "Blocage",
    question: "Quand tu n'arrives pas à avancer, c'est surtout à cause de :",
    options: [
      { letter: "A", text: "La distraction : je suis happé par autre chose", score: 1 },
      { letter: "B", text: "Le manque d'énergie ou de motivation", score: 2 },
      { letter: "C", text: "Le manque de clarté sur quoi faire", score: 2 },
      { letter: "D", text: "La procrastination, je sais mais je ne fais pas", score: 1 },
    ],
  },
];

const PROFILES: Record<string, Profile> = {
  chaos: {
    id: "chaos", emoji: "🔴",
    color: "#FF4D6A", colorBg: "rgba(255,77,106,0.08)", colorBorder: "rgba(255,77,106,0.25)",
    label: "Chaos Mental",
    tagline: "Tu perds de l'énergie avant même de commencer.",
    problem: "Distraction forte · Absence de structure",
    insight: "Tu ne manques pas de temps. Tu perds ton attention.",
    solution: "Kolyb va reconstruire ton système en 7 jours.",
    ctaText: "Reprendre le contrôle",
  },
  dispersed: {
    id: "dispersed", emoji: "🟠",
    color: "#FFB800", colorBg: "rgba(255,184,0,0.08)", colorBorder: "rgba(255,184,0,0.25)",
    label: "Productif dispersé",
    tagline: "Tu fais beaucoup... mais pas dans la bonne direction.",
    problem: "Effort élevé · Impact dilué",
    insight: "Ton énergie est réelle. Ta direction, elle, est floue.",
    solution: "Kolyb centralise et priorise pour que chaque action compte vraiment.",
    ctaText: "Reprendre le cap",
  },
  blocked: {
    id: "blocked", emoji: "🟡",
    color: "#FFB800", colorBg: "rgba(255,184,0,0.07)", colorBorder: "rgba(255,184,0,0.2)",
    label: "Potentiel bloqué",
    tagline: "Tu sais quoi faire. Tu ne le fais pas.",
    problem: "Clarté présente · Exécution bloquée",
    insight: "Le blocage n'est pas un manque de compétence. C'est un manque de structure.",
    solution: "Kolyb transforme tes intentions en actions concrètes, chaque jour.",
    ctaText: "Débloquer mon potentiel",
  },
  stable: {
    id: "stable", emoji: "🟢",
    color: "#00D4C8", colorBg: "rgba(0,212,200,0.07)", colorBorder: "rgba(0,212,200,0.22)",
    label: "Opérateur stable",
    tagline: "Tu es déjà efficace. Kolyb peut te faire passer au niveau supérieur.",
    problem: "Bon équilibre · Besoin d'optimisation",
    insight: "Tu as les bases solides. Il te manque le système qui scale.",
    solution: "Kolyb optimise et mesure ce qui fonctionne déjà chez toi.",
    ctaText: "Passer au niveau suivant",
  },
  optimized: {
    id: "optimized", emoji: "🔵",
    color: "#8B7FE8", colorBg: "rgba(139,127,232,0.08)", colorBorder: "rgba(139,127,232,0.22)",
    label: "Système optimisé",
    tagline: "Tu es dans le top 10%. Kolyb sert à scaler ton système.",
    problem: "Structure élite · Scalabilité à construire",
    insight: "Tu n'as pas besoin de te réinventer. Tu as besoin de t'amplifier.",
    solution: "Kolyb te donne les données et la communauté pour aller encore plus loin.",
    ctaText: "Scaler mon système",
  },
};

/* ─── Helpers ────────────────────────────────────────────────────────────── */

function calculateScores(answers: { dimension: string; score: number }[]): Scores {
  const byDim: Record<string, number[]> = { focus: [], execution: [], structure: [] };
  answers.forEach((a) => byDim[a.dimension]?.push(a.score));
  const avg = (arr: number[]) =>
    arr.length ? arr.reduce((s, v) => s + v, 0) / arr.length : 1;
  const toPercent = (v: number) => Math.round(((v - 1) / 3) * 100);
  const focus     = toPercent(avg(byDim.focus));
  const execution = toPercent(avg(byDim.execution));
  const structure = toPercent(avg(byDim.structure));
  const global    = Math.round((focus + execution + structure) / 3);
  return { focus, execution, structure, global };
}

function getProfile(score: number): Profile {
  if (score <= 39) return PROFILES.chaos;
  if (score <= 54) return PROFILES.dispersed;
  if (score <= 69) return PROFILES.blocked;
  if (score <= 84) return PROFILES.stable;
  return PROFILES.optimized;
}

/* ─── Sub-components ─────────────────────────────────────────────────────── */

function Background() {
  return (
    <div style={{ position: "fixed", inset: 0, pointerEvents: "none", zIndex: 0 }} aria-hidden="true">
      {/* Deep base */}
      <div style={{ position: "absolute", inset: 0, background: "#0D0B1E" }} />
      {/* Grid */}
      <div style={{
        position: "absolute", inset: 0,
        backgroundImage:
          "linear-gradient(rgba(139,127,232,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.035) 1px, transparent 1px)",
        backgroundSize: "60px 60px",
      }} />
      {/* Orbs */}
      {ORBS.map((o, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            width: o.w, height: o.h,
            left: o.x, top: o.y,
            borderRadius: "50%",
            background: `radial-gradient(circle, ${o.color} 0%, transparent 70%)`,
            filter: "blur(72px)",
            animation: `float-slow ${o.dur} ease-in-out infinite`,
            animationDelay: o.del,
          }}
        />
      ))}
      {/* Noise */}
      <div style={{
        position: "absolute", inset: 0,
        backgroundImage: "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E\")",
        opacity: 0.5,
      }} />
    </div>
  );
}

function MiniNav() {
  return (
    <header style={{
      position: "fixed", top: 0, left: 0, right: 0, zIndex: 50,
      padding: "0 clamp(20px, 5vw, 64px)",
      height: 64,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: "rgba(13,11,30,0.6)", backdropFilter: "blur(20px)",
      borderBottom: "1px solid rgba(34,32,74,0.5)",
    }}>
      <a href="/" style={{ display: "flex", alignItems: "center", gap: 10, textDecoration: "none" }}>
        <KolybIcon size={30} variant="violet" animate={false} />
        <span style={{ fontSize: 18, fontWeight: 800, color: "#EDEDFF", letterSpacing: "-0.02em" }}>kolyb</span>
      </a>
      <a
        href="/"
        style={{
          fontSize: 12, fontWeight: 500, color: "rgba(237,237,255,0.4)",
          textDecoration: "none", display: "flex", alignItems: "center", gap: 4,
          transition: "color 0.2s",
        }}
      >
        ← Accueil
      </a>
    </header>
  );
}

function AnimatedCounter({ target, color }: { target: number; color: string }) {
  const [value, setValue] = useState(0);
  useEffect(() => {
    let start: number | null = null;
    const duration = 1800;
    const raf = requestAnimationFrame(function step(ts) {
      if (!start) start = ts;
      const p = Math.min((ts - start) / duration, 1);
      const eased = 1 - Math.pow(1 - p, 4);
      setValue(Math.round(eased * target));
      if (p < 1) requestAnimationFrame(step);
    });
    return () => cancelAnimationFrame(raf);
  }, [target]);
  return <span style={{ color }}>{value}</span>;
}

function ScoreBar({ label, value, color, icon: Icon, delay }: {
  label: string; value: number; color: string;
  icon: typeof Brain; delay: number;
}) {
  const [width, setWidth] = useState(0);
  useEffect(() => {
    const t = setTimeout(() => setWidth(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <Icon size={13} color={color} />
          <span style={{ fontSize: 12, fontWeight: 600, color: "rgba(237,237,255,0.6)", textTransform: "uppercase", letterSpacing: "0.08em" }}>
            {label}
          </span>
        </div>
        <span style={{ fontSize: 13, fontWeight: 700, color }}>{value}/100</span>
      </div>
      <div style={{ height: 6, borderRadius: 99, background: "rgba(237,237,255,0.07)", overflow: "hidden" }}>
        <div style={{
          height: "100%",
          borderRadius: 99,
          background: `linear-gradient(90deg, ${color}aa, ${color})`,
          width: `${width}%`,
          transition: `width 1.2s cubic-bezier(0.16, 1, 0.3, 1)`,
          boxShadow: `0 0 12px ${color}55`,
        }} />
      </div>
    </div>
  );
}

/* ─── Main component ─────────────────────────────────────────────────────── */

export default function AuditQuiz() {
  const [phase, setPhase]             = useState<Phase>("hero");
  const [currentQ, setCurrentQ]       = useState(0);
  const [answers, setAnswers]         = useState<{ dimension: string; score: number }[]>([]);
  const [selected, setSelected]       = useState<string | null>(null);
  const [direction, setDirection]     = useState(1); // 1 = forward, -1 = back
  const [email, setEmail]             = useState("");
  const [status, setStatus]           = useState<Status>("idle");
  const [statusMsg, setStatusMsg]     = useState("");
  const [scores, setScores]           = useState<Scores | null>(null);
  const [scanProgress, setScanProgress] = useState(0);

  const q = QUESTIONS[currentQ];
  const profile = scores ? getProfile(scores.global) : null;

  /* ── Scanning animation ── */
  useEffect(() => {
    if (phase !== "scanning") { setScanProgress(0); return; }
    const start = Date.now();
    const duration = 2200;
    const raf = requestAnimationFrame(function tick() {
      const p = Math.min((Date.now() - start) / duration, 1);
      setScanProgress(Math.round(p * 100));
      if (p < 1) { requestAnimationFrame(tick); }
      else { setTimeout(() => setPhase("email"), 200); }
    });
    return () => cancelAnimationFrame(raf);
  }, [phase]);

  /* ── Select an answer ── */
  const handleSelect = useCallback((letter: string, score: number) => {
    if (selected) return;
    setSelected(letter);
    setTimeout(() => {
      const newAnswers = [...answers, { dimension: q.dimension, score }];
      setAnswers(newAnswers);
      setSelected(null);
      setDirection(1);
      if (currentQ < QUESTIONS.length - 1) {
        setCurrentQ(currentQ + 1);
      } else {
        const computed = calculateScores(newAnswers);
        setScores(computed);
        setPhase("scanning");
      }
    }, 420);
  }, [selected, answers, currentQ, q]);

  /* ── Go back one question ── */
  const handleBack = useCallback(() => {
    if (currentQ === 0) { setPhase("hero"); setAnswers([]); return; }
    setDirection(-1);
    setAnswers(answers.slice(0, -1));
    setCurrentQ(currentQ - 1);
  }, [currentQ, answers]);

  /* ── Email submit — appel direct freewaitlists (site statique, pas d'API route) ── */
  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || status === "loading") return;
    setStatus("loading");
    try {
      const res = await fetch("https://api.freewaitlists.com/waitlists/cmo78oimu08j901png9bqw4xb", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, meta: { source: "audit-quiz" } }),
      });
      if (res.ok) {
        setStatus("success");
        setPhase("results");
      } else if (res.status === 409) {
        // Déjà inscrit : on laisse quand même accéder aux résultats
        setStatus("success");
        setPhase("results");
      } else {
        setStatus("error");
        setStatusMsg("Une erreur est survenue. Réessaie.");
      }
    } catch {
      setStatus("error");
      setStatusMsg("Connexion impossible. Vérifie ta connexion et réessaie.");
    }
  };

  /* ── Variants ── */
  const pageVariants = {
    enter:  (d: number) => ({ opacity: 0, x: d * 40, filter: "blur(4px)" }),
    center: { opacity: 1, x: 0, filter: "blur(0px)" },
    exit:   (d: number) => ({ opacity: 0, x: d * -40, filter: "blur(4px)" }),
  };

  return (
    <div style={{ minHeight: "100vh", position: "relative", fontFamily: "var(--font-inter, Inter, sans-serif)" }}>
      <Background />
      <MiniNav />

      <div style={{ position: "relative", zIndex: 1, paddingTop: 64 }}>
        <AnimatePresence mode="wait" custom={direction}>

          {/* ══════════════════════════════════════════════════════
              PHASE 1 — HERO
          ══════════════════════════════════════════════════════ */}
          {phase === "hero" && (
            <motion.div
              key="hero"
              custom={direction}
              variants={pageVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.5, ease: EASE }}
              style={{
                minHeight: "calc(100vh - 64px)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                padding: "40px clamp(20px, 5vw, 64px)",
                textAlign: "center",
              }}
            >
              {/* Badge */}
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1, duration: 0.6, ease: EASE }}
              >
                <span style={{
                  display: "inline-flex", alignItems: "center", gap: 6,
                  padding: "6px 14px", borderRadius: 99,
                  fontSize: 11, fontWeight: 600, letterSpacing: "0.10em",
                  textTransform: "uppercase",
                  background: "rgba(109,40,217,0.16)",
                  border: "1px solid rgba(109,40,217,0.32)",
                  color: "#C4B5FD",
                  marginBottom: 28,
                }}>
                  ✦ Audit gratuit · 2 minutes · Résultats personnalisés
                </span>
              </motion.div>

              {/* Title */}
              <motion.h1
                initial={{ opacity: 0, y: 24 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.18, duration: 0.65, ease: EASE }}
                style={{
                  fontSize: "clamp(2.4rem, 6.5vw, 5rem)",
                  fontWeight: 800,
                  letterSpacing: "-0.045em",
                  lineHeight: 1.08,
                  color: "#EDEDFF",
                  maxWidth: 720,
                  marginBottom: 20,
                }}
              >
                Quel est ton vrai{" "}
                <span style={{
                  background: "linear-gradient(135deg, #8B7FE8 0%, #C4B5FD 55%, #00D4C8 100%)",
                  WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
                }}>
                  niveau de productivité ?
                </span>
              </motion.h1>

              {/* Subtitle */}
              <motion.p
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.26, duration: 0.6, ease: EASE }}
                style={{
                  fontSize: "clamp(1rem, 2.2vw, 1.15rem)",
                  color: "rgba(237,237,255,0.55)",
                  lineHeight: 1.75,
                  maxWidth: 520,
                  marginBottom: 40,
                }}
              >
                9 questions. Un profil psychoproductif précis. Les blocages invisibles qui te coûtent des heures — identifiés.
              </motion.p>

              {/* 3 pillars preview */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.34, duration: 0.6, ease: EASE }}
                style={{
                  display: "flex", gap: 12, flexWrap: "wrap", justifyContent: "center",
                  marginBottom: 40,
                }}
              >
                {[
                  { icon: Brain,  label: "Focus",     color: "#8B7FE8" },
                  { icon: Zap,    label: "Exécution",  color: "#00D4C8" },
                  { icon: Layers, label: "Structure",  color: "#FFB800" },
                ].map(({ icon: Icon, label, color }) => (
                  <div key={label} style={{
                    display: "flex", alignItems: "center", gap: 7,
                    padding: "8px 16px", borderRadius: 99,
                    background: "rgba(255,255,255,0.04)",
                    border: "1px solid rgba(255,255,255,0.08)",
                  }}>
                    <Icon size={13} color={color} />
                    <span style={{ fontSize: 12, fontWeight: 600, color: "rgba(237,237,255,0.7)" }}>{label}</span>
                  </div>
                ))}
              </motion.div>

              {/* CTA */}
              <motion.button
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.42, duration: 0.6, ease: EASE }}
                onClick={() => { setPhase("quiz"); setCurrentQ(0); setAnswers([]); }}
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
                style={{
                  display: "inline-flex", alignItems: "center", gap: 10,
                  padding: "16px 36px", borderRadius: 99,
                  background: "linear-gradient(135deg, #6D28D9 0%, #8B7FE8 100%)",
                  color: "#fff", fontWeight: 700, fontSize: 16,
                  border: "none", cursor: "pointer",
                  boxShadow: "0 0 40px rgba(109,40,217,0.4), inset 0 1px 0 rgba(255,255,255,0.12)",
                  marginBottom: 20,
                  fontFamily: "inherit",
                }}
              >
                Commencer l&apos;audit
                <ArrowRight size={18} />
              </motion.button>

              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.54, duration: 0.5 }}
                style={{ fontSize: 12, color: "rgba(237,237,255,0.28)" }}
              >
                Gratuit · Sans CB · Résultats immédiats
              </motion.p>

              {/* Social proof */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6, duration: 0.5 }}
                style={{
                  marginTop: 48,
                  display: "flex", alignItems: "center", gap: 10,
                  padding: "10px 18px", borderRadius: 12,
                  background: "rgba(255,255,255,0.03)",
                  border: "1px solid rgba(255,255,255,0.06)",
                }}
              >
                <div style={{ display: "flex" }}>
                  {["#8B7FE8", "#00D4C8", "#FFB800", "#FF4D6A", "#C4B5FD"].map((c, i) => (
                    <div key={i} style={{
                      width: 26, height: 26, borderRadius: "50%",
                      background: `radial-gradient(circle at 35% 35%, ${c}, ${c}99)`,
                      border: "2px solid #0D0B1E",
                      marginLeft: i === 0 ? 0 : -8,
                    }} />
                  ))}
                </div>
                <span style={{ fontSize: 12, color: "rgba(237,237,255,0.45)" }}>
                  <strong style={{ color: "rgba(237,237,255,0.75)" }}>2 847</strong> indépendants ont déjà fait leur audit
                </span>
              </motion.div>
            </motion.div>
          )}

          {/* ══════════════════════════════════════════════════════
              PHASE 2 — QUIZ
          ══════════════════════════════════════════════════════ */}
          {phase === "quiz" && (
            <motion.div
              key={`q-${currentQ}`}
              custom={direction}
              variants={pageVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.38, ease: EASE }}
              style={{
                minHeight: "calc(100vh - 64px)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                padding: "40px clamp(20px, 5vw, 64px)",
              }}
            >
              <div style={{ width: "100%", maxWidth: 600 }}>

                {/* Progress bar */}
                <div style={{ marginBottom: 36 }}>
                  <div style={{
                    display: "flex", justifyContent: "space-between", alignItems: "center",
                    marginBottom: 10,
                  }}>
                    <button
                      onClick={handleBack}
                      style={{
                        display: "flex", alignItems: "center", gap: 5,
                        background: "none", border: "none", cursor: "pointer",
                        color: "rgba(237,237,255,0.35)", fontSize: 12, fontWeight: 500,
                        padding: 0, fontFamily: "inherit",
                        transition: "color 0.2s",
                      }}
                    >
                      <ArrowLeft size={13} />
                      Retour
                    </button>
                    <span style={{ fontSize: 12, fontWeight: 600, color: "rgba(237,237,255,0.4)", letterSpacing: "0.06em" }}>
                      {currentQ + 1} / {QUESTIONS.length}
                    </span>
                  </div>
                  <div style={{ height: 4, borderRadius: 99, background: "rgba(237,237,255,0.07)", overflow: "hidden" }}>
                    <motion.div
                      style={{
                        height: "100%", borderRadius: 99,
                        background: "linear-gradient(90deg, #6D28D9, #8B7FE8)",
                        boxShadow: "0 0 12px rgba(109,40,217,0.5)",
                      }}
                      initial={false}
                      animate={{ width: `${((currentQ + 1) / QUESTIONS.length) * 100}%` }}
                      transition={{ duration: 0.4, ease: EASE }}
                    />
                  </div>
                </div>

                {/* Dimension badge */}
                <div style={{
                  display: "inline-flex", alignItems: "center", gap: 6,
                  padding: "4px 12px", borderRadius: 99, marginBottom: 20,
                  background: "rgba(109,40,217,0.12)",
                  border: "1px solid rgba(109,40,217,0.25)",
                  fontSize: 11, fontWeight: 600, color: "#8B7FE8",
                  textTransform: "uppercase", letterSpacing: "0.1em",
                }}>
                  {q.emoji} {q.dimLabel}
                </div>

                {/* Question */}
                <h2 style={{
                  fontSize: "clamp(1.3rem, 3.5vw, 1.75rem)",
                  fontWeight: 700, letterSpacing: "-0.025em", lineHeight: 1.25,
                  color: "#EDEDFF", marginBottom: 28,
                }}>
                  {q.question}
                </h2>

                {/* Options */}
                <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                  {q.options.map((opt) => {
                    const isSelected = selected === opt.letter;
                    return (
                      <motion.button
                        key={opt.letter}
                        onClick={() => handleSelect(opt.letter, opt.score)}
                        disabled={!!selected}
                        whileHover={!selected ? { scale: 1.015 } : {}}
                        whileTap={!selected ? { scale: 0.985 } : {}}
                        style={{
                          width: "100%",
                          display: "flex", alignItems: "center", gap: 14,
                          padding: "16px 20px", borderRadius: 14,
                          background: isSelected
                            ? "rgba(109,40,217,0.2)"
                            : "rgba(26,24,54,0.8)",
                          border: `1.5px solid ${isSelected
                            ? "rgba(109,40,217,0.65)"
                            : "rgba(34,32,74,0.9)"}`,
                          cursor: selected ? "not-allowed" : "pointer",
                          textAlign: "left",
                          transition: "background 0.2s, border-color 0.2s, box-shadow 0.2s",
                          boxShadow: isSelected ? "0 0 24px rgba(109,40,217,0.25)" : "none",
                          backdropFilter: "blur(10px)",
                          fontFamily: "inherit",
                        }}
                      >
                        {/* Letter badge */}
                        <span style={{
                          flexShrink: 0,
                          width: 30, height: 30, borderRadius: 8,
                          display: "flex", alignItems: "center", justifyContent: "center",
                          fontSize: 12, fontWeight: 700,
                          background: isSelected ? "rgba(109,40,217,0.5)" : "rgba(255,255,255,0.05)",
                          border: `1px solid ${isSelected ? "rgba(139,127,232,0.6)" : "rgba(255,255,255,0.08)"}`,
                          color: isSelected ? "#C4B5FD" : "rgba(237,237,255,0.45)",
                          transition: "all 0.2s",
                        }}>
                          {opt.letter}
                        </span>
                        <span style={{
                          fontSize: 14, fontWeight: 500, lineHeight: 1.4,
                          color: isSelected ? "#EDEDFF" : "rgba(237,237,255,0.75)",
                          transition: "color 0.2s",
                        }}>
                          {opt.text}
                        </span>
                        {isSelected && (
                          <motion.span
                            initial={{ scale: 0 }}
                            animate={{ scale: 1 }}
                            style={{ marginLeft: "auto", fontSize: 16 }}
                          >
                            ✓
                          </motion.span>
                        )}
                      </motion.button>
                    );
                  })}
                </div>
              </div>
            </motion.div>
          )}

          {/* ══════════════════════════════════════════════════════
              PHASE 3 — SCANNING
          ══════════════════════════════════════════════════════ */}
          {phase === "scanning" && (
            <motion.div
              key="scanning"
              custom={direction}
              variants={pageVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.5, ease: EASE }}
              style={{
                minHeight: "calc(100vh - 64px)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                padding: "40px clamp(20px, 5vw, 64px)",
                textAlign: "center",
              }}
            >
              {/* Radar rings */}
              <div style={{ position: "relative", width: 160, height: 160, marginBottom: 36 }}>
                {[1, 1.6, 2.2].map((scale, i) => (
                  <div
                    key={i}
                    style={{
                      position: "absolute",
                      inset: 0,
                      borderRadius: "50%",
                      border: "1.5px solid rgba(109,40,217,0.3)",
                      animation: "radar-ping 2.2s ease-out infinite",
                      animationDelay: `${i * 0.55}s`,
                      transform: `scale(${scale})`,
                    }}
                  />
                ))}
                <div style={{
                  position: "absolute", inset: 0,
                  borderRadius: "50%",
                  background: "radial-gradient(circle, rgba(109,40,217,0.2) 0%, transparent 70%)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  <KolybIcon size={56} variant="violet" animate={true} />
                </div>
              </div>

              <motion.h2
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1, duration: 0.5, ease: EASE }}
                style={{
                  fontSize: "clamp(1.4rem, 3vw, 1.75rem)",
                  fontWeight: 700, letterSpacing: "-0.025em",
                  color: "#EDEDFF", marginBottom: 10,
                }}
              >
                Analyse en cours...
              </motion.h2>
              <p style={{ fontSize: 14, color: "rgba(237,237,255,0.4)", marginBottom: 36 }}>
                Kolyb calcule ton profil psychoproductif
              </p>

              {/* Progress */}
              <div style={{ width: "min(320px, 90vw)" }}>
                <div style={{ height: 6, borderRadius: 99, background: "rgba(255,255,255,0.06)", overflow: "hidden", marginBottom: 8 }}>
                  <div style={{
                    height: "100%", borderRadius: 99,
                    background: "linear-gradient(90deg, #6D28D9, #8B7FE8, #00D4C8)",
                    width: `${scanProgress}%`,
                    transition: "width 0.1s linear",
                    boxShadow: "0 0 16px rgba(109,40,217,0.5)",
                  }} />
                </div>
                <p style={{ fontSize: 12, color: "rgba(237,237,255,0.25)", textAlign: "right" }}>
                  {scanProgress}%
                </p>
              </div>

              {/* Live labels */}
              <div style={{ display: "flex", gap: 8, marginTop: 20, flexWrap: "wrap", justifyContent: "center" }}>
                {[
                  { label: "Focus", done: scanProgress > 33 },
                  { label: "Exécution", done: scanProgress > 66 },
                  { label: "Structure", done: scanProgress > 90 },
                ].map(({ label, done }) => (
                  <span key={label} style={{
                    fontSize: 11, fontWeight: 600,
                    padding: "4px 10px", borderRadius: 99,
                    background: done ? "rgba(0,212,200,0.12)" : "rgba(255,255,255,0.04)",
                    border: `1px solid ${done ? "rgba(0,212,200,0.3)" : "rgba(255,255,255,0.07)"}`,
                    color: done ? "#00D4C8" : "rgba(237,237,255,0.3)",
                    transition: "all 0.4s",
                  }}>
                    {done ? "✓ " : ""}{label}
                  </span>
                ))}
              </div>
            </motion.div>
          )}

          {/* ══════════════════════════════════════════════════════
              PHASE 4 — EMAIL GATE
          ══════════════════════════════════════════════════════ */}
          {phase === "email" && (
            <motion.div
              key="email"
              custom={direction}
              variants={pageVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.5, ease: EASE }}
              style={{
                minHeight: "calc(100vh - 64px)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                padding: "40px clamp(20px, 5vw, 64px)",
                textAlign: "center",
              }}
            >
              <div style={{ width: "100%", maxWidth: 480 }}>
                {/* Teaser blurred card */}
                <motion.div
                  initial={{ opacity: 0, y: 20, scale: 0.96 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  transition={{ delay: 0.05, duration: 0.6, ease: EASE }}
                  style={{
                    position: "relative",
                    padding: "24px",
                    borderRadius: 18,
                    background: "rgba(26,24,54,0.9)",
                    border: "1px solid rgba(34,32,74,0.9)",
                    marginBottom: 28,
                    overflow: "hidden",
                  }}
                >
                  {/* Blurred content preview */}
                  <div style={{ filter: "blur(7px)", pointerEvents: "none", userSelect: "none" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                      <span style={{
                        padding: "5px 12px", borderRadius: 99, fontSize: 11, fontWeight: 700,
                        background: "rgba(255,77,106,0.15)", color: "#FF4D6A",
                        border: "1px solid rgba(255,77,106,0.3)",
                      }}>
                        🔴 Profil — ████████
                      </span>
                      <span style={{ fontSize: 28, fontWeight: 900, color: "#fff" }}>??/100</span>
                    </div>
                    <div style={{ height: 8, borderRadius: 99, background: "rgba(255,255,255,0.06)", marginBottom: 8 }}>
                      <div style={{ height: "100%", width: "45%", borderRadius: 99, background: "#FF4D6A" }} />
                    </div>
                    <div style={{ height: 8, borderRadius: 99, background: "rgba(255,255,255,0.06)", marginBottom: 8 }}>
                      <div style={{ height: "100%", width: "55%", borderRadius: 99, background: "#8B7FE8" }} />
                    </div>
                    <div style={{ height: 8, borderRadius: 99, background: "rgba(255,255,255,0.06)" }}>
                      <div style={{ height: "100%", width: "38%", borderRadius: 99, background: "#00D4C8" }} />
                    </div>
                  </div>
                  {/* Lock overlay */}
                  <div style={{
                    position: "absolute", inset: 0,
                    display: "flex", flexDirection: "column",
                    alignItems: "center", justifyContent: "center",
                    background: "rgba(13,11,30,0.35)",
                  }}>
                    <div style={{
                      width: 44, height: 44, borderRadius: 12,
                      background: "rgba(109,40,217,0.2)",
                      border: "1px solid rgba(109,40,217,0.4)",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      marginBottom: 8,
                    }}>
                      <Lock size={20} color="#8B7FE8" />
                    </div>
                    <span style={{ fontSize: 12, fontWeight: 600, color: "#C4B5FD" }}>Résultats verrouillés</span>
                  </div>
                </motion.div>

                {/* Email form */}
                <motion.div
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2, duration: 0.6, ease: EASE }}
                >
                  <h2 style={{
                    fontSize: "clamp(1.5rem, 4vw, 2rem)",
                    fontWeight: 800, letterSpacing: "-0.03em",
                    color: "#EDEDFF", marginBottom: 10,
                  }}>
                    Ton profil est prêt ✦
                  </h2>
                  <p style={{
                    fontSize: 14, color: "rgba(237,237,255,0.5)", lineHeight: 1.65,
                    marginBottom: 28,
                  }}>
                    Entre ton email pour révéler ton score, tes blocages identifiés et ta direction d&apos;amélioration.
                  </p>

                  {status === "error" && (
                    <p style={{ color: "#FF4D6A", fontSize: 13, marginBottom: 12 }}>{statusMsg}</p>
                  )}

                  <form onSubmit={handleEmailSubmit} style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                    <input
                      type="email" required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="ton@email.com"
                      style={{
                        width: "100%", padding: "15px 20px", borderRadius: 99,
                        background: "#1A1836", border: "1px solid #22204A",
                        color: "#EDEDFF", fontSize: 15, fontFamily: "inherit",
                        outline: "none", textAlign: "center",
                        transition: "border-color 0.2s, box-shadow 0.2s",
                      }}
                      onFocus={(e) => {
                        e.target.style.borderColor = "#6D28D9";
                        e.target.style.boxShadow = "0 0 0 3px rgba(109,40,217,0.14)";
                      }}
                      onBlur={(e) => {
                        e.target.style.borderColor = "#22204A";
                        e.target.style.boxShadow = "none";
                      }}
                    />
                    <motion.button
                      type="submit"
                      disabled={status === "loading"}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.97 }}
                      style={{
                        width: "100%", padding: "16px", borderRadius: 99,
                        background: "linear-gradient(135deg, #6D28D9 0%, #8B7FE8 100%)",
                        color: "#fff", fontWeight: 700, fontSize: 15,
                        border: "none", cursor: status === "loading" ? "not-allowed" : "pointer",
                        display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                        boxShadow: "0 0 32px rgba(109,40,217,0.35)",
                        fontFamily: "inherit",
                        opacity: status === "loading" ? 0.7 : 1,
                      }}
                    >
                      {status === "loading" ? (
                        <span style={{
                          width: 18, height: 18, display: "inline-block",
                          border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff",
                          borderRadius: "50%", animation: "spin 0.7s linear infinite",
                        }} />
                      ) : (
                        <> Révéler mes résultats <ArrowRight size={16} /> </>
                      )}
                    </motion.button>
                  </form>
                  <p style={{ fontSize: 11, color: "rgba(237,237,255,0.22)", marginTop: 12 }}>
                    0 spam · Uniquement tes résultats · RGPD · Tu te désinscrits quand tu veux
                  </p>
                </motion.div>
              </div>
            </motion.div>
          )}

          {/* ══════════════════════════════════════════════════════
              PHASE 5 — RESULTS
          ══════════════════════════════════════════════════════ */}
          {phase === "results" && scores && profile && (
            <motion.div
              key="results"
              custom={direction}
              variants={pageVariants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.6, ease: EASE }}
              style={{
                minHeight: "calc(100vh - 64px)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                padding: "60px clamp(20px, 5vw, 64px)",
              }}
            >
              <div style={{ width: "100%", maxWidth: 560 }}>

                {/* Profile header */}
                <motion.div
                  initial={{ opacity: 0, y: 24 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.05, duration: 0.6, ease: EASE }}
                  style={{ textAlign: "center", marginBottom: 32 }}
                >
                  <span style={{
                    display: "inline-block", fontSize: 11, fontWeight: 600,
                    letterSpacing: "0.12em", textTransform: "uppercase",
                    color: "#8B7FE8", marginBottom: 12,
                  }}>
                    Ton profil psychoproductif
                  </span>
                  <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 10, marginBottom: 12 }}>
                    <span style={{ fontSize: 28 }}>{profile.emoji}</span>
                    <h2 style={{
                      fontSize: "clamp(1.7rem, 4.5vw, 2.5rem)",
                      fontWeight: 800, letterSpacing: "-0.03em",
                      color: profile.color,
                    }}>
                      {profile.label}
                    </h2>
                  </div>
                  <p style={{
                    fontSize: "clamp(1rem, 2.5vw, 1.15rem)",
                    color: "rgba(237,237,255,0.65)", lineHeight: 1.6,
                    fontStyle: "italic",
                  }}>
                    &ldquo;{profile.tagline}&rdquo;
                  </p>
                </motion.div>

                {/* Score card */}
                <motion.div
                  initial={{ opacity: 0, y: 24, scale: 0.96 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  transition={{ delay: 0.15, duration: 0.65, ease: EASE }}
                  style={{
                    padding: "28px 28px 24px",
                    borderRadius: 20,
                    background: "rgba(26,24,54,0.85)",
                    border: `1px solid ${profile.colorBorder}`,
                    backdropFilter: "blur(16px)",
                    boxShadow: `0 0 40px ${profile.colorBg}`,
                    marginBottom: 16,
                  }}
                >
                  {/* Global score */}
                  <div style={{ textAlign: "center", marginBottom: 24 }}>
                    <div style={{
                      fontSize: 13, fontWeight: 600,
                      color: "rgba(237,237,255,0.4)",
                      textTransform: "uppercase", letterSpacing: "0.1em",
                      marginBottom: 4,
                    }}>
                      Score global
                    </div>
                    <div style={{ display: "flex", alignItems: "baseline", justifyContent: "center", gap: 4 }}>
                      <span style={{
                        fontSize: "clamp(3rem, 10vw, 5rem)",
                        fontWeight: 900, letterSpacing: "-0.04em", lineHeight: 1,
                        color: profile.color,
                      }}>
                        <AnimatedCounter target={scores.global} color={profile.color} />
                      </span>
                      <span style={{ fontSize: 20, fontWeight: 600, color: "rgba(237,237,255,0.3)" }}>/100</span>
                    </div>
                  </div>

                  {/* Problem tag */}
                  <div style={{
                    display: "inline-flex", alignItems: "center", gap: 6,
                    padding: "5px 12px", borderRadius: 99, marginBottom: 20,
                    background: profile.colorBg,
                    border: `1px solid ${profile.colorBorder}`,
                    fontSize: 11, fontWeight: 600,
                    color: profile.color,
                  }}>
                    ⚠️ {profile.problem}
                  </div>

                  {/* Sub-scores */}
                  <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
                    <ScoreBar label="Focus"     value={scores.focus}     color="#8B7FE8" icon={Brain}  delay={300} />
                    <ScoreBar label="Exécution" value={scores.execution} color="#00D4C8" icon={Zap}    delay={500} />
                    <ScoreBar label="Structure" value={scores.structure} color="#FFB800" icon={Layers} delay={700} />
                  </div>
                </motion.div>

                {/* Insight box */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.35, duration: 0.6, ease: EASE }}
                  style={{
                    padding: "20px 22px",
                    borderRadius: 16,
                    background: "rgba(109,40,217,0.07)",
                    border: "1px solid rgba(109,40,217,0.18)",
                    marginBottom: 16,
                  }}
                >
                  <p style={{ fontSize: 12, fontWeight: 700, color: "#8B7FE8", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 6 }}>
                    💡 Insight
                  </p>
                  <p style={{ fontSize: 15, color: "#EDEDFF", lineHeight: 1.65, fontWeight: 500 }}>
                    &ldquo;{profile.insight}&rdquo;
                  </p>
                </motion.div>

                {/* Solution + CTA */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.45, duration: 0.6, ease: EASE }}
                  style={{
                    padding: "20px 22px",
                    borderRadius: 16,
                    background: "rgba(26,24,54,0.8)",
                    border: "1px solid rgba(34,32,74,0.9)",
                    marginBottom: 28,
                  }}
                >
                  <p style={{ fontSize: 12, fontWeight: 700, color: "#00D4C8", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 6 }}>
                    🚀 La solution
                  </p>
                  <p style={{ fontSize: 15, color: "rgba(237,237,255,0.75)", lineHeight: 1.65 }}>
                    {profile.solution}
                  </p>
                </motion.div>

                {/* CTA */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.55, duration: 0.6, ease: EASE }}
                  style={{ textAlign: "center" }}
                >
                  <motion.a
                    href="/#waitlist"
                    whileHover={{ scale: 1.03 }}
                    whileTap={{ scale: 0.97 }}
                    style={{
                      display: "inline-flex", alignItems: "center", gap: 10,
                      padding: "16px 36px", borderRadius: 99,
                      background: "linear-gradient(135deg, #6D28D9 0%, #8B7FE8 100%)",
                      color: "#fff", fontWeight: 700, fontSize: 16,
                      textDecoration: "none",
                      boxShadow: "0 0 40px rgba(109,40,217,0.4), inset 0 1px 0 rgba(255,255,255,0.12)",
                      marginBottom: 16,
                    }}
                  >
                    {profile.ctaText} <ArrowRight size={18} />
                  </motion.a>
                  <p style={{ fontSize: 12, color: "rgba(237,237,255,0.25)" }}>
                    Gratuit · Sans CB · RGPD
                  </p>

                  {/* Retake */}
                  <button
                    onClick={() => {
                      setPhase("hero"); setCurrentQ(0); setAnswers([]);
                      setScores(null); setStatus("idle"); setEmail("");
                    }}
                    style={{
                      marginTop: 20, background: "none", border: "none",
                      fontSize: 12, color: "rgba(237,237,255,0.28)",
                      cursor: "pointer", fontFamily: "inherit",
                      textDecoration: "underline", textUnderlineOffset: 3,
                    }}
                  >
                    Refaire l&apos;audit
                  </button>
                </motion.div>
              </div>
            </motion.div>
          )}

        </AnimatePresence>
      </div>
    </div>
  );
}
