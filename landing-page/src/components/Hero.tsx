"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles, CheckCircle2 } from "lucide-react";
import KolybIcon from "./KolybIcon";

const features = [
  "Check-in matin & soir",
  "Planificateur 3 priorités",
  "Communauté Ma Tribu",
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
      className="relative min-h-screen flex flex-col items-center justify-center px-6 pt-24 pb-16 overflow-hidden"
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

      <div className="relative z-10 max-w-4xl mx-auto text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#6D28D9]/20 border border-[#6D28D9]/40 text-[#C4B5FD] text-sm font-medium mb-8"
        >
          <Sparkles size={14} />
          <span>Beta ouverte — places limitées</span>
        </motion.div>

        {/* Icon */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="flex justify-center mb-10"
        >
          <KolybIcon size={100} variant="violet" animate={true} />
        </motion.div>

        {/* Headline */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight"
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
          className="text-xl md:text-2xl text-[#EDEDFF]/70 mb-4 max-w-2xl mx-auto leading-relaxed"
        >
          kolyb réunit tout ce dont tu as besoin pour avancer — à ton rythme,{" "}
          <span className="text-[#C4B5FD] font-medium">jamais seul·e.</span>
        </motion.p>

        {/* Features pills */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="flex flex-wrap justify-center gap-3 mb-12"
        >
          {features.map((f) => (
            <span
              key={f}
              className="flex items-center gap-1.5 text-sm text-[#8B7FE8] px-3 py-1 rounded-full"
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
          className="max-w-md mx-auto"
        >
          {status === "success" ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="p-6 rounded-2xl bg-[#00D4C8]/10 border border-[#00D4C8]/30 text-center"
            >
              <div className="text-3xl mb-3">🚀</div>
              <p className="text-[#00D4C8] font-semibold text-lg">{message}</p>
              <p className="text-[#EDEDFF]/60 text-sm mt-2">
                On te tient au courant dès l&apos;ouverture de la beta.
              </p>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-3">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ton@email.com"
                required
                className="flex-1 px-5 py-4 rounded-xl bg-[#1A1836] border border-[#22204A] text-white placeholder-[#EDEDFF]/30 text-sm font-medium focus:outline-none focus:border-[#6D28D9] focus:ring-1 focus:ring-[#6D28D9] transition-all"
              />
              <button
                type="submit"
                disabled={status === "loading"}
                className="flex items-center justify-center gap-2 px-6 py-4 bg-[#6D28D9] hover:bg-[#5B21B6] disabled:opacity-60 text-white text-sm font-semibold rounded-xl transition-all duration-200 hover:shadow-xl hover:shadow-purple-900/40 whitespace-nowrap"
              >
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
          <p className="text-[#EDEDFF]/30 text-xs text-center mt-4">
            Gratuit, sans CB. Tu te désinscrits quand tu veux. RGPD respecté.
          </p>
        </motion.div>

        {/* Social proof */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.8 }}
          className="mt-16 flex flex-col sm:flex-row items-center justify-center gap-8 text-center"
        >
          {[
            { value: "500+", label: "entrepreneurs inscrits" },
            { value: "100%", label: "gratuit en V1" },
            { value: "0", label: "spam promis" },
          ].map((stat) => (
            <div key={stat.label} className="flex flex-col gap-1">
              <span className="text-2xl font-bold text-white" style={{ letterSpacing: "-0.02em" }}>
                {stat.value}
              </span>
              <span className="text-xs text-[#EDEDFF]/40 font-medium uppercase tracking-wider">
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
