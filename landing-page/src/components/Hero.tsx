"use client";

import { useState, useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { ArrowRight, Sparkles, CheckCircle2 } from "lucide-react";
import KolybIcon from "./KolybIcon";

const APP_STORE_URL = "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978";

const features = [
  "Check-in matin & soir",
  "Planificateur 3 priorités",
  "Le Salon",
];

const particles = Array.from({ length: 18 }, (_, i) => ({
  id: i,
  x: Math.random() * 100,
  y: Math.random() * 100,
  size: 2 + Math.random() * 3,
  duration: 4 + Math.random() * 6,
  delay: Math.random() * 4,
  opacity: 0.15 + Math.random() * 0.3,
}));

const EASE_OUT = [0.22, 1, 0.36, 1] as [number, number, number, number];

const containerVariants = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.12, delayChildren: 0.1 } },
};

const itemVariants = {
  hidden: { opacity: 0, y: 28 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.65, ease: EASE_OUT } },
};

export default function Hero() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

  const sectionRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({ target: sectionRef, offset: ["start start", "end start"] });

  const bgY = useTransform(scrollYProgress, [0, 1], ["0%", "30%"]);
  const glowY = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);
  const contentY = useTransform(scrollYProgress, [0, 1], ["0%", "20%"]);
  const opacity = useTransform(scrollYProgress, [0, 0.6], [1, 0]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;
    setStatus("loading");
    try {
      const res = await fetch("/api/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, source: "hero" }),
      });
      const data = await res.json();
      if (res.ok) {
        setStatus("success");
        setMessage(data.message);
        setEmail("");
      } else {
        setStatus("error");
        setMessage(data.error || "Une erreur est survenue.");
      }
    } catch {
      setStatus("error");
      setMessage("Connexion impossible. Réessaie dans quelques instants.");
    }
  };

  return (
    <section
      ref={sectionRef}
      id="hero"
      className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden"
      style={{ paddingTop: "120px", paddingBottom: "80px" }}
    >
      {/* Parallax background glows */}
      <motion.div
        style={{ y: glowY }}
        className="absolute inset-0 overflow-hidden pointer-events-none"
      >
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[900px] h-[700px] bg-[#6D28D9]/18 rounded-full blur-[140px]" />
        <div className="absolute bottom-0 right-1/4 w-[450px] h-[450px] bg-[#00D4C8]/10 rounded-full blur-[110px]" />
        <div className="absolute top-1/3 left-1/4 w-[320px] h-[320px] bg-[#FF4D6A]/7 rounded-full blur-[90px]" />
      </motion.div>

      {/* Grid pattern (parallax) */}
      <motion.div
        style={{
          y: bgY,
          backgroundImage:
            "linear-gradient(#8B7FE8 1px, transparent 1px), linear-gradient(90deg, #8B7FE8 1px, transparent 1px)",
          backgroundSize: "60px 60px",
        }}
        className="absolute inset-0 pointer-events-none opacity-[0.035]"
        aria-hidden="true"
      />

      {/* Floating particles */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none" aria-hidden="true">
        {particles.map((p) => (
          <motion.div
            key={p.id}
            animate={{ y: [0, -20, 0], opacity: [p.opacity, p.opacity * 1.6, p.opacity] }}
            transition={{ duration: p.duration, delay: p.delay, repeat: Infinity, ease: "easeInOut" }}
            style={{
              position: "absolute",
              left: `${p.x}%`,
              top: `${p.y}%`,
              width: p.size,
              height: p.size,
              borderRadius: "50%",
              background: p.id % 3 === 0 ? "#8B7FE8" : p.id % 3 === 1 ? "#00D4C8" : "#C4B5FD",
            }}
          />
        ))}
      </div>

      {/* Content */}
      <motion.div
        style={{ y: contentY, opacity }}
        className="wrap-sm relative z-10 text-center"
      >
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          {/* Badge */}
          <motion.div variants={itemVariants} className="flex justify-center mb-8">
            <span className="badge badge-violet">
              <Sparkles size={13} />
              Disponible sur iOS · Android bientôt
            </span>
          </motion.div>

          {/* Icon */}
          <motion.div
            variants={itemVariants}
            className="flex justify-center mb-10"
          >
            <motion.div
              animate={{ rotate: [0, 4, -4, 0] }}
              transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
            >
              <KolybIcon size={96} variant="violet" animate={true} />
            </motion.div>
          </motion.div>

          {/* Headline */}
          <motion.h1
            variants={itemVariants}
            className="text-5xl md:text-7xl font-bold text-white leading-tight mb-8"
            style={{ letterSpacing: "-0.03em" }}
          >
            Ton niveau{" "}
            <span className="gradient-text">devient visible.</span>
          </motion.h1>

          {/* Subheadline */}
          <motion.p
            variants={itemVariants}
            className="text-lg md:text-xl text-[#EDEDFF]/65 leading-relaxed mb-8"
          >
            kolyb réunit tout ce dont tu as besoin pour avancer, à ton rythme,{" "}
            <span className="text-[#C4B5FD] font-medium">jamais seul·e.</span>
          </motion.p>

          {/* Feature pills */}
          <motion.div
            variants={itemVariants}
            className="flex flex-wrap justify-center gap-2.5 mb-16"
          >
            {features.map((f, i) => (
              <motion.span
                key={f}
                initial={{ opacity: 0, scale: 0.85 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.7 + i * 0.1, duration: 0.4 }}
                className="flex items-center gap-2 text-sm text-[#8B7FE8] px-4 py-2 rounded-full font-medium"
                style={{ background: "rgba(109,40,217,0.12)", border: "1px solid rgba(109,40,217,0.25)" }}
              >
                <CheckCircle2 size={13} className="text-[#00D4C8]" />
                {f}
              </motion.span>
            ))}
          </motion.div>

          {/* CTA */}
          <motion.div variants={itemVariants} className="flex flex-col items-center gap-6">
            {/* App Store button */}
            <motion.a
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.04, boxShadow: "0 16px 56px rgba(109,40,217,0.5)" }}
              whileTap={{ scale: 0.97 }}
              className="btn btn-primary"
              style={{ fontSize: 16, padding: "16px 36px", display: "inline-flex", alignItems: "center", gap: 10 }}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Télécharger sur l&apos;App Store
            </motion.a>

            <p className="text-[#EDEDFF]/28 text-xs">Gratuit · Sans CB · RGPD</p>

            {/* Android waitlist */}
            <div className="w-full max-w-sm">
              <p className="text-[#EDEDFF]/40 text-sm text-center mb-3">
                Sur Android ? Sois notifié·e dès le lancement →
              </p>
              {status === "success" ? (
                <motion.p
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-[#00D4C8] text-sm text-center font-medium"
                >
                  ✓ {message}
                </motion.p>
              ) : (
                <form onSubmit={handleSubmit} className="flex gap-2">
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="ton@email.com"
                    required
                    className="input flex-1"
                    style={{ fontSize: 13, padding: "10px 14px" }}
                  />
                  <button type="submit" disabled={status === "loading"} className="btn btn-primary" style={{ padding: "10px 16px", fontSize: 13 }}>
                    {status === "loading" ? (
                      <span className="inline-block w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                      <ArrowRight size={14} />
                    )}
                  </button>
                </form>
              )}
              {status === "error" && (
                <p className="text-[#FF4D6A] text-xs text-center mt-2">{message}</p>
              )}
            </div>
          </motion.div>

          {/* Stats */}
          <motion.div
            variants={itemVariants}
            className="mt-20 flex flex-col sm:flex-row items-center justify-center gap-12"
          >
            {[
              { value: "500+", label: "entrepreneurs inscrits" },
              { value: "Gratuit", label: "pour commencer" },
              { value: "0", label: "spam promis" },
            ].map((stat) => (
              <div key={stat.label} className="flex flex-col items-center gap-1.5">
                <span className="text-2xl font-bold text-white" style={{ letterSpacing: "-0.02em" }}>
                  {stat.value}
                </span>
                <span className="text-xs text-[#EDEDFF]/38 font-medium uppercase tracking-widest">
                  {stat.label}
                </span>
              </div>
            ))}
          </motion.div>
        </motion.div>
      </motion.div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.4 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
          className="w-5 h-8 rounded-full border border-[#22204A] flex items-start justify-center p-1"
        >
          <div className="w-1 h-2 bg-[#6D28D9] rounded-full" />
        </motion.div>
      </motion.div>
    </section>
  );
}
