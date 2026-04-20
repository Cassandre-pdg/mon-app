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
  "Je veux rejoindre la beta",
  "J'ai une idée pour l'app",
  "Je veux pitcher un partenariat",
  "Presse / média",
  "Autre",
];

export default function Contact() {
  const ref = useRef(null);
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
    setResponseMsg("Message reçu ! On te répond dans les 48h. 🙌");
    setForm({ firstName: "", email: "", subject: subjects[0], message: "" });
  };

  return (
    <section ref={ref} id="contact" className="section overflow-hidden">
      {/* BG */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[300px] bg-[#6D28D9]/12 rounded-full blur-[100px]" />
      </div>

      <div className="wrap relative z-10">
        {/* Top CTA — Email capture */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-28"
        >
          <p className="eyebrow">Rejoindre l&apos;aventure</p>
          <h2 className="section-title mt-0">
            Prêt·e à avancer{" "}
            <span className="gradient-text">différemment ?</span>
          </h2>
          <p className="section-sub mb-10">
            Rejoins les premiers entrepreneurs qui façonnent kolyb.
            Accès beta prioritaire, feedback direct, et la fierté d&apos;avoir été là dès le début.
          </p>
          <NewsletterForm />
        </motion.div>

        {/* Separator */}
        <div className="flex items-center gap-4 mb-20">
          <div className="flex-1 h-px bg-[#22204A]" />
          <span className="text-sm text-[#EDEDFF]/28 font-medium px-4 whitespace-nowrap">
            ou envoie-nous un message
          </span>
          <div className="flex-1 h-px bg-[#22204A]" />
        </div>

        {/* Contact form grid */}
        <div className="grid md:grid-cols-2 gap-12 items-start">
          {/* Left — info */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="flex flex-col gap-12"
          >
            <div>
              <h3 className="text-2xl font-bold text-white mb-5" style={{ letterSpacing: "-0.02em" }}>
                On adore avoir de tes nouvelles
              </h3>
              <p className="text-[#EDEDFF]/55 leading-relaxed text-sm">
                Idée de feature, question, feedback, partenariat : toutes les raisons sont bonnes.
                On répond personnellement dans les 48h.
              </p>
            </div>

            <div className="flex flex-col gap-6">
              {[
                { icon: Mail, label: "Email", value: "hello@kolyb.app" },
                { icon: MessageCircle, label: "Réponse", value: "Toujours sous 48h" },
              ].map((item) => {
                const Icon = item.icon;
                return (
                  <div key={item.label} className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-xl bg-[#6D28D9]/15 border border-[#6D28D9]/22 flex items-center justify-center flex-shrink-0">
                      <Icon size={17} className="text-[#8B7FE8]" />
                    </div>
                    <div>
                      <p className="text-xs text-[#EDEDFF]/38 font-medium uppercase tracking-wider mb-0.5">
                        {item.label}
                      </p>
                      <p className="text-sm text-[#EDEDFF]/80 font-medium">{item.value}</p>
                    </div>
                  </div>
                );
              })}
            </div>

            <div className="p-7 rounded-2xl bg-[#1A1836] border border-[#22204A]">
              <p className="text-sm text-[#EDEDFF]/55 leading-relaxed">
                <span className="text-[#C4B5FD] font-semibold">kolyb</span> est construit par une
                fondatrice solo qui vit les mêmes défis que toi. Ton retour compte vraiment, il
                façonne directement l&apos;app.
              </p>
            </div>
          </motion.div>

          {/* Right — form */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.3 }}
          >
            {status === "success" ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="flex flex-col items-center justify-center text-center p-12 rounded-2xl bg-[#1A1836] border border-[#22204A]"
              >
                <div className="text-5xl mb-5">🙌</div>
                <h4 className="text-xl font-bold text-white mb-3">{responseMsg}</h4>
                <p className="text-[#EDEDFF]/45 text-sm mb-6">
                  En attendant, rejoins la liste d&apos;attente si ce n&apos;est pas déjà fait !
                </p>
                <button
                  onClick={() => setStatus("idle")}
                  className="text-sm text-[#8B7FE8] hover:text-white transition-colors"
                >
                  Envoyer un autre message
                </button>
              </motion.div>
            ) : (
              <form
                onSubmit={handleSubmit}
                className="p-8 rounded-2xl bg-[#1A1836] border border-[#22204A] flex flex-col gap-7"
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
                      className="input input-dark"
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
                      className="input input-dark"
                    />
                  </div>
                </div>

                <div className="field">
                  <label className="label">Sujet</label>
                  <select
                    name="subject"
                    value={form.subject}
                    onChange={handleChange}
                    className="input input-dark appearance-none cursor-pointer"
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
                    className="input input-dark resize-none"
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

  if (status === "success") {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="inline-flex items-center gap-3 px-7 py-4 rounded-2xl bg-[#00D4C8]/10 border border-[#00D4C8]/28"
      >
        <span className="text-2xl">🚀</span>
        <p className="text-[#00D4C8] font-semibold">{msg}</p>
      </motion.div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col sm:flex-row gap-3 max-w-lg mx-auto"
    >
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
            Accès prioritaire
            <ArrowRight size={16} />
          </>
        )}
      </button>
    </form>
  );
}
