"use client";

import { useRef, useState } from "react";
import {
  motion,
  useScroll,
  useTransform,
  useMotionValueEvent,
  type MotionValue,
} from "framer-motion";
import { ArrowRight } from "lucide-react";
import KolybIcon from "./KolybIcon";

/* ─── Deterministic stars — no Math.random() → no hydration mismatch ──── */
const STARS = Array.from({ length: 130 }, (_, i) => ({
  x: (i * 137.508 + 23.7) % 100,
  y: (i * 97.312 + 13.1) % 100,
  r: 0.5 + (i % 4) * 0.35,
  o: 0.15 + (i % 6) * 0.1,
  dur: 2 + (i % 5) * 0.6,
  del: (i * 0.23) % 3,
}));

const TAGLINE = ["Décide.", "Agis.,", "Progresse."];
const EASE: [number, number, number, number] = [0.16, 1, 0.3, 1];

/* ─── Atmosphere background ─────────────────────────────────────────────── */
function Atmosphere({ p }: { p: MotionValue<number> }) {
  const gridOp  = useTransform(p, [0, 0.35], [1, 0]);
  const spaceOp = useTransform(p, [0.15, 0.55], [0, 1]);
  const glowOp  = useTransform(p, [0, 0.6, 1], [1, 0.4, 0]);

  return (
    <div style={{ position: "absolute", inset: 0 }}>
      {/* Base */}
      <div style={{ position: "absolute", inset: 0, background: "#0D0B1E" }} />

      {/* Launch glow from below */}
      <motion.div
        style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(ellipse 70% 50% at 50% 100%, rgba(109,40,217,0.45) 0%, transparent 70%)",
          opacity: glowOp,
        }}
      />

      {/* Grid fades out as we enter space */}
      <motion.div
        style={{
          position: "absolute", inset: 0,
          backgroundImage:
            "linear-gradient(rgba(139,127,232,0.045) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.045) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
          opacity: gridOp,
        }}
      />

      {/* Deep space overlay */}
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

/* ─── Flame + smoke ──────────────────────────────────────────────────────── */
function Flame() {
  return (
    <div style={{ position: "relative", width: 70, height: 90, pointerEvents: "none" }}>
      {/* Outer diffuse glow */}
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
      {/* Core flame */}
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
      {/* Hot center */}
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
      {/* Smoke puffs */}
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

/* ─── Speed lines (warp exit) ────────────────────────────────────────────── */
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
  const [revealCount, setRevealCount] = useState(0);
  const [email, setEmail]   = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [msg, setMsg]       = useState("");

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  /* ── Word-by-word reveal trigger ── */
  useMotionValueEvent(scrollYProgress, "change", (v) => {
    setRevealCount(
      Math.max(0, Math.min(Math.floor((v - 0.20) / 0.055) + 1, TAGLINE.length))
    );
  });

  /* ── Rocket ── */
  const rocketY   = useTransform(scrollYProgress, [0.05, 0.62], ["0vh", "-95vh"]);
  const rocketX   = useTransform(scrollYProgress, [0.05, 0.2, 0.35, 0.55], [0, -12, 6, 0]);
  const rocketRot = useTransform(scrollYProgress, [0.05, 0.18, 0.38, 0.55], [0, -7, -3, 0]);
  const rocketSc  = useTransform(scrollYProgress, [0, 0.06, 0.62], [1, 1.25, 0.55]);
  const rocketOp  = useTransform(scrollYProgress, [0, 0.60, 0.70], [1, 1, 0]);

  /* ── Flame ── */
  const flameOp   = useTransform(scrollYProgress, [0.06, 0.14, 0.58, 0.68], [0, 1, 0.8, 0]);
  const flameSc   = useTransform(scrollYProgress, [0.06, 0.22, 0.58], [0.3, 1.5, 0.7]);
  const flameY    = useTransform(scrollYProgress, [0.05, 0.62], ["0vh", "-95vh"]);

  /* ── "kolyb" name (initial phase only) ── */
  const nameOp    = useTransform(scrollYProgress, [0, 0.14, 0.24], [1, 1, 0]);
  const nameSc    = useTransform(scrollYProgress, [0, 0.14, 0.24], [1, 1, 0.6]);

  /* ── Sky ── */
  const skyP      = useTransform(scrollYProgress, [0, 0.55], [0, 1]);

  /* ── Stars ── */
  const starsOp   = useTransform(scrollYProgress, [0.16, 0.42], [0, 1]);

  /* ── Tagline ── */
  const tagY      = useTransform(scrollYProgress, [0.18, 0.32, 0.70, 0.80], [36, 0, 0, -28]);
  const tagOp     = useTransform(scrollYProgress, [0.18, 0.26, 0.70, 0.80], [0, 1, 1, 0]);

  /* ── Description ── */
  const descOp    = useTransform(scrollYProgress, [0.44, 0.58, 0.72, 0.81], [0, 1, 1, 0]);
  const descY     = useTransform(scrollYProgress, [0.44, 0.58], [30, 0]);

  /* ── Form + badges ── */
  const formOp    = useTransform(scrollYProgress, [0.54, 0.66, 0.72, 0.81], [0, 1, 1, 0]);
  const formY     = useTransform(scrollYProgress, [0.54, 0.66], [24, 0]);

  /* ── Exit — hyperspace jump ── */
  const exitSc     = useTransform(scrollYProgress, [0.78, 0.97], [1, 2.5]);
  const exitOp     = useTransform(scrollYProgress, [0.83, 0.97], [1, 0]);
  const exitBlurV  = useTransform(scrollYProgress, [0.82, 0.97], [0, 20]);
  const exitFilter = useTransform(exitBlurV, (v) => `blur(${v}px)`);
  const linesOp    = useTransform(scrollYProgress, [0.77, 0.84, 0.97], [0, 0.95, 0]);
  const flashOp    = useTransform(scrollYProgress, [0.89, 0.93, 0.97], [0, 0.65, 0]);

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
    <section ref={containerRef} style={{ height: "430vh" }} id="hero">
      {/* ══ Sticky scene ══════════════════════════════════════════════ */}
      <motion.div
        style={{
          position: "sticky", top: 0, height: "100vh",
          overflow: "hidden",
          scale: exitSc, opacity: exitOp,
          filter: exitFilter,
          transformOrigin: "50% 50%",
        }}
      >
        {/* Background layers */}
        <Atmosphere p={skyP} />

        {/* Stars */}
        <motion.div
          style={{ position: "absolute", inset: 0, pointerEvents: "none", opacity: starsOp }}
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
        </motion.div>

        {/* Speed lines — warp jump */}
        <SpeedLines op={linesOp} />

        {/* ── Rocket ─────────────────────────────────────────────── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "38%", zIndex: 4 }}>
          <motion.div style={{ y: rocketY, x: rocketX, rotate: rocketRot, scale: rocketSc, opacity: rocketOp }}>
            <KolybIcon size={116} variant="violet" animate={true} />
          </motion.div>
        </div>

        {/* ── Flame (below rocket, moves with it) ─────────────────── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(38% + 116px)", zIndex: 3 }} aria-hidden="true">
          <motion.div style={{ y: flameY, opacity: flameOp, scale: flameSc }}>
            <Flame />
          </motion.div>
        </div>

        {/* ── "kolyb" name (initial reveal, fades before launch) ───── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(38% + 130px)", zIndex: 5, textAlign: "center" }}>
          <motion.div style={{ opacity: nameOp, scale: nameSc }}>
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

        {/* ── Tagline — word by word ───────────────────────────────── */}
        <div style={{ position: "absolute", left: "50%", top: "50%", transform: "translate(-50%, -50%)", textAlign: "center", width: "min(700px, 92vw)", zIndex: 5 }}>
          <motion.div style={{ y: tagY, opacity: tagOp }}>
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
              {TAGLINE.map((word, i) => (
                <motion.span
                  key={word}
                  initial={{ opacity: 0, y: 22, filter: "blur(6px)" }}
                  animate={
                    revealCount > i
                      ? { opacity: 1, y: 0, filter: "blur(0px)" }
                      : { opacity: 0, y: 22, filter: "blur(6px)" }
                  }
                  transition={{ duration: 0.5, ease: EASE }}
                  style={{
                    display: "inline-block",
                    ...(i === TAGLINE.length - 1
                      ? {
                          background: "linear-gradient(135deg, #8B7FE8 0%, #C4B5FD 55%, #00D4C8 100%)",
                          WebkitBackgroundClip: "text",
                          WebkitTextFillColor: "transparent",
                          backgroundClip: "text",
                        }
                      : { color: "#EDEDFF" }),
                  }}
                >
                  {word}
                </motion.span>
              ))}
            </p>
          </motion.div>
        </div>

        {/* ── Description ─────────────────────────────────────────── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(50% + clamp(90px, 14vw, 150px))", width: "min(520px, 90vw)", textAlign: "center", zIndex: 5 }}>
          <motion.div style={{ opacity: descOp, y: descY }}>
            <p style={{ fontSize: 17, color: "rgba(237,237,255,0.58)", lineHeight: 1.78 }}>
              kolyb réunit tout ce dont tu as besoin pour avancer, à ton rythme,{" "}
              <span style={{ color: "#C4B5FD", fontWeight: 600 }}>jamais seul·e.</span>
            </p>
          </motion.div>
        </div>

        {/* ── Feature pills + form + stats ────────────────────────── */}
        <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: "calc(50% + clamp(155px, 22vw, 230px))", width: "min(460px, 92vw)", textAlign: "center", zIndex: 5 }}>
          <motion.div style={{ opacity: formOp, y: formY }}>
          {/* Pills */}
          <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 8, marginBottom: 20 }}>
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

          {/* Form / success */}
          {status === "success" ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              style={{
                padding: "20px 24px", borderRadius: 18,
                background: "rgba(0,212,200,0.08)",
                border: "1px solid rgba(0,212,200,0.25)",
              }}
            >
              <p style={{ fontSize: 28, marginBottom: 6 }}>🚀</p>
              <p style={{ color: "#00D4C8", fontWeight: 700, fontSize: 15 }}>{msg}</p>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              <input
                type="email" value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ton@email.com" required
                className="input" style={{ textAlign: "center" }}
              />
              <motion.button
                type="submit" disabled={status === "loading"}
                className="btn btn-primary btn-block"
                style={{ fontSize: 15 }}
                whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.97 }}
              >
                {status === "loading" ? (
                  <span style={{
                    width: 16, height: 16, display: "inline-block",
                    border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff",
                    borderRadius: "50%", animation: "spin 0.7s linear infinite",
                  }} />
                ) : (
                  <> Rejoindre la beta <ArrowRight size={16} /> </>
                )}
              </motion.button>
            </form>
          )}

          {status === "error" && (
            <p style={{ color: "#FF4D6A", fontSize: 13, marginTop: 8 }}>{msg}</p>
          )}

          {/* Stats */}
          <div style={{ display: "flex", justifyContent: "center", gap: 28, marginTop: 22 }}>
            {[
              { val: "500+", lbl: "entrepreneurs" },
              { val: "100%", lbl: "gratuit" },
              { val: "0",    lbl: "spam" },
            ].map((s) => (
              <div key={s.lbl} style={{ textAlign: "center" }}>
                <p style={{ fontSize: 20, fontWeight: 800, color: "#fff", letterSpacing: "-0.02em" }}>{s.val}</p>
                <p style={{ fontSize: 10, color: "rgba(237,237,255,0.32)", textTransform: "uppercase", letterSpacing: "0.1em" }}>{s.lbl}</p>
              </div>
            ))}
          </div>
          <p style={{ fontSize: 11, color: "rgba(237,237,255,0.22)", marginTop: 12 }}>
            Gratuit · Sans CB · RGPD · Tu te désinscrits quand tu veux
          </p>
          </motion.div>
        </div>

        {/* Hyperspace flash */}
        <motion.div
          aria-hidden="true"
          style={{
            position: "absolute", inset: 0,
            background: "radial-gradient(ellipse 55% 35% at 50% 50%, rgba(255,255,255,0.92) 0%, rgba(139,127,232,0.55) 35%, transparent 72%)",
            opacity: flashOp,
            pointerEvents: "none",
            zIndex: 20,
          }}
        />

      </motion.div>
    </section>
  );
}
