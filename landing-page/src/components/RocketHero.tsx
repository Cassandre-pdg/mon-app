"use client";

import { useRef, useState, useEffect } from "react";
import {
  motion,
  useScroll,
  useTransform,
  useMotionValueEvent,
  type MotionValue,
} from "framer-motion";
import { ArrowRight } from "lucide-react";
import KolybIcon from "./KolybIcon";

/* ─── Deterministic stars ────────────────────────────────────────────────── */
const STARS = Array.from({ length: 130 }, (_, i) => ({
  x: (i * 137.508 + 23.7) % 100,
  y: (i * 97.312 + 13.1) % 100,
  r: 0.5 + (i % 4) * 0.35,
  o: 0.15 + (i % 6) * 0.1,
  dur: 2 + (i % 5) * 0.6,
  del: (i * 0.23) % 3,
}));

const TAGLINE = ["Décide.", "Agis.", "Progresse."];
const APP_STORE_URL = "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978";

/* ─── Atmosphere ─────────────────────────────────────────────────────────── */
function Atmosphere({ p }: { p: MotionValue<number> }) {
  const gridOp  = useTransform(p, [0, 0.30], [1, 0]);
  const spaceOp = useTransform(p, [0.12, 0.50], [0, 1]);
  const glowOp  = useTransform(p, [0, 0.55, 1], [1, 0.4, 0]);

  return (
    <div style={{ position: "absolute", inset: 0 }}>
      <div style={{ position: "absolute", inset: 0, background: "#0D0B1E" }} />
      <motion.div
        style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(ellipse 70% 50% at 50% 100%, rgba(109,40,217,0.45) 0%, transparent 70%)",
          opacity: glowOp,
        }}
      />
      <motion.div
        style={{
          position: "absolute", inset: 0,
          backgroundImage:
            "linear-gradient(rgba(139,127,232,0.045) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.045) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
          opacity: gridOp,
        }}
      />
      <motion.div
        style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(ellipse 100% 60% at 50% 0%, rgba(0,0,8,0.9) 0%, transparent 60%)",
          opacity: spaceOp,
        }}
      />
    </div>
  );
}

/* ─── Flame ──────────────────────────────────────────────────────────────── */
function Flame() {
  return (
    <div style={{ position: "relative", width: 70, height: 90, pointerEvents: "none" }}>
      <div
        style={{
          position: "absolute", left: "50%", top: 0,
          width: 56, height: 80,
          background: "radial-gradient(ellipse at top, rgba(255,184,0,0.35) 0%, transparent 70%)",
          transform: "translateX(-50%)",
          filter: "blur(10px)",
          animation: "flame-glow 0.22s ease-in-out infinite alternate",
        }}
      />
      <div
        style={{
          position: "absolute", left: "50%", top: 4,
          width: 22, height: 58,
          background: "linear-gradient(180deg, #FFD700 0%, #FF8C00 35%, #FF4D6A 65%, transparent 100%)",
          borderRadius: "0 0 60% 60%",
          filter: "blur(3px)",
          animation: "flame-core 0.14s ease-in-out infinite alternate",
        }}
      />
      <div
        style={{
          position: "absolute", left: "50%", top: 10,
          width: 10, height: 30,
          background: "linear-gradient(180deg, #fff 0%, #FFD700 60%, transparent 100%)",
          borderRadius: "0 0 50% 50%",
          transform: "translateX(-50%)",
          filter: "blur(1px)",
        }}
      />
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            left: `${28 + (i - 1) * 16}%`,
            top: 62,
            width: 18, height: 18,
            borderRadius: "50%",
            background: "rgba(139,127,232,0.18)",
            filter: "blur(5px)",
            animation: "smoke-rise 1.4s ease-out infinite",
            animationDelay: `${i * 0.45}s`,
          }}
        />
      ))}
    </div>
  );
}

/* ─── Speed lines ────────────────────────────────────────────────────────── */
function SpeedLines({ op }: { op: MotionValue<number> }) {
  return (
    <motion.div
      style={{
        position: "absolute", inset: 0,
        opacity: op,
        pointerEvents: "none",
        overflow: "hidden",
      }}
    >
      {Array.from({ length: 28 }, (_, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            left: "50%", top: "50%",
            width: `${55 + (i % 4) * 20}vw`,
            height: "1px",
            background: "linear-gradient(90deg, transparent 0%, rgba(139,127,232,0.55) 50%, transparent 100%)",
            transformOrigin: "0 0",
            transform: `rotate(${i * 12.857}deg)`,
          }}
        />
      ))}
    </motion.div>
  );
}

/* ─── Main component ─────────────────────────────────────────────────────── */
export default function RocketHero() {
  const containerRef = useRef<HTMLDivElement>(null);
  const [email, setEmail]   = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [msg, setMsg]       = useState("");

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  /* Sur mobile, compresse la phase de sortie : 0.70→1.0 mappe vers 0.87→1.0
     Les animations d'entrée (≤0.58) restent identiques sur tous les devices. */
  const isMobileRef = useRef(false);
  useEffect(() => {
    isMobileRef.current = window.innerWidth < 768;
  }, []);
  const p = useTransform(scrollYProgress, (v) => {
    if (!isMobileRef.current || v <= 0.70) return v;
    return 0.87 + (v - 0.70) * ((1 - 0.87) / (1 - 0.70));
  });

  /* ══ Section 1000vh — entrée rapide (0→0.40), CTA dwell 0.38→0.87 (~3000px) ══ */

  /* ── Rocket ── */
  const rocketY   = useTransform(p, [0.02, 0.38], ["0vh", "-95vh"]);
  const rocketX   = useTransform(p, [0.02, 0.11, 0.22, 0.34], [0, -12, 6, 0]);
  const rocketRot = useTransform(p, [0.02, 0.10, 0.22, 0.34], [0, -7, -3, 0]);
  const rocketSc  = useTransform(p, [0, 0.03, 0.38], [1, 1.25, 0.55]);
  const rocketOp  = useTransform(p, [0, 0.36, 0.43], [1, 1, 0]);

  /* ── Flame ── */
  const flameOp   = useTransform(p, [0.03, 0.08, 0.33, 0.41], [0, 1, 0.8, 0]);
  const flameSc   = useTransform(p, [0.03, 0.13, 0.35], [0.3, 1.5, 0.7]);
  const flameY    = useTransform(p, [0.02, 0.38], ["0vh", "-95vh"]);

  /* ── "kolyb" name ── */
  const nameOp    = useTransform(p, [0, 0.06, 0.12], [1, 1, 0]);
  const nameSc    = useTransform(p, [0, 0.06, 0.12], [1, 1, 0.6]);

  /* ── Sky ── */
  const skyP      = useTransform(p, [0, 0.35], [0, 1]);

  /* ── Stars ── */
  const starsOp   = useTransform(p, [0.08, 0.22], [0, 1]);

  /* ── Tagline container ── */
  const tagY      = useTransform(p, [0.23, 0.34, 0.87, 0.93], [36, 0, 0, -28]);
  const tagOp     = useTransform(p, [0.23, 0.34, 0.87, 0.93], [0, 1, 1, 0]);

  /* ── Mots du tagline — 3 mots en décalé ── */
  const w0op   = useTransform(p, [0.25, 0.35], [0, 1]);
  const w0y    = useTransform(p, [0.25, 0.35], [22, 0]);
  const w0blur = useTransform(p, [0.25, 0.35], ["blur(8px)", "blur(0px)"]);

  const w1op   = useTransform(p, [0.29, 0.39], [0, 1]);
  const w1y    = useTransform(p, [0.29, 0.39], [22, 0]);
  const w1blur = useTransform(p, [0.29, 0.39], ["blur(8px)", "blur(0px)"]);

  const w2op   = useTransform(p, [0.33, 0.43], [0, 1]);
  const w2y    = useTransform(p, [0.33, 0.43], [22, 0]);
  const w2blur = useTransform(p, [0.33, 0.43], ["blur(8px)", "blur(0px)"]);

  /* ── Description ── */
  const descOp    = useTransform(p, [0.39, 0.50, 0.87, 0.93], [0, 1, 1, 0]);
  const descY     = useTransform(p, [0.39, 0.50], [30, 0]);

  /* ── Form — visible de 0.46 à 0.87 ── */
  const formOp    = useTransform(p, [0.46, 0.58, 0.87, 0.93], [0, 1, 1, 0]);
  const formY     = useTransform(p, [0.46, 0.58], [24, 0]);

  /* ── Sortie hyperspatiale — bien après le CTA ── */
  const exitSc     = useTransform(p, [0.91, 0.99], [1, 2.5]);
  const exitOp     = useTransform(p, [0.93, 0.99], [1, 0]);
  const exitBlurV  = useTransform(p, [0.92, 0.99], [0, 20]);
  const exitFilter = useTransform(exitBlurV, (v) => `blur(${v}px)`);
  const linesOp    = useTransform(p, [0.89, 0.93, 0.99], [0, 0.95, 0]);
  const flashOp    = useTransform(p, [0.95, 0.97, 0.99], [0, 0.65, 0]);

  /* ── Refs pour mise à jour impérative de l'opacité ── */
  /* framer-motion v11 n'applique pas opacity via MotionValue au DOM,
     contrairement aux transforms — on contourne avec des refs + event */
  const stickyRef   = useRef<HTMLDivElement>(null);
  const nameOpRef   = useRef<HTMLDivElement>(null);
  const tagOpRef    = useRef<HTMLDivElement>(null);
  const w0Ref       = useRef<HTMLSpanElement>(null);
  const w1Ref       = useRef<HTMLSpanElement>(null);
  const w2Ref       = useRef<HTMLSpanElement>(null);
  const descOpRef   = useRef<HTMLDivElement>(null);
  const formOpRef   = useRef<HTMLDivElement>(null);
  const flameOpRef  = useRef<HTMLDivElement>(null);
  const rocketOpRef = useRef<HTMLDivElement>(null);
  const starsOpRef  = useRef<HTMLDivElement>(null);
  const flashOpRef  = useRef<HTMLDivElement>(null);

  /* Toutes les propriétés CSS non-transform (opacity, filter) sont mises à jour
     impérativement — framer-motion v11 ne les flushes pas via MotionValue style */
  useMotionValueEvent(exitOp,   "change", (v) => { if (stickyRef.current)   stickyRef.current.style.opacity   = String(v); });
  useMotionValueEvent(nameOp,   "change", (v) => { if (nameOpRef.current)   nameOpRef.current.style.opacity   = String(v); });
  useMotionValueEvent(tagOp,    "change", (v) => { if (tagOpRef.current)    tagOpRef.current.style.opacity    = String(v); });
  useMotionValueEvent(w0op,     "change", (v) => { if (w0Ref.current)       w0Ref.current.style.opacity       = String(v); });
  useMotionValueEvent(w0blur,   "change", (v) => { if (w0Ref.current)       w0Ref.current.style.filter        = v; });
  useMotionValueEvent(w1op,     "change", (v) => { if (w1Ref.current)       w1Ref.current.style.opacity       = String(v); });
  useMotionValueEvent(w1blur,   "change", (v) => { if (w1Ref.current)       w1Ref.current.style.filter        = v; });
  useMotionValueEvent(w2op,     "change", (v) => { if (w2Ref.current)       w2Ref.current.style.opacity       = String(v); });
  useMotionValueEvent(w2blur,   "change", (v) => { if (w2Ref.current)       w2Ref.current.style.filter        = v; });
  useMotionValueEvent(descOp,   "change", (v) => { if (descOpRef.current)   descOpRef.current.style.opacity   = String(v); });
  useMotionValueEvent(formOp,   "change", (v) => { if (formOpRef.current)   formOpRef.current.style.opacity   = String(v); });
  useMotionValueEvent(flameOp,  "change", (v) => { if (flameOpRef.current)  flameOpRef.current.style.opacity  = String(v); });
  useMotionValueEvent(rocketOp, "change", (v) => { if (rocketOpRef.current) rocketOpRef.current.style.opacity = String(v); });
  useMotionValueEvent(starsOp,  "change", (v) => { if (starsOpRef.current)  starsOpRef.current.style.opacity  = String(v); });
  useMotionValueEvent(flashOp,  "change", (v) => { if (flashOpRef.current)  flashOpRef.current.style.opacity  = String(v); });

  /* ── Form submit ── */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;
    setStatus("loading");
    try {
      const res = await fetch("https://api.freewaitlists.com/waitlists/cmo78oimu08j901png9bqw4xb", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, meta: { source: "rocket-hero" } }),
      });
      if (res.ok || res.status === 409) {
        setStatus("success");
        setMsg(res.status === 409 ? "Tu es déjà inscrit·e ! On te tient au courant 🚀" : "Bienvenue dans l'aventure kolyb ! 🚀");
        setEmail("");
      } else { setStatus("error"); setMsg("Une erreur est survenue. Réessaie."); }
    } catch {
      setStatus("error"); setMsg("Connexion impossible. Réessaie.");
    }
  };

  return (
    /* 1000vh — le CTA a ~3000px de dwell time pour être lu et rempli */
    <section ref={containerRef} style={{ height: "1000dvh", position: "relative" }} id="hero">
      <motion.div
        ref={stickyRef}
        style={{
          position: "sticky", top: 0, height: "100dvh",
          overflow: "hidden",
          scale: exitSc,
          filter: exitFilter,
          transformOrigin: "50% 50%",
          willChange: "transform",
          opacity: 1,
        }}
      >
        <Atmosphere p={skyP} />

        {/* Étoiles */}
        <div
          ref={starsOpRef}
          style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: 0 }}
          aria-hidden="true"
        >
          {STARS.map((s, i) => (
            <div
              key={i}
              className="star-pulse"
              style={{
                position: "absolute",
                left: `${s.x}%`, top: `${s.y}%`,
                width: `${s.r * 2}px`, height: `${s.r * 2}px`,
                borderRadius: "50%", background: "#fff",
                opacity: s.o,
                animationDuration: `${s.dur}s`,
                animationDelay: `${s.del}s`,
              }}
            />
          ))}
        </div>

        <SpeedLines op={linesOp} />

        {/* ── Rocket ── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "38%", zIndex: 4 }}>
          <div ref={rocketOpRef} style={{ opacity: 1 }}>
            <motion.div style={{ y: rocketY, x: rocketX, rotate: rocketRot, scale: rocketSc }}>
              <KolybIcon size={116} variant="violet" animate={true} />
            </motion.div>
          </div>
        </div>

        {/* ── Flame ── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(38% + 116px)", zIndex: 3 }} aria-hidden="true">
          <div ref={flameOpRef} style={{ opacity: 0 }}>
            <motion.div style={{ y: flameY, scale: flameSc }}>
              <Flame />
            </motion.div>
          </div>
        </div>

        {/* ── "kolyb" name — phase initiale ── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(38% + 130px)", zIndex: 5, textAlign: "center" }}>
          <div ref={nameOpRef} style={{ opacity: 1 }}>
            <motion.div style={{ scale: nameSc, transformOrigin: "50% 0" }}>
              <span
                style={{
                  fontSize: "clamp(56px, 13vw, 110px)",
                  fontWeight: 900,
                  letterSpacing: "-0.06em",
                  color: "#EDEDFF",
                  display: "block",
                  whiteSpace: "nowrap",
                }}
              >
                kolyb
              </span>
              <span
                style={{
                  fontSize: 13,
                  fontWeight: 600,
                  letterSpacing: "0.14em",
                  textTransform: "uppercase",
                  color: "rgba(139,127,232,0.5)",
                  display: "block",
                  marginTop: 4,
                }}
              >
                Ton niveau devient visible
              </span>
            </motion.div>
          </div>
        </div>

        {/* ── Tagline — mot par mot, 100% MotionValues, aucun re-render ── */}
        <div
          style={{
            position: "absolute", left: "50%", top: "calc(50% - 180px)",
            transform: "translate(-50%, -50%)",
            textAlign: "center",
            width: "min(700px, 92vw)",
            zIndex: 5,
          }}
        >
          <div ref={tagOpRef} style={{ opacity: 0 }}>
            <motion.div style={{ y: tagY }}>
              <p
                style={{
                  fontSize: "clamp(2.2rem, 7vw, 5.5rem)",
                  fontWeight: 800,
                  letterSpacing: "-0.045em",
                  lineHeight: 1.08,
                  display: "flex",
                  flexWrap: "wrap",
                  justifyContent: "center",
                  gap: "0.3em",
                }}
              >
                {[
                  { ref: w0Ref, wy: w0y, color: "#EDEDFF" },
                  { ref: w1Ref, wy: w1y, color: "#EDEDFF" },
                  {
                    ref: w2Ref, wy: w2y,
                    gradient: {
                      background: "linear-gradient(135deg, #8B7FE8 0%, #C4B5FD 55%, #00D4C8 100%)",
                      WebkitBackgroundClip: "text" as const,
                      WebkitTextFillColor: "transparent" as const,
                      backgroundClip: "text" as const,
                    },
                  },
                ].map(({ ref, wy, color, gradient }, i) => (
                  <motion.span
                    key={TAGLINE[i]}
                    ref={ref}
                    style={{
                      display: "inline-block",
                      opacity: 0,
                      filter: "blur(8px)",
                      y: wy,
                      ...(gradient ?? { color }),
                    }}
                  >
                    {TAGLINE[i]}
                  </motion.span>
                ))}
              </p>
            </motion.div>
          </div>
        </div>

        {/* ── Description ── */}
        <div
          style={{
            position: "absolute", left: "50%",
            transform: "translateX(-50%)",
            top: "calc(50% + clamp(90px, 14vw, 150px) - 180px)",
            width: "min(520px, 90vw)",
            textAlign: "center",
            zIndex: 5,
          }}
        >
          <div ref={descOpRef} style={{ opacity: 0 }}>
            <motion.div style={{ y: descY }}>
              <p style={{ fontSize: 17, color: "rgba(237,237,255,0.58)", lineHeight: 1.78, marginBottom: 15 }}>
                kolyb réunit tout ce dont tu as besoin pour avancer, à ton rythme,{" "}
                <span style={{ color: "#C4B5FD", fontWeight: 600 }}>jamais seul·e.</span>
              </p>
            </motion.div>
          </div>
        </div>

        {/* ── Formulaire + pills + stats ── */}
        <div
          style={{
            position: "absolute", left: "50%",
            transform: "translateX(-50%)",
            top: "calc(50% + clamp(155px, 22vw, 230px) - 180px)",
            width: "min(460px, 92vw)",
            textAlign: "center",
            zIndex: 5,
          }}
        >
          <div ref={formOpRef} style={{ opacity: 0 }}>
          <motion.div style={{ y: formY }}>
            <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 8, marginBottom: 40 }}>
              {["✓ Check-in matin & soir", "✓ Planificateur", "✓ Le Salon"].map((f) => (
                <span
                  key={f}
                  style={{
                    fontSize: 12, fontWeight: 500, color: "#8B7FE8",
                    padding: "5px 12px", borderRadius: 9999,
                    background: "rgba(109,40,217,0.12)",
                    border: "1px solid rgba(109,40,217,0.25)",
                  }}
                >
                  {f}
                </span>
              ))}
            </div>

            {/* App Store button */}
            <motion.a
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary btn-block"
              style={{ fontSize: 15, padding: "14px 28px", display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 10, marginBottom: 8 }}
              whileHover={{ scale: 1.03, boxShadow: "0 12px 48px rgba(109,40,217,0.5)" }}
              whileTap={{ scale: 0.97 }}
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Télécharger sur l&apos;App Store
            </motion.a>

            <p style={{ fontSize: 11, color: "rgba(237,237,255,0.25)", marginBottom: 20 }}>
              Gratuit · Sans CB · RGPD
            </p>

            {/* Android waitlist */}
            <p style={{ fontSize: 12, color: "rgba(237,237,255,0.38)", marginBottom: 8 }}>
              Sur Android ? Sois notifié·e dès le lancement →
            </p>
            {status === "success" ? (
              <p style={{ color: "#00D4C8", fontSize: 13, fontWeight: 600 }}>✓ {msg}</p>
            ) : (
              <form onSubmit={handleSubmit} style={{ display: "flex", gap: 8 }}>
                <input
                  type="email" value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="ton@email.com" required
                  className="input" style={{ flex: 1, fontSize: 13, padding: "10px 14px", textAlign: "left" }}
                />
                <motion.button
                  type="submit" disabled={status === "loading"}
                  className="btn btn-primary"
                  style={{ padding: "10px 14px" }}
                  whileHover={{ scale: 1.04 }} whileTap={{ scale: 0.97 }}
                >
                  {status === "loading" ? (
                    <span style={{ width: 12, height: 12, display: "inline-block", border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} />
                  ) : (
                    <ArrowRight size={14} />
                  )}
                </motion.button>
              </form>
            )}
            {status === "error" && (
              <p style={{ color: "#FF4D6A", fontSize: 12, marginTop: 6 }}>{msg}</p>
            )}

            <div style={{ display: "flex", justifyContent: "center", gap: 28, marginTop: 32 }}>
              {[
                { val: "500+", lbl: "entrepreneurs" },
                { val: "Gratuit", lbl: "pour commencer" },
                { val: "0", lbl: "spam" },
              ].map((s) => (
                <div key={s.lbl} style={{ textAlign: "center" }}>
                  <p style={{ fontSize: 18, fontWeight: 800, color: "#fff", letterSpacing: "-0.02em" }}>{s.val}</p>
                  <p style={{ fontSize: 10, color: "rgba(237,237,255,0.32)", textTransform: "uppercase", letterSpacing: "0.1em" }}>{s.lbl}</p>
                </div>
              ))}
            </div>
          </motion.div>
          </div>
        </div>

        {/* Flash hyperspatial */}
        <div
          ref={flashOpRef}
          aria-hidden="true"
          style={{
            position: "absolute", inset: 0,
            background: "radial-gradient(ellipse 55% 35% at 50% 50%, rgba(255,255,255,0.92) 0%, rgba(139,127,232,0.55) 35%, transparent 72%)",
            opacity: 0,
            pointerEvents: "none",
            zIndex: 20,
          }}
        />
      </motion.div>
    </section>
  );
}
