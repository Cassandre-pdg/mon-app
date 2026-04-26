"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";

const EASE = [0.16, 1, 0.3, 1] as const;

export default function ImmersiveCTA() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

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
    <section className="immersive-cta" id="waitlist">
      {/* Glow layers */}
      <div className="cta-glow" aria-hidden="true">
        <div className="cta-glow-main" />
        <div className="cta-glow-ring" />

        {/* Floating orbs */}
        {[
          { size: 320, top: "10%",  left: "5%",   color: "rgba(109,40,217,0.2)",  delay: "0s",   dur: "9s" },
          { size: 200, top: "60%",  right: "8%",  color: "rgba(0,212,200,0.14)",  delay: "-4s",  dur: "11s" },
          { size: 150, top: "30%",  right: "20%", color: "rgba(255,77,106,0.08)", delay: "-7s",  dur: "8s" },
        ].map((orb, i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              width: orb.size,
              height: orb.size,
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
            position: "absolute",
            inset: 0,
            backgroundImage:
              "linear-gradient(rgba(139,127,232,0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(139,127,232,0.04) 1px, transparent 1px)",
            backgroundSize: "60px 60px",
            maskImage:
              "radial-gradient(ellipse 70% 70% at 50% 50%, black 40%, transparent 100%)",
          }}
        />
      </div>

      {/* Content */}
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
              ✦ Beta ouverte · Places limitées
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
            Rejoins les premiers indépendants qui avancent avec kolyb. Ta progression commence maintenant.
          </motion.p>

          <motion.div
            variants={{ hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: EASE } } }}
          >
            {status === "success" ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                style={{
                  padding: "32px",
                  borderRadius: 20,
                  background: "rgba(0,212,200,0.08)",
                  border: "1px solid rgba(0,212,200,0.25)",
                  textAlign: "center",
                }}
              >
                <div style={{ fontSize: 40, marginBottom: 12 }}>🚀</div>
                <p style={{ color: "#00D4C8", fontWeight: 700, fontSize: 18, marginBottom: 8 }}>
                  {message}
                </p>
                <p style={{ color: "rgba(237,237,255,0.45)", fontSize: 14 }}>
                  On te tient au courant dès l&apos;ouverture de la beta.
                </p>
              </motion.div>
            ) : (
              <>
                <form
                  onSubmit={handleSubmit}
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    gap: 12,
                    maxWidth: 440,
                    margin: "0 auto",
                  }}
                >
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="ton@email.com"
                    required
                    className="input"
                    style={{ textAlign: "center", fontSize: 15 }}
                  />
                  <motion.button
                    type="submit"
                    disabled={status === "loading"}
                    className="btn btn-primary btn-block"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    style={{ fontSize: 15, padding: "16px 32px" }}
                  >
                    {status === "loading" ? (
                      <span
                        style={{
                          display: "inline-block",
                          width: 16,
                          height: 16,
                          border: "2px solid rgba(255,255,255,0.3)",
                          borderTopColor: "#fff",
                          borderRadius: "50%",
                          animation: "spin 0.7s linear infinite",
                        }}
                      />
                    ) : (
                      <>
                        Commencer maintenant
                        <ArrowRight size={16} />
                      </>
                    )}
                  </motion.button>
                </form>

                {status === "error" && (
                  <p style={{ color: "#FF4D6A", fontSize: 13, textAlign: "center", marginTop: 12 }}>
                    {message}
                  </p>
                )}

                <p style={{ color: "rgba(237,237,255,0.25)", fontSize: 12, marginTop: 16, textAlign: "center" }}>
                  Gratuit · Sans CB · RGPD · Tu te désinscrits quand tu veux
                </p>
              </>
            )}
          </motion.div>

          {/* Trust badges */}
          <motion.div
            variants={{ hidden: { opacity: 0 }, visible: { opacity: 1, transition: { delay: 0.4 } } }}
            style={{
              display: "flex",
              flexWrap: "wrap",
              justifyContent: "center",
              gap: 12,
              marginTop: 48,
            }}
          >
            {[
              "🇪🇺 Données en EU",
              "🔒 RGPD",
              "✨ Gratuit en beta",
              "💌 0 spam",
            ].map((t) => (
              <span
                key={t}
                style={{
                  fontSize: 12,
                  color: "rgba(237,237,255,0.35)",
                  padding: "5px 12px",
                  borderRadius: 9999,
                  background: "rgba(139,127,232,0.07)",
                  border: "1px solid rgba(139,127,232,0.12)",
                }}
              >
                {t}
              </span>
            ))}
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
