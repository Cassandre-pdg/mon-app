"use client";

import { useRef, useState } from "react";
import {
  motion,
  useScroll,
  useMotionValueEvent,
  AnimatePresence,
} from "framer-motion";

/* ─── Data ─────────────────────────────────────────────────── */

const FEATURES = [
  {
    id: "checkin",
    num: "01",
    eyebrow: "Check-in émotionnel",
    title: "Commence chaque journée avec intention.",
    sub: "Pas sur les mails. Sur toi.",
    description:
      "3 questions le matin, 3 minutes le soir. Ton état d'esprit posé, sans jugement, sans pression. Le fil rouge qui change tout.",
    accent: "#8B7FE8",
  },
  {
    id: "planner",
    num: "02",
    eyebrow: "Ma Journée",
    title: "Focus sur ce qui compte vraiment.",
    sub: "L'essentiel, pas l'exhaustif.",
    description:
      "3 priorités par jour. Un Pomodoro intégré. Une revue de semaine. Pas de liste infinie qui t'écrase. Juste l'avancement.",
    accent: "#00D4C8",
  },
  {
    id: "sleep",
    num: "03",
    eyebrow: "Mon Sommeil",
    title: "Ton corps est ton premier outil.",
    sub: "Prends soin de lui.",
    description:
      "Suis tes nuits en quelques secondes. Visualise ta récupération au fil du temps. Comprends ce qui t'aide à avancer vraiment.",
    accent: "#C4B5FD",
  },
  {
    id: "community",
    num: "04",
    eyebrow: "Le Salon",
    title: "Avance, mais jamais seul·e.",
    sub: "Une communauté qui te ressemble.",
    description:
      "Des groupes thématiques par métier. Des échanges vrais entre pairs. Pas d'algorithme de comparaison. Juste de l'entraide.",
    accent: "#FF4D6A",
  },
  {
    id: "badges",
    num: "05",
    eyebrow: "Badges & Streaks",
    title: "La régularité, récompensée.",
    sub: "Pas la performance. La constance.",
    description:
      "Chaque check-in, chaque journée planifiée, chaque nuit suivie compte. Tes efforts s'accumulent, visiblement, à ton rythme.",
    accent: "#FFB800",
  },
] as const;

/* ─── Phone screens ─────────────────────────────────────────── */

function CheckinScreen() {
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#8B7FE8" }}>
        Mon Check-in · Matin
      </p>
      <p className="ph-title">Comment tu vas ce matin ?</p>
      <p className="ph-sub">Choisis ce qui te correspond le mieux</p>
      <div className="ph-mood-row">
        {["😤", "😕", "😐", "🙂", "😊"].map((m, i) => (
          <div key={m} className={`ph-mood ${i === 4 ? "selected" : ""}`}>
            {m}
          </div>
        ))}
      </div>
      <div className="ph-card">
        <p style={{ fontSize: 9, color: "rgba(237,237,255,0.35)", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 6 }}>
          Ta pensée du matin
        </p>
        <p style={{ fontSize: 11, color: "rgba(237,237,255,0.5)", lineHeight: 1.5 }}>
          Aujourd&apos;hui je veux avancer sur mon projet...
        </p>
      </div>
      <div
        style={{
          marginTop: 14,
          padding: "10px 16px",
          background: "#6D28D9",
          borderRadius: 9999,
          fontSize: 11,
          fontWeight: 700,
          color: "#fff",
          textAlign: "center",
        }}
      >
        Commencer mon check-in →
      </div>
    </div>
  );
}

function PlannerScreen() {
  const tasks = [
    { done: true,  text: "Finaliser la présentation client" },
    { done: false, text: "Appeler le cabinet comptable" },
    { done: false, text: "Répondre aux 3 messages urgents" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#00D4C8" }}>
        Ma Journée · Aujourd&apos;hui
      </p>
      <p className="ph-title">3 priorités</p>
      <div className="ph-card" style={{ marginBottom: 10 }}>
        {tasks.map((t, i) => (
          <div key={i} className="ph-task">
            <div className={`ph-check ${t.done ? "done" : ""}`}>
              {t.done && (
                <svg width="8" height="6" viewBox="0 0 8 6" fill="none">
                  <path d="M1 3l2 2 4-4" stroke="#fff" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              )}
            </div>
            <span style={{ textDecoration: t.done ? "line-through" : "none", opacity: t.done ? 0.4 : 1 }}>
              {t.text}
            </span>
          </div>
        ))}
      </div>
      <div className="ph-card" style={{ textAlign: "center" }}>
        <p style={{ fontSize: 9, color: "#00D4C8", textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 4 }}>
          🍅 Pomodoro
        </p>
        <p className="ph-timer" style={{ color: "#EDEDFF" }}>23:41</p>
        <div style={{ display: "flex", gap: 8, justifyContent: "center" }}>
          <div style={{ padding: "6px 14px", background: "rgba(0,212,200,0.15)", borderRadius: 9999, fontSize: 10, color: "#00D4C8" }}>
            ⏸ Pause
          </div>
          <div style={{ padding: "6px 14px", background: "rgba(139,127,232,0.12)", borderRadius: 9999, fontSize: 10, color: "#8B7FE8" }}>
            ⏭ Skip
          </div>
        </div>
      </div>
    </div>
  );
}

function SleepScreen() {
  const bars = [
    { h: 40, day: "L" },
    { h: 65, day: "M" },
    { h: 55, day: "M" },
    { h: 75, day: "J" },
    { h: 50, day: "V" },
    { h: 80, day: "S" },
    { h: 70, day: "D" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#C4B5FD" }}>
        Mon Sommeil · Semaine
      </p>
      <div className="ph-stat-row">
        {[
          { val: "7.3h", lbl: "Moyenne" },
          { val: "22:45", lbl: "Coucher" },
          { val: "78%", lbl: "Qualité" },
        ].map((s) => (
          <div key={s.lbl} className="ph-stat">
            <span className="ph-stat-val" style={{ color: "#C4B5FD" }}>{s.val}</span>
            <span className="ph-stat-lbl">{s.lbl}</span>
          </div>
        ))}
      </div>
      <div className="ph-card">
        <div className="ph-bar-row">
          {bars.map((b, i) => (
            <div
              key={i}
              className="ph-bar"
              style={{
                height: `${b.h}%`,
                background: i === 5
                  ? "linear-gradient(180deg, #C4B5FD, #8B7FE8)"
                  : "rgba(196,181,253,0.25)",
              }}
            />
          ))}
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", paddingTop: 6 }}>
          {bars.map((b, i) => (
            <span key={i} style={{ flex: 1, textAlign: "center", fontSize: 8, color: "rgba(237,237,255,0.3)" }}>
              {b.day}
            </span>
          ))}
        </div>
      </div>
      <div
        style={{
          marginTop: 10,
          padding: "10px",
          background: "rgba(196,181,253,0.08)",
          border: "1px solid rgba(196,181,253,0.15)",
          borderRadius: 10,
          fontSize: 10,
          color: "rgba(237,237,255,0.5)",
          lineHeight: 1.5,
        }}
      >
        ✨ Belle semaine. Samedi était ta meilleure nuit.
      </div>
    </div>
  );
}

function CommunityScreen() {
  const posts = [
    { initials: "JM", name: "Julie M.", time: "2h", text: "Qui utilise Notion pour ses devis ? J'hésite encore...", likes: 12, comments: 5 },
    { initials: "TR", name: "Tom R.", time: "4h", text: "Première mission terminée 🎉 merci pour vos conseils la semaine dernière !", likes: 24, comments: 8 },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#FF4D6A" }}>
        Le Salon · Freelances
      </p>
      <div
        style={{
          display: "flex",
          gap: 6,
          marginBottom: 12,
          overflowX: "hidden",
        }}
      >
        {["#général", "#outils", "#entraide"].map((ch, i) => (
          <span
            key={ch}
            style={{
              padding: "3px 8px",
              borderRadius: 9999,
              fontSize: 9,
              fontWeight: 600,
              background: i === 0 ? "rgba(255,77,106,0.2)" : "rgba(139,127,232,0.1)",
              color: i === 0 ? "#FF4D6A" : "rgba(237,237,255,0.4)",
              border: `1px solid ${i === 0 ? "rgba(255,77,106,0.35)" : "rgba(139,127,232,0.15)"}`,
              whiteSpace: "nowrap",
            }}
          >
            {ch}
          </span>
        ))}
      </div>
      {posts.map((p, i) => (
        <div key={i} className="ph-post">
          <div className="ph-post-head">
            <div
              className="ph-avatar"
              style={{
                background: i === 0
                  ? "linear-gradient(135deg, #FF4D6A, #FFB800)"
                  : "linear-gradient(135deg, #6D28D9, #00D4C8)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 8,
                fontWeight: 700,
                color: "#fff",
              }}
            >
              {p.initials}
            </div>
            <span className="ph-post-name">{p.name}</span>
            <span className="ph-post-time">· {p.time}</span>
          </div>
          <p className="ph-post-text">{p.text}</p>
          <div className="ph-post-actions">
            <span className="ph-action">❤️ {p.likes}</span>
            <span className="ph-action">💬 {p.comments}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function BadgesScreen() {
  const badges = [
    { icon: "🔥", label: "7 jours\nde suite" },
    { icon: "⭐", label: "Check-in\nrégulier" },
    { icon: "🏅", label: "Planif.\nmaster" },
    { icon: "💎", label: "Relevé\naprès pause" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#FFB800" }}>
        Mes Badges · Niveau 2
      </p>
      <div className="ph-card" style={{ marginBottom: 10, textAlign: "center" }}>
        <p style={{ fontSize: 9, color: "rgba(237,237,255,0.4)", marginBottom: 4 }}>
          Indépendant · 240 / 300 pts
        </p>
        <div className="ph-xp-bar-bg">
          <div className="ph-xp-bar-fill" style={{ width: "80%" }} />
        </div>
        <p style={{ fontSize: 9, color: "rgba(255,184,0,0.7)", marginTop: 4 }}>
          60 pts avant Entrepreneur ✨
        </p>
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "8px 12px",
          background: "rgba(255,184,0,0.1)",
          border: "1px solid rgba(255,184,0,0.25)",
          borderRadius: 10,
          marginBottom: 10,
        }}
      >
        <span style={{ fontSize: 24 }}>🔥</span>
        <div>
          <p style={{ fontSize: 11, fontWeight: 700, color: "#FFB800" }}>Streak actif : 7 jours</p>
          <p style={{ fontSize: 9, color: "rgba(237,237,255,0.4)" }}>Continue comme ça 💪</p>
        </div>
      </div>
      <div className="ph-badge-grid">
        {badges.map((b, i) => (
          <div key={i} className="ph-badge-card">
            <span className="ph-badge-icon">{b.icon}</span>
            <p className="ph-badge-label" style={{ whiteSpace: "pre-line" }}>{b.label}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

const SCREENS: Record<string, React.ReactNode> = {
  checkin:   <CheckinScreen />,
  planner:   <PlannerScreen />,
  sleep:     <SleepScreen />,
  community: <CommunityScreen />,
  badges:    <BadgesScreen />,
};

/* ─── Main component ────────────────────────────────────────── */

const EASE = [0.16, 1, 0.3, 1] as const;

export default function PinnedShowcase() {
  const containerRef = useRef<HTMLDivElement>(null);
  const [activeIndex, setActiveIndex] = useState(0);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  useMotionValueEvent(scrollYProgress, "change", (v) => {
    const idx = Math.min(
      Math.floor(v * FEATURES.length),
      FEATURES.length - 1
    );
    setActiveIndex(idx);
  });

  const feature = FEATURES[activeIndex];

  return (
    <section
      ref={containerRef}
      className="pinned-outer"
      style={{ height: `${FEATURES.length * 100}vh` }}
      id="features"
    >
      {/* Section label */}
      <div className="pinned-inner">
        {/* Progress rail */}
        <div className="feature-progress-rail" aria-hidden="true">
          {FEATURES.map((_, i) => (
            <div
              key={i}
              className={`feature-progress-dot ${i === activeIndex ? "active" : ""}`}
            />
          ))}
        </div>

        {/* Background accent glow */}
        <motion.div
          key={feature.id + "-glow"}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.8 }}
          style={{
            position: "absolute",
            inset: 0,
            background: `radial-gradient(ellipse 60% 40% at 70% 50%, ${feature.accent}18, transparent 70%)`,
            pointerEvents: "none",
          }}
          aria-hidden="true"
        />

        <div className="pinned-layout">
          {/* Left — feature text */}
          <div style={{ position: "relative" }}>
            <AnimatePresence mode="wait">
              <motion.div
                key={feature.id}
                initial={{ opacity: 0, y: 32 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.55, ease: EASE }}
              >
                <motion.div
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: 8,
                    padding: "6px 14px",
                    borderRadius: 9999,
                    fontSize: 11,
                    fontWeight: 700,
                    letterSpacing: "0.08em",
                    textTransform: "uppercase",
                    background: `${feature.accent}1A`,
                    border: `1px solid ${feature.accent}40`,
                    color: feature.accent,
                    marginBottom: 24,
                  }}
                >
                  <span style={{ opacity: 0.5 }}>{feature.num}</span>
                  {feature.eyebrow}
                </motion.div>

                <h2
                  style={{
                    fontSize: "clamp(2rem, 4vw, 3.25rem)",
                    fontWeight: 800,
                    lineHeight: 1.1,
                    letterSpacing: "-0.03em",
                    color: "#EDEDFF",
                    marginBottom: 12,
                  }}
                >
                  {feature.title}
                </h2>

                <p
                  style={{
                    fontSize: "clamp(1rem, 1.5vw, 1.25rem)",
                    fontWeight: 600,
                    color: feature.accent,
                    marginBottom: 16,
                    opacity: 0.8,
                  }}
                >
                  {feature.sub}
                </p>

                <p
                  style={{
                    fontSize: 16,
                    color: "rgba(237,237,255,0.55)",
                    lineHeight: 1.75,
                    maxWidth: 420,
                  }}
                >
                  {feature.description}
                </p>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right — phone mockup */}
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
            }}
          >
            <motion.div
              style={{
                filter: `drop-shadow(0 0 60px ${feature.accent}35)`,
              }}
              animate={{
                y: [0, -8, 0],
                filter: [
                  `drop-shadow(0 0 40px ${feature.accent}25)`,
                  `drop-shadow(0 0 70px ${feature.accent}45)`,
                  `drop-shadow(0 0 40px ${feature.accent}25)`,
                ],
              }}
              transition={{
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            >
              <div
                className="phone-frame"
                style={{ borderColor: `${feature.accent}35` }}
              >
                <div className="phone-notch" />
                <div className="phone-status">
                  <span>09:30</span>
                  <span style={{ letterSpacing: 2 }}>···</span>
                </div>
                <AnimatePresence mode="wait">
                  <motion.div
                    key={feature.id + "-screen"}
                    initial={{ opacity: 0, y: 16 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.4, ease: EASE }}
                    style={{ height: "100%" }}
                  >
                    {SCREENS[feature.id]}
                  </motion.div>
                </AnimatePresence>
                <div className="phone-home-bar" style={{ background: `${feature.accent}40` }} />
              </div>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  );
}
