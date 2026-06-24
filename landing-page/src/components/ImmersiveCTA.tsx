"use client";

import { useRef, useState } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { ArrowRight } from "lucide-react";

const APP_STORE_URL = "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978";

const EASE: [number, number, number, number] = [0.16, 1, 0.3, 1];

export default function ImmersiveCTA() {
  const sectionRef = useRef<HTMLElement>(null);
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

  /* ── Glow curseur ──────────────────────────────────────── */
  const mouseX = useMotionValue(0.5);
  const mouseY = useMotionValue(0.5);
  const smoothX = useSpring(mouseX, { stiffness: 70, damping: 22 });
  const smoothY = useSpring(mouseY, { stiffness: 70, damping: 22 });
  const glowLeft = useTransform(smoothX, [0, 1], ["-10%", "110%"]);
  const glowTop  = useTransform(smoothY, [0, 1], ["-10%", "110%"]);

  const handleMouseMove = (e: React.MouseEvent<HTMLElement>) => {
    const rect = sectionRef.current?.getBoundingClientRect();
    if (!rect) return;
    mouseX.set((e.clientX - rect.left) / rect.width);
    mouseY.set((e.clientY - rect.top) / rect.height);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;
    setStatus("loading");
    try {
      const res = await fetch("https://api.freewaitlists.com/waitlists/cmo78oimu08j901png9bqw4xb", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, meta: { source: "cta" } }),
      });
      if (res.ok || res.status === 409) {
        setStatus("success");
        setMessage(res.status === 409 ? "Tu es déjà inscrit·e ! On te tient au courant 🚀" : "Bienvenue dans l'aventure kolyb ! 🚀");
        setEmail("");
      } else {
        setStatus("error");
        setMessage("Une erreur est survenue. Réessaie dans quelques instants.");
      }
    } catch {
      setStatus("error");
      setMessage("Connexion impossible. Réessaie dans quelques instants.");
    }
  };

  return (
    <section
      ref={sectionRef}
      className="immersive-cta"
      id="waitlist"
      style={{ paddingTop: "clamp(100px, 12vw, 140px)", paddingBottom: "clamp(100px, 12vw, 140px)" }}
      onMouseMove={handleMouseMove}
    >
      {/* Séparateur — diagonal inversé */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute", top: 0, left: 0, right: 0,
          height: 1,
          background: "linear-gradient(90deg, transparent 0%, rgba(255,77,106,0.25) 25%, rgba(109,40,217,0.45) 55%, transparent 100%)",
        }}
      />

      {/* Glow layers fixes */}
      <div className="cta-glow" aria-hidden="true">
        <div className="cta-glow-main" />
        <div className="cta-glow-ring" />

        {/* Orbes flottantes */}
        {[
          { size: 320, top: "10%",  left: "5%",   color: "rgba(109,40,217,0.2)",  delay: "0s",   dur: "9s" },
          { size: 200, top: "60%",  right: "8%",  color: "rgba(0,212,200,0.14)",  delay: "-4s",  dur: "11s" },
          { size: 150, top: "30%",  right: "20%", color: "rgba(255,77,106,0.08)", delay: "-7s",  dur: "8s" },
        ].map((orb, i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              width: orb.size, height: orb.size,
              borderRadius: "50%",
              background: `radial-gradient(circle, ${orb.color} 0%, transparent 70%)`,
              filter: "blur(60px)",
              top: orb.top,
              left: "left" in orb ? orb.left : undefined,
              right: "right" in orb ? orb.right : undefined,
              animation: `float-slow ${orb.dur} ease-in-out infinite`,
              animationDelay: orb.delay,
            }}
          />
        ))}

        {/* Grid */}
        <div
          style={{
            position: "absolute", inset: 0,
            backgroundImage: "linear-gradient(rgba(139,127,232,0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.04) 1px, transparent 1px)",
            backgroundSize: "60px 60px",
            maskImage: "radial-gradient(ellipse 70% 70% at 50% 50%, black 40%, transparent 100%)",
          }}
        />
      </div>

      {/* Glow curseur — suit la souris */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          width: 700, height: 700,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(109,40,217,0.22) 0%, rgba(139,127,232,0.08) 40%, transparent 70%)",
          filter: "blur(80px)",
          pointerEvents: "none",
          left: glowLeft,
          top: glowTop,
          x: "-50%",
          y: "-50%",
          zIndex: 0,
        }}
      />

      {/* Contenu */}
      <div className="wrap-sm" style={{ position: "relative", zIndex: 1, textAlign: "center" }}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-80px" }}
          variants={{
            hidden: {},
            visible: { transition: { staggerChildren: 0.1 } },
          }}
        >
          <motion.div
            variants={{ hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: EASE } } }}
          >
            <span className="badge badge-violet" style={{ marginBottom: 32 }}>
              ✦ Disponible sur iOS · Android bientôt
            </span>
          </motion.div>

          <motion.h2
            variants={{ hidden: { opacity: 0, y: 24 }, visible: { opacity: 1, y: 0, transition: { duration: 0.65, ease: EASE } } }}
            style={{
              fontSize: "clamp(2.5rem, 7vw, 5rem)",
              fontWeight: 800,
              letterSpacing: "-0.04em",
              lineHeight: 1.05,
              color: "#EDEDFF",
              marginBottom: 16,
            }}
          >
            Deviens{" "}
            <span className="gradient-text" style={{ margin: 0, display: "inline" }}>
              ton propre standard.
            </span>
          </motion.h2>

          <motion.p
            variants={{ hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: EASE } } }}
            style={{
              fontSize: 17,
              color: "rgba(237,237,255,0.5)",
              lineHeight: 1.75,
              marginBottom: 40,
              maxWidth: 440,
              margin: "0 auto 40px",
            }}
          >
            Télécharge kolyb et commence ton élan aujourd&apos;hui. Gratuit, sans CB.
          </motion.p>

          <motion.div
            variants={{ hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: EASE } } }}
            style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 24 }}
          >
            {/* App Store button */}
            <motion.a
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary btn-block"
              whileHover={{ scale: 1.03, boxShadow: "0 12px 48px rgba(109,40,217,0.5)" }}
              whileTap={{ scale: 0.97 }}
              style={{ fontSize: 16, padding: "16px 36px", maxWidth: 360, display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 10 }}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Télécharger sur l&apos;App Store
            </motion.a>

            <p style={{ color: "rgba(237,237,255,0.25)", fontSize: 12 }}>Gratuit · Sans CB · RGPD</p>

            {/* Android waitlist */}
            <div style={{ width: "100%", maxWidth: 360 }}>
              <p style={{ color: "rgba(237,237,255,0.38)", fontSize: 13, textAlign: "center", marginBottom: 10 }}>
                Sur Android ? Sois notifié·e dès le lancement →
              </p>
              {status === "success" ? (
                <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} style={{ color: "#00D4C8", fontSize: 13, textAlign: "center", fontWeight: 600 }}>
                  ✓ {message}
                </motion.p>
              ) : (
                <form onSubmit={handleSubmit} style={{ display: "flex", gap: 8 }}>
                  <input
                    type="email" value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="ton@email.com" required
                    className="input"
                    style={{ flex: 1, fontSize: 13, padding: "10px 14px", textAlign: "left" }}
                  />
                  <motion.button
                    type="submit"
                    disabled={status === "loading"}
                    className="btn btn-primary"
                    whileHover={{ scale: 1.04 }}
                    whileTap={{ scale: 0.97 }}
                    style={{ fontSize: 13, padding: "10px 16px" }}
                  >
                    {status === "loading" ? (
                      <span style={{ display: "inline-block", width: 12, height: 12, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} />
                    ) : (
                      <ArrowRight size={14} />
                    )}
                  </motion.button>
                </form>
              )}
              {status === "error" && (
                <p style={{ color: "#FF4D6A", fontSize: 12, textAlign: "center", marginTop: 8 }}>{message}</p>
              )}
            </div>
          </motion.div>

          {/* Trust badges */}
          <motion.div
            variants={{ hidden: { opacity: 0 }, visible: { opacity: 1, transition: { delay: 0.4 } } }}
            style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 12, marginTop: 48 }}
          >
            {["🇪🇺 Données en EU", "🔒 RGPD", "✨ Gratuit en beta", "💌 0 spam"].map((t) => (
              <motion.span
                key={t}
                whileHover={{ scale: 1.06, borderColor: "rgba(109,40,217,0.35)" }}
                style={{
                  fontSize: 12,
                  color: "rgba(237,237,255,0.35)",
                  padding: "5px 12px",
                  borderRadius: 9999,
                  background: "rgba(139,127,232,0.07)",
                  border: "1px solid rgba(139,127,232,0.12)",
                  cursor: "default",
                  transition: "border-color 0.2s ease",
                }}
              >
                {t}
              </motion.span>
            ))}
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
