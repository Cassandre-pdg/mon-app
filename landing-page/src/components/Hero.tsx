"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles, CheckCircle2 } from "lucide-react";
import KolybIcon from "./KolybIcon";

const features = [
  "Check-in matin & soir",
  "Planificateur 3 priorités",
  "Le Salon",
];

export default function Hero() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

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
      id="hero"
      className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden"
      style={{ paddingTop: "120px", paddingBottom: "80px" }}
    >
      {/* Background glows */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[800px] h-[600px] bg-[#6D28D9]/15 rounded-full blur-[120px]" />
        <div className="absolute bottom-0 right-1/4 w-[400px] h-[400px] bg-[#00D4C8]/8 rounded-full blur-[100px]" />
        <div className="absolute top-1/3 left-1/4 w-[300px] h-[300px] bg-[#FF4D6A]/6 rounded-full blur-[80px]" />
      </div>

      {/* Grid pattern */}
      <div
        className="absolute inset-0 pointer-events-none opacity-[0.03]"
        style={{
          backgroundImage: `linear-gradient(#8B7FE8 1px, transparent 1px), linear-gradient(90deg, #8B7FE8 1px, transparent 1px)`,
          backgroundSize: "60px 60px",
        }}
      />

      <div className="wrap-sm relative z-10 text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="flex justify-center mb-8"
        >
          <span className="badge badge-violet">
            <Sparkles size={13} />
            Beta ouverte, places limitées
          </span>
        </motion.div>

        {/* Icon */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="flex justify-center mb-10"
        >
          <KolybIcon size={96} variant="violet" animate={true} />
        </motion.div>

        {/* Headline */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-5xl md:text-7xl font-bold text-white leading-tight mb-8"
          style={{ letterSpacing: "-0.03em" }}
        >
          Ton élan,{" "}
          <span className="gradient-text">au quotidien.</span>
        </motion.h1>

        {/* Subheadline */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="text-lg md:text-l text-[#EDEDFF]/65 leading-relaxed mb-8"
        >
          kolyb réunit tout ce dont tu as besoin pour avancer, à ton rythme,{" "}
          <span className="text-[#C4B5FD] font-medium">jamais seul·e.</span>
        </motion.p>

        {/* Features pills */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="badge-hero flex flex-wrap justify-center gap-2.5 mb-16"
        >
          {features.map((f) => (
            <span
              key={f}
              className="badgess flex items-center gap-2 text-sm text-[#8B7FE8] px-4 py-2 rounded-full font-medium"
              style={{ background: "rgba(109,40,217,0.12)", border: "1px solid rgba(109,40,217,0.25)" }}
            >
              <CheckCircle2 size={13} className="text-[#00D4C8]" />
              {f}
            </span>
          ))}
        </motion.div>

        {/* Email form */}
        <motion.div
          id="hero-form"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.5 }}
        >
          {status === "success" ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="p-8 rounded-2xl bg-[#00D4C8]/10 border border-[#00D4C8]/30 text-center"
            >
              <div className="text-4xl mb-4">🚀</div>
              <p className="text-[#00D4C8] font-semibold text-lg mb-2">{message}</p>
              <p className="text-[#EDEDFF]/55 text-sm">
                On te tient au courant dès l&apos;ouverture de la beta.
              </p>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="newsletter-form flex flex-col sm:flex-row gap-3">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ton@email.com"
                required
                className="input flex-1"
              />
              <button type="submit" disabled={status === "loading"} className="btn btn-primary">
                {status === "loading" ? (
                  <span className="inline-block w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                ) : (
                  <>
                    Rejoindre la beta
                    <ArrowRight size={16} />
                  </>
                )}
              </button>
            </form>
          )}

          {status === "error" && (
            <p className="text-[#FF4D6A] text-sm text-center mt-3">{message}</p>
          )}

          <p className="text-[#EDEDFF]/28 text-xs text-center mt-4">
            Gratuit, sans CB. Tu te désinscrits quand tu veux. RGPD respecté.
          </p>
        </motion.div>

        {/* Social proof */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.8 }}
          className="mt-20 flex flex-col sm:flex-row items-center justify-center gap-12"
        >
          {[
            { value: "500+", label: "entrepreneurs inscrits" },
            { value: "100%", label: "gratuit en V1" },
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
      </div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2 }}
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
