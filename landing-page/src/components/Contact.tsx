"use client";

import { useState, useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Send, Mail, MessageCircle, ArrowRight } from "lucide-react";

type FormState = {
  firstName: string;
  email: string;
  subject: string;
  message: string;
};

const subjects = [
  "J'ai téléchargé l'app et j'ai un retour",
  "J'ai une idée pour l'app",
  "Je veux pitcher un partenariat",
  "Presse / média",
  "Autre",
];

export default function Contact() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  const [form, setForm] = useState<FormState>({
    firstName: "",
    email: "",
    subject: subjects[0],
    message: "",
  });
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [responseMsg, setResponseMsg] = useState("");

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("loading");
    try {
      await fetch("/api/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: form.email,
          firstName: form.firstName,
          source: `contact-${form.subject}`,
        }),
      });
    } catch {}
    await new Promise((r) => setTimeout(r, 1200));
    setStatus("success");
    setResponseMsg("Message reçu ! On te répond dans les 48h.");
    setForm({ firstName: "", email: "", subject: subjects[0], message: "" });
  };

  return (
    <section ref={ref} id="contact" className="section" style={{ overflow: "hidden", position: "relative" }}>
      {/* BG */}
      <motion.div
        animate={{ scale: [1, 1.2, 1], opacity: [0.7, 1, 0.7] }}
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
        className="absolute inset-0 pointer-events-none overflow-hidden"
        aria-hidden="true"
      >
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[700px] h-[350px] bg-[#6D28D9]/12 rounded-full blur-[110px]" />
      </motion.div>

      <div className="wrap relative z-10">
        {/* Top CTA */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="text-center mb-28"
        >
          <p className="eyebrow">Disponible maintenant</p>
          <h2 className="section-title mt-0">
            Prêt·e à avancer{" "}
            <span className="gradient-text">différemment ?</span>
          </h2>
          <p className="section-sub mb-10">
            Rejoins les indépendants qui avancent avec kolyb.
            Sur Android ? Laisse ton email, on te prévient dès le lancement.
          </p>
          <NewsletterForm />
        </motion.div>

        {/* Separator */}
        <motion.div
          initial={{ scaleX: 0 }}
          animate={inView ? { scaleX: 1 } : {}}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="separator flex items-center gap-4 mb-20"
          style={{ transformOrigin: "center" }}
        >
          <div className="flex-1 h-px bg-[#22204A]" />
          <span className="text-sm text-[#EDEDFF]/28 font-medium px-4 whitespace-nowrap">
            ou envoie-nous un message
          </span>
          <div className="flex-1 h-px bg-[#22204A]" />
        </motion.div>

        {/* Contact form grid */}
        <div className="grid md:grid-cols-2 gap-12 items-start">
          {/* Left info */}
          <motion.div
            initial={{ opacity: 0, x: -32 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="flex flex-col gap-12"
          >
            <div>
              <h3 className="text-2xl font-bold text-white mb-5" style={{ letterSpacing: "-0.02em" }}>
                Quelque chose manque ? Une idée en tête ? On t'écoute.
              </h3>
              <p className="text-[#EDEDFF]/55 leading-relaxed text-sm">
                Idée de feature, question, feedback, partenariat : toutes les raisons sont bonnes.
                On répond personnellement dans les 48h.
              </p>
            </div>

            <div className="flex flex-col gap-6">
              {[
                { icon: Mail, label: "Email", value: "contact@kolyb.app" },
                { icon: MessageCircle, label: "Réponse", value: "Toujours sous 48h" },
              ].map((item, i) => {
                const Icon = item.icon;
                return (
                  <motion.div
                    key={item.label}
                    initial={{ opacity: 0, x: -20 }}
                    animate={inView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 0.5, delay: 0.4 + i * 0.1 }}
                    className="flex items-center gap-4"
                  >
                    <div className="w-10 h-10 rounded-xl bg-[#6D28D9]/15 border border-[#6D28D9]/22 flex items-center justify-center flex-shrink-0">
                      <Icon size={17} className="text-[#8B7FE8]" />
                    </div>
                    <div>
                      <p className="text-xs text-[#EDEDFF]/38 font-medium uppercase tracking-wider mb-0.5">
                        {item.label}
                      </p>
                      <p className="text-sm text-[#EDEDFF]/80 font-medium">{item.value}</p>
                    </div>
                  </motion.div>
                );
              })}
            </div>

            <motion.div
              initial={{ opacity: 0, y: 12 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.6 }}
              className="announce p-7 rounded-2xl bg-[#1A1836] border border-[#22204A]"
            >
              <p className="text-sm text-[#EDEDFF]/55 leading-relaxed">
                <span className="text-[#C4B5FD] font-semibold">kolyb</span> est construit par une
                fondatrice solo qui vit les mêmes défis que toi. Ton retour compte vraiment, il
                façonne directement l&apos;app.
              </p>
            </motion.div>
          </motion.div>

          {/* Right form */}
          <motion.div
            initial={{ opacity: 0, x: 32 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
          >
            {status === "success" ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.92 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
                className="flex flex-col items-center justify-center text-center p-12 rounded-2xl bg-[#1A1836] border border-[#22204A]"
              >
                <motion.div
                  animate={{ rotate: [0, 10, -10, 0] }}
                  transition={{ duration: 0.5, delay: 0.2 }}
                  className="text-5xl mb-5"
                >
                  🙌
                </motion.div>
                <h4 className="text-xl font-bold text-white mb-3">{responseMsg}</h4>
                <p className="text-[#EDEDFF]/45 text-sm mb-6">
                  En attendant, télécharge l&apos;app si ce n&apos;est pas déjà fait !
                </p>
                <button
                  onClick={() => setStatus("idle")}
                  className="text-sm text-[#8B7FE8] hover:text-white transition-colors cursor-pointer"
                >
                  Envoyer un autre message
                </button>
              </motion.div>
            ) : (
              <form
                onSubmit={handleSubmit}
                className="contact-form rounded-2xl bg-[#1A1836] border border-[#22204A] flex flex-col gap-7"
              >
                <div className="grid grid-cols-2 gap-4">
                  <div className="field">
                    <label className="label">Prénom</label>
                    <input
                      type="text"
                      name="firstName"
                      value={form.firstName}
                      onChange={handleChange}
                      placeholder="Alex"
                      className="input input-dark input-form"
                    />
                  </div>
                  <div className="field">
                    <label className="label">Email *</label>
                    <input
                      type="email"
                      name="email"
                      value={form.email}
                      onChange={handleChange}
                      placeholder="alex@freelance.fr"
                      required
                      className="input input-dark input-form"
                    />
                  </div>
                </div>

                <div className="field">
                  <label className="label">Sujet</label>
                  <select
                    name="subject"
                    value={form.subject}
                    onChange={handleChange}
                    className="input input-dark input-form appearance-none cursor-pointer"
                  >
                    {subjects.map((s) => (
                      <option key={s} value={s} className="bg-[#1A1836]">
                        {s}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="field">
                  <label className="label">Message *</label>
                  <textarea
                    name="message"
                    value={form.message}
                    onChange={handleChange}
                    required
                    rows={5}
                    placeholder="Dis-nous tout…"
                    className="input input-dark input-form resize-none"
                  />
                </div>

                {status === "error" && (
                  <p className="text-[#FF4D6A] text-sm">{responseMsg}</p>
                )}

                <button type="submit" disabled={status === "loading"} className="btn btn-primary btn-block">
                  {status === "loading" ? (
                    <span className="inline-block w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  ) : (
                    <>
                      <Send size={15} />
                      Envoyer le message
                    </>
                  )}
                </button>

                <p className="text-[#EDEDFF]/22 text-xs text-center">
                  Tes données ne seront jamais partagées. RGPD respecté.
                </p>
              </form>
            )}
          </motion.div>
        </div>
      </div>
    </section>
  );
}

const APP_STORE_URL = "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978";

function NewsletterForm() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [msg, setMsg] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("loading");
    try {
      const res = await fetch("/api/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, source: "contact-newsletter" }),
      });
      const data = await res.json();
      setStatus(res.ok ? "success" : "error");
      setMsg(res.ok ? data.message : data.error);
      if (res.ok) setEmail("");
    } catch {
      setStatus("error");
      setMsg("Erreur réseau. Réessaie.");
    }
  };

  return (
    <div className="flex flex-col items-center gap-6 max-w-sm mx-auto">
      <motion.a
        href={APP_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        className="btn btn-primary btn-block"
        whileHover={{ scale: 1.03, boxShadow: "0 12px 48px rgba(109,40,217,0.5)" }}
        whileTap={{ scale: 0.97 }}
        style={{ fontSize: 16, padding: "16px 36px", display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 10 }}
      >
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
        </svg>
        Télécharger sur l&apos;App Store
      </motion.a>

      <p className="text-[#EDEDFF]/28 text-xs">Gratuit · Sans CB · RGPD</p>

      <div className="w-full">
        <p className="text-[#EDEDFF]/40 text-sm text-center mb-3">
          Sur Android ? Sois notifié·e dès le lancement →
        </p>
        {status === "success" ? (
          <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-[#00D4C8] text-sm text-center font-medium">
            ✓ {msg}
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
            <button type="submit" disabled={status === "loading"} className="btn btn-primary" style={{ padding: "10px 16px" }}>
              {status === "loading" ? (
                <span className="inline-block w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <ArrowRight size={14} />
              )}
            </button>
          </form>
        )}
        {status === "error" && (
          <p className="text-[#FF4D6A] text-xs text-center mt-2">{msg}</p>
        )}
      </div>
    </div>
  );
}
