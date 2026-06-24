"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";

const EASE: [number, number, number, number] = [0.22, 1, 0.36, 1];

export default function OurStory() {
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });

  return (
    <section ref={ref} id="notre-histoire" className="section" style={{ overflow: "hidden", position: "relative" }}>
      {/* BG glow */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden" aria-hidden="true">
        <div className="absolute top-1/2 left-1/4 -translate-y-1/2 w-[500px] h-[500px] bg-[#6D28D9]/10 rounded-full blur-[120px]" />
        <div className="absolute top-1/3 right-1/4 w-[300px] h-[300px] bg-[#00D4C8]/8 rounded-full blur-[100px]" />
      </div>

      <div className="wrap relative z-10">
        <div className="grid md:grid-cols-2 gap-16 items-center">

          {/* Left — portrait card */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.75, ease: EASE }}
            className="flex justify-center"
          >
            <div
              className="relative rounded-3xl overflow-hidden"
              style={{
                width: "100%",
                maxWidth: 420,
                background: "linear-gradient(135deg, rgba(109,40,217,0.15) 0%, rgba(0,212,200,0.08) 100%)",
                border: "1px solid rgba(109,40,217,0.25)",
                textAlign: "center",
              }}
            >
              {/* Photo */}
              <div style={{ width: "100%", height: 380, overflow: "hidden", position: "relative" }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/cassandre-1.png"
                  alt="Cassandre Rollet, fondatrice de kolyb"
                  style={{ width: "100%", height: "100%", objectFit: "cover", objectPosition: "center top" }}
                />
                {/* Gradient overlay bas */}
                <div style={{
                  position: "absolute", bottom: 0, left: 0, right: 0, height: 80,
                  background: "linear-gradient(to bottom, transparent, rgba(13,11,30,0.85))"
                }} />
              </div>

              {/* Infos */}
              <div style={{ padding: "32px 32px 40px" }}>
                <p className="text-white font-bold text-xl" style={{ letterSpacing: "-0.02em", marginBottom: 10 }}>
                  Cassandre Rollet
                </p>
                <p className="text-[#8B7FE8] text-sm font-medium" style={{ marginBottom: 24 }}>
                  Fondatrice & CEO · kolyb
                </p>

                <div
                  style={{
                    background: "rgba(109,40,217,0.12)",
                    border: "1px solid rgba(109,40,217,0.2)",
                    borderRadius: 12,
                    padding: "14px 16px",
                    fontSize: 13,
                    color: "rgba(237,237,255,0.6)",
                    marginBottom: 24,
                  }}
                >
                  🇫🇷 France · Entrepreneuse solo · 21 ans
                </div>

                <div className="flex justify-center gap-3">
                  <a
                    href="https://www.instagram.com/cassandre.rollet/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs text-[#8B7FE8] hover:text-white transition-colors px-3 py-1.5 rounded-full"
                    style={{ background: "rgba(109,40,217,0.12)", border: "1px solid rgba(109,40,217,0.2)" }}
                  >
                    Instagram
                  </a>
                  <a
                    href="https://www.linkedin.com/in/cassandrerollet/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs text-[#8B7FE8] hover:text-white transition-colors px-3 py-1.5 rounded-full"
                    style={{ background: "rgba(109,40,217,0.12)", border: "1px solid rgba(109,40,217,0.2)" }}
                  >
                    LinkedIn
                  </a>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Right — story */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.75, ease: EASE, delay: 0.1 }}
            className="flex flex-col gap-8"
          >
            <div>
              <p className="eyebrow">Notre histoire</p>
              <h2 className="section-title mt-0">
                Née d&apos;un problème{" "}
                <span className="gradient-text">vécu.</span>
              </h2>
            </div>

            <div className="flex flex-col gap-5 text-[#EDEDFF]/65 leading-relaxed" style={{ fontSize: 15 }}>
              <p>
                À 21 ans, entrepreneuse solo, je jonglais entre Notion, Todoist, Calm, carnet de notes, docx...
                juste pour gérer mon activité. Résultat : épuisante dispersion, isolement progressif,
                et l&apos;impression de courir h24 sans vraiment avancer.
              </p>
              <p>
                J&apos;ai cherché une app qui réunisse tout, pensée pour les indépendants français.
                Elle n&apos;existait pas. Alors je l&apos;ai construite.
              </p>
              <p>
                Kolyb, c&apos;est chaque fonctionnalité qui répond à un vrai problème vécu.
                Pas de features gadgets, pas de jargon toxic de surperformance. Juste ce dont tu as besoin
                pour avancer, à ton rythme, sans jamais te sentir seul·e.
              </p>
              <p
                style={{
                  background: "rgba(109,40,217,0.1)",
                  border: "1px solid rgba(109,40,217,0.22)",
                  borderRadius: 12,
                  padding: "14px 16px",
                  color: "rgba(237,237,255,0.75)",
                  fontSize: 14,
                }}
              >
                ✨ <span style={{ color: "#C4B5FD", fontWeight: 600 }}>Kolyb, c&apos;est la v1.</span> Viens l&apos;essayer et dis-moi ce que tu voudrais en plus : chaque retour compte vraiment. L&apos;app a pour but d&apos;évoluer très loin, avec toi.
              </p>
            </div>

            {/* Values */}
            <div className="grid grid-cols-2 gap-4 mt-2">
              {[
                { emoji: "🇪🇺", label: "100% RGPD", sub: "Hébergé en Europe" },
                { emoji: "🛠️", label: "Solo-built", sub: "Chaque feature vécue" },
                { emoji: "💜", label: "Bienveillant", sub: "Jamais moralisateur" },
                { emoji: "🚀", label: "Lancé juin 2026", sub: "iOS disponible" },
              ].map((v) => (
                <div
                  key={v.label}
                  style={{
                    background: "rgba(26,24,54,0.8)",
                    border: "1px solid rgba(34,32,74,0.8)",
                    borderRadius: 12,
                    padding: "14px 16px",
                  }}
                >
                  <p className="text-lg mb-1">{v.emoji}</p>
                  <p className="text-white text-sm font-semibold" style={{ letterSpacing: "-0.01em" }}>{v.label}</p>
                  <p className="text-[#EDEDFF]/38 text-xs mt-0.5">{v.sub}</p>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
