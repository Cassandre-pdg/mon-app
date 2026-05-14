"use client";

import { useRef, useState, useEffect } from "react";
import {
  motion,
  useScroll,
  useTransform,
  useMotionValueEvent,
  AnimatePresence,
} from "framer-motion";

/* ─── Data ──────────────────────────────────────────────────── */

const FEATURES = [
  {
    id: "Problématique",
    num: "01",
    eyebrow: "Le problème.",
    title: "Tu progresses sans mesure.",
    sub: "Donc tu progresses sans preuve.",
    description:
      "Tu stagnes sans t'en rendre compte. Reprends le contrôle avec des check-ins rapides. Visualise ta progression mentale et émotionnelle. Comprends ce qui t'aide vraiment à avancer.",
    accent: "#8B7FE8",
  },
  {
    id: "CLARTÉ",
    num: "02",
    eyebrow: "Clarté & Focus",
    title: "Focus sur ce qui compte vraiment.",
    sub: "Ton niveau n'est plus une impression.",
    description:
      "Kolyb transforme tes actions en une lecture claire de ta progression réelle.",
    accent: "#00D4C8",
  },
  {
    id: "score",
    num: "03",
    eyebrow: "Score",
    title: "Chaque jour a de la valeur.",
    sub: "Ta discipline devient mesurable",
    description:
      "Chaque action alimente un score de progression qui reflète ton niveau réel.",
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
    id: "STATUT",
    num: "05",
    eyebrow: "Statut & Badges",
    title: "La régularité, récompensée.",
    sub: "Pas la performance. La constance.",
    description:
      "Chaque check-in, chaque journée planifiée, chaque nuit suivie compte. Tes efforts s'accumulent, visiblement, à ton rythme.",
    accent: "#FFB800",
  },
] as const;

type Feature = (typeof FEATURES)[number];

/* ─── Phone screens ─────────────────────────────────────────── */

/* Slide 01 — "Tu progresses sans mesure" → le check-in comme solution */
function CheckinScreen() {
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#8B7FE8" }}>Mon Check-in · Matin</p>

      {/* Streak + points — la mesure quotidienne */}
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14 }}>
        <span style={{ fontSize: 10, fontWeight: 700, color: "#8B7FE8" }}>🔥 Jour 7</span>
        <div style={{ flex: 1, height: 3, borderRadius: 2, background: "rgba(139,127,232,0.12)" }}>
          <div style={{ width: "70%", height: "100%", borderRadius: 2, background: "linear-gradient(90deg,#6D28D9,#8B7FE8)" }} />
        </div>
        <span style={{ fontSize: 10, fontWeight: 600, color: "rgba(139,127,232,0.6)" }}>+5 pts</span>
      </div>

      <p className="ph-title">Comment tu vas ce matin ?</p>
      <p className="ph-sub">Choisis ce qui te correspond le mieux</p>

      <div className="ph-mood-row">
        {["😤", "😕", "😐", "🙂", "😊"].map((m, i) => (
          <div key={m} className={`ph-mood ${i === 4 ? "selected" : ""}`}>{m}</div>
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

      <div style={{ marginTop: 14, padding: "10px 16px", background: "#6D28D9", borderRadius: 9999, fontSize: 11, fontWeight: 700, color: "#fff", textAlign: "center" }}>
        Commencer mon check-in →
      </div>
    </div>
  );
}

/* Slide 02 — "Focus sur ce qui compte vraiment" → planner 3 priorités */
function PlannerScreen() {
  const tasks = [
    { done: true,  text: "Finaliser la présentation client" },
    { done: false, text: "Appeler le cabinet comptable" },
    { done: false, text: "Répondre aux 3 messages urgents" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#00D4C8" }}>Ma Journée · Aujourd&apos;hui</p>
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
            <span style={{ textDecoration: t.done ? "line-through" : "none", opacity: t.done ? 0.4 : 1 }}>{t.text}</span>
          </div>
        ))}
      </div>
      <div className="ph-card" style={{ textAlign: "center" }}>
        <p style={{ fontSize: 9, color: "#00D4C8", textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 4 }}>🍅 Pomodoro</p>
        <p className="ph-timer" style={{ color: "#EDEDFF" }}>23:41</p>
        <div style={{ display: "flex", gap: 8, justifyContent: "center" }}>
          <div style={{ padding: "6px 14px", background: "rgba(0,212,200,0.15)", borderRadius: 9999, fontSize: 10, color: "#00D4C8" }}>⏸ Pause</div>
          <div style={{ padding: "6px 14px", background: "rgba(139,127,232,0.12)", borderRadius: 9999, fontSize: 10, color: "#8B7FE8" }}>⏭ Skip</div>
        </div>
      </div>
    </div>
  );
}

/* Slide 03 — "Chaque jour a de la valeur" → score & progression */
function ScoreScreen() {
  const bars   = [40, 65, 55, 75, 68, 82, 95];
  const days   = ["L", "M", "M", "J", "V", "S", "D"];

  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#C4B5FD" }}>Mon Score · Cette semaine</p>

      {/* Score + niveau */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
        <div>
          <p style={{ fontSize: 9, color: "rgba(237,237,255,0.3)", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 2 }}>
            Score aujourd&apos;hui
          </p>
          <p style={{ fontSize: 34, fontWeight: 800, color: "#C4B5FD", letterSpacing: "-0.04em", lineHeight: 1 }}>247</p>
        </div>
        <div style={{ padding: "5px 10px", background: "rgba(196,181,253,0.12)", border: "1px solid rgba(196,181,253,0.25)", borderRadius: 20, marginTop: 4 }}>
          <span style={{ fontSize: 10, fontWeight: 600, color: "#C4B5FD" }}>Indépendant</span>
        </div>
      </div>

      {/* Histogramme 7 jours */}
      <div className="ph-card" style={{ marginBottom: 10 }}>
        <p style={{ fontSize: 9, color: "rgba(237,237,255,0.3)", marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.08em" }}>
          Progression · 7 jours
        </p>
        <div className="ph-bar-row" style={{ height: 48 }}>
          {bars.map((h, i) => (
            <div
              key={i}
              className="ph-bar"
              style={{
                height: `${h}%`,
                background: i === 6
                  ? "linear-gradient(180deg,#C4B5FD,#8B7FE8)"
                  : "rgba(196,181,253,0.2)",
              }}
            />
          ))}
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", paddingTop: 4 }}>
          {days.map((d, i) => (
            <span key={i} style={{ flex: 1, textAlign: "center", fontSize: 8, color: i === 6 ? "#C4B5FD" : "rgba(237,237,255,0.3)" }}>{d}</span>
          ))}
        </div>
      </div>

      {/* Barre XP */}
      <div className="ph-card">
        <p style={{ fontSize: 9, color: "rgba(237,237,255,0.3)", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 6 }}>
          Vers niveau suivant
        </p>
        <div className="ph-xp-bar-bg">
          <div className="ph-xp-bar-fill" style={{ width: "82%", background: "linear-gradient(90deg,#8B7FE8,#C4B5FD)" }} />
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", marginTop: 4 }}>
          <span style={{ fontSize: 9, color: "rgba(237,237,255,0.3)" }}>247 pts</span>
          <span style={{ fontSize: 9, color: "#C4B5FD" }}>→ Entrepreneur (300)</span>
        </div>
      </div>
    </div>
  );
}

/* Slide 04 — "Avance, jamais seul·e" → Le Salon (INCHANGÉ) */
function CommunityScreen() {
  const posts = [
    { initials: "JM", name: "Julie M.", time: "2h", text: "Qui utilise Notion pour ses devis ? J'hésite encore...", likes: 12, comments: 5, grad: "linear-gradient(135deg,#FF4D6A,#FFB800)" },
    { initials: "TR", name: "Tom R.",   time: "4h", text: "Première mission terminée 🎉 merci pour vos conseils !", likes: 24, comments: 8, grad: "linear-gradient(135deg,#6D28D9,#00D4C8)" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#FF4D6A" }}>Le Salon · Freelances</p>
      <div style={{ display: "flex", gap: 6, marginBottom: 12, overflowX: "hidden" }}>
        {["#général", "#outils", "#entraide"].map((ch, i) => (
          <span key={ch} style={{ padding: "3px 8px", borderRadius: 9999, fontSize: 9, fontWeight: 600, background: i === 0 ? "rgba(255,77,106,0.2)" : "rgba(139,127,232,0.1)", color: i === 0 ? "#FF4D6A" : "rgba(237,237,255,0.4)", border: `1px solid ${i === 0 ? "rgba(255,77,106,0.35)" : "rgba(139,127,232,0.15)"}`, whiteSpace: "nowrap" }}>{ch}</span>
        ))}
      </div>
      {posts.map((p, i) => (
        <div key={i} className="ph-post">
          <div className="ph-post-head">
            <div className="ph-avatar" style={{ background: p.grad, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 8, fontWeight: 700, color: "#fff" }}>{p.initials}</div>
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

/* Slide 05 — "La régularité, récompensée" → badges & streaks */
function BadgesScreen() {
  const badges = [
    { icon: "🔥", label: "7 jours\nde suite" },
    { icon: "⭐", label: "Check-in\nrégulier" },
    { icon: "🏅", label: "Planif.\nmaster" },
    { icon: "💎", label: "Relevé\naprès pause" },
  ];
  return (
    <div className="phone-body">
      <p className="ph-header" style={{ color: "#FFB800" }}>Mes Badges · Niveau 2</p>
      <div className="ph-card" style={{ marginBottom: 10, textAlign: "center" }}>
        <p style={{ fontSize: 9, color: "rgba(237,237,255,0.4)", marginBottom: 4 }}>Indépendant · 240 / 300 pts</p>
        <div className="ph-xp-bar-bg"><div className="ph-xp-bar-fill" style={{ width: "80%" }} /></div>
        <p style={{ fontSize: 9, color: "rgba(255,184,0,0.7)", marginTop: 4 }}>60 pts avant Entrepreneur ✨</p>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 12px", background: "rgba(255,184,0,0.1)", border: "1px solid rgba(255,184,0,0.25)", borderRadius: 10, marginBottom: 10 }}>
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

/* ─── Mapping feature.id → écran phone ─────────────────────── */
const SCREENS: Record<string, React.ReactNode> = {
  "Problématique": <CheckinScreen />,
  "CLARTÉ":        <PlannerScreen />,
  "score":         <ScoreScreen />,
  "community":     <CommunityScreen />,
  "STATUT":        <BadgesScreen />,
};

/* ─── Slide ──────────────────────────────────────────────────── */

function FeatureSlide({ feature }: { feature: Feature }) {
  return (
    <div style={{ width: "100%", height: "100%", position: "relative", overflow: "hidden" }}>

      {/* Background radial glow */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", right: "-8%", top: "50%", transform: "translateY(-50%)",
          width: "55%", paddingBottom: "55%",
          background: `radial-gradient(ellipse at center, ${feature.accent}1C 0%, transparent 68%)`,
          pointerEvents: "none",
        }}
      />

      {/* Grid subtil */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", inset: 0,
          backgroundImage: "linear-gradient(rgba(139,127,232,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.03) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
          pointerEvents: "none",
        }}
      />

      {/* Numéro filigrane */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", right: "3%", bottom: "-4%",
          fontSize: "clamp(120px, 19vw, 260px)", fontWeight: 900,
          color: `${feature.accent}0C`, lineHeight: 1,
          letterSpacing: "-0.06em", userSelect: "none", pointerEvents: "none",
        }}
      >
        {feature.num}
      </div>

      {/* Content */}
      <div className="h-slide-inner">
        {/* Gauche — texte */}
        <div className="h-slide-text">
          <div style={{
            display: "inline-flex", alignItems: "center", gap: 8,
            padding: "6px 14px", borderRadius: 9999,
            fontSize: 11, fontWeight: 700, letterSpacing: "0.08em", textTransform: "uppercase" as const,
            background: `${feature.accent}1A`, border: `1px solid ${feature.accent}40`,
            color: feature.accent, marginBottom: 28,
          }}>
            <span style={{ opacity: 0.45 }}>{feature.num}</span>
            {feature.eyebrow}
          </div>

          <h2 style={{
            fontSize: "clamp(1.85rem, 4vw, 3.25rem)", fontWeight: 800,
            lineHeight: 1.08, letterSpacing: "-0.035em", color: "#EDEDFF", marginBottom: 14,
          }}>
            {feature.title}
          </h2>

          <p style={{
            fontSize: "clamp(0.95rem, 1.3vw, 1.15rem)", fontWeight: 600,
            color: feature.accent, marginBottom: 20, opacity: 0.85,
          }}>
            {feature.sub}
          </p>

          <p style={{ fontSize: 15, color: "rgba(237,237,255,0.55)", lineHeight: 1.8, maxWidth: 400 }}>
            {feature.description}
          </p>
        </div>

        {/* Droite — phone */}
        <div className="h-slide-phone">
          <motion.div
            animate={{
              y: [0, -10, 0],
              filter: [
                `drop-shadow(0 24px 60px ${feature.accent}28)`,
                `drop-shadow(0 24px 88px ${feature.accent}50)`,
                `drop-shadow(0 24px 60px ${feature.accent}28)`,
              ],
            }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
          >
            <div
              className="phone-frame"
              style={{ width: 270, height: 540, borderColor: `${feature.accent}38` }}
            >
              <div className="phone-notch" />
              <div className="phone-status">
                <span>09:30</span>
                <span style={{ letterSpacing: 2 }}>···</span>
              </div>
              {SCREENS[feature.id]}
              <div className="phone-home-bar" style={{ background: `${feature.accent}45` }} />
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}

/* ─── Mobile layout — cartes verticales, pas de scroll-jacking ── */

/* Scale = 0.62 → phone 270×540 devient 167×335 */
const PHONE_SCALE = 0.62;
const PHONE_W = Math.round(270 * PHONE_SCALE);
const PHONE_H = Math.round(540 * PHONE_SCALE);

function MobileShowcase() {
  return (
    <section id="features" style={{ padding: "72px 16px 60px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 32, maxWidth: 480, margin: "0 auto" }}>
        {FEATURES.map((f) => (
          <motion.div
            key={f.id}
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-40px" }}
            transition={{ duration: 0.55, ease: [0.22, 1, 0.36, 1] }}
            style={{
              background: "#1A1836",
              border: `1px solid ${f.accent}28`,
              borderRadius: 24,
              padding: "24px 20px 28px",
              position: "relative",
              overflow: "hidden",
            }}
          >
            {/* Glow coin supérieur droit */}
            <div style={{
              position: "absolute", top: 0, right: 0,
              width: 160, height: 160,
              background: `radial-gradient(ellipse at top right, ${f.accent}1A 0%, transparent 70%)`,
              pointerEvents: "none",
            }} />

            {/* Badge eyebrow */}
            <div style={{
              display: "inline-flex", alignItems: "center", gap: 6,
              padding: "4px 12px", borderRadius: 9999, marginBottom: 14,
              fontSize: 10, fontWeight: 700, letterSpacing: "0.08em", textTransform: "uppercase",
              background: `${f.accent}18`, border: `1px solid ${f.accent}35`, color: f.accent,
            }}>
              <span style={{ opacity: 0.45 }}>{f.num}</span>{f.eyebrow}
            </div>

            <h3 style={{
              fontSize: "1.2rem", fontWeight: 800, lineHeight: 1.1,
              letterSpacing: "-0.03em", color: "#EDEDFF", marginBottom: 8,
            }}>{f.title}</h3>

            <p style={{ fontSize: 13, fontWeight: 600, color: f.accent, marginBottom: 10, opacity: 0.85 }}>
              {f.sub}
            </p>

            <p style={{ fontSize: 13, color: "rgba(237,237,255,0.52)", lineHeight: 1.7, marginBottom: 24 }}>
              {f.description}
            </p>

            {/* Phone frame centré et réduit */}
            <div style={{ display: "flex", justifyContent: "center" }}>
              <motion.div
                animate={{ y: [0, -6, 0], filter: [`drop-shadow(0 16px 40px ${f.accent}20)`, `drop-shadow(0 16px 56px ${f.accent}40)`, `drop-shadow(0 16px 40px ${f.accent}20)`] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              >
                {/* Wrapper qui absorbe le scale */}
                <div style={{ width: PHONE_W, height: PHONE_H, overflow: "hidden", borderRadius: Math.round(40 * PHONE_SCALE), flexShrink: 0 }}>
                  <div style={{ width: 270, height: 540, transform: `scale(${PHONE_SCALE})`, transformOrigin: "top left" }}>
                    <div
                      className="phone-frame"
                      style={{ width: 270, height: 540, borderColor: `${f.accent}38` }}
                    >
                      <div className="phone-notch" />
                      <div className="phone-status">
                        <span>09:30</span>
                        <span style={{ letterSpacing: 2 }}>···</span>
                      </div>
                      {SCREENS[f.id]}
                      <div className="phone-home-bar" style={{ background: `${f.accent}45` }} />
                    </div>
                  </div>
                </div>
              </motion.div>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}

/* ─── Main component ─────────────────────────────────────────── */

const N = FEATURES.length;

export default function HorizontalShowcase() {
  const containerRef = useRef<HTMLDivElement>(null);
  const [activeIndex, setActiveIndex] = useState(0);
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768);
    check();
    window.addEventListener("resize", check);
    return () => window.removeEventListener("resize", check);
  }, []);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  const x = useTransform(
    scrollYProgress,
    [0, 1],
    ["0vw", `-${(N - 1) * 100}vw`]
  );

  useMotionValueEvent(scrollYProgress, "change", (v) => {
    const idx = Math.max(0, Math.min(Math.round(v * (N - 1)), N - 1));
    setActiveIndex(idx);
  });

  const activeFeature = FEATURES[activeIndex];

  if (isMobile) return <MobileShowcase />;

  return (
    <section
      ref={containerRef}
      style={{ height: `${N * 100}dvh` }}
      id="features"
    >
      <div style={{ position: "sticky", top: 0, height: "100dvh", overflow: "hidden" }}>

        {/* Barre de progression */}
        <motion.div
          style={{
            position: "absolute", top: 0, left: 0, right: 0, height: 2,
            background: activeFeature.accent,
            scaleX: scrollYProgress,
            transformOrigin: "0 0",
            zIndex: 10,
            transition: "background 0.5s ease",
          }}
        />

        {/* Compteur */}
        <div style={{
          position: "absolute", top: 28, right: "clamp(20px, 4vw, 48px)",
          zIndex: 10, fontSize: 12, fontWeight: 600,
          color: "rgba(237,237,255,0.38)", letterSpacing: "0.08em",
        }}>
          <span style={{ color: activeFeature.accent, transition: "color 0.4s ease" }}>
            {String(activeIndex + 1).padStart(2, "0")}
          </span>
          {" / "}{String(N).padStart(2, "0")}
        </div>

        {/* Dots nav */}
        <div style={{
          position: "absolute", bottom: 32, left: "50%", transform: "translateX(-50%)",
          display: "flex", gap: 7, zIndex: 10, alignItems: "center",
        }}>
          {FEATURES.map((f, i) => (
            <div
              key={i}
              style={{
                height: 6,
                width: i === activeIndex ? 26 : 6,
                borderRadius: 3,
                background: i === activeIndex ? f.accent : "rgba(237,237,255,0.14)",
                transition: "all 0.45s cubic-bezier(0.16, 1, 0.3, 1)",
              }}
            />
          ))}
        </div>

        {/* Scroll hint */}
        <AnimatePresence>
          {activeIndex === 0 && (
            <motion.div
              key="hint"
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 4 }}
              transition={{ delay: 0.6, duration: 0.5 }}
              style={{
                position: "absolute", bottom: 68, left: "50%", transform: "translateX(-50%)",
                zIndex: 10, display: "flex", alignItems: "center", gap: 7,
                fontSize: 10, color: "rgba(237,237,255,0.28)",
                letterSpacing: "0.1em", textTransform: "uppercase",
                whiteSpace: "nowrap",
              }}
            >
              <motion.span animate={{ y: [0, 4, 0] }} transition={{ duration: 1.4, repeat: Infinity }}>↓</motion.span>
              Scroll pour découvrir les fonctionnalités
              <motion.span animate={{ y: [0, 4, 0] }} transition={{ duration: 1.4, repeat: Infinity, delay: 0.7 }}>↓</motion.span>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Track horizontal */}
        <motion.div
          style={{
            display: "flex",
            height: "100%",
            x,
            willChange: "transform",
          }}
        >
          {FEATURES.map((feature) => (
            <div
              key={feature.id}
              style={{ width: "100vw", height: "100%", flexShrink: 0 }}
            >
              <FeatureSlide feature={feature} />
            </div>
          ))}
        </motion.div>

      </div>
    </section>
  );
}
