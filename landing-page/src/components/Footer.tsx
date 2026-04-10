"use client";

import { motion } from "framer-motion";
import { Instagram, Twitter, Linkedin, Heart } from "lucide-react";
import KolybIcon from "./KolybIcon";

const links = {
  Produit: [
    { label: "Fonctionnalités", href: "#features" },
    { label: "Comment ça marche", href: "#how-it-works" },
    { label: "FAQ", href: "#faq" },
  ],
  Entreprise: [
    { label: "Notre histoire", href: "#" },
    { label: "Contact", href: "#contact" },
    { label: "Presse", href: "#contact" },
  ],
  Légal: [
    { label: "Mentions légales", href: "#" },
    { label: "Politique de confidentialité", href: "#" },
    { label: "CGU", href: "#" },
  ],
};

const socials = [
  { icon: Instagram, href: "#", label: "Instagram" },
  { icon: Twitter, href: "#", label: "Twitter / X" },
  { icon: Linkedin, href: "#", label: "LinkedIn" },
];

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="relative pt-16 pb-8 px-6 border-t border-[#22204A]">
      <div className="max-w-6xl mx-auto">
        <div className="grid md:grid-cols-5 gap-12 mb-12">
          {/* Brand */}
          <div className="md:col-span-2">
            <div className="flex items-center gap-3 mb-5">
              <KolybIcon size={40} variant="violet" animate={false} />
              <div>
                <p
                  className="text-xl font-bold text-white"
                  style={{ letterSpacing: "-0.02em" }}
                >
                  kolyb
                </p>
                <p className="text-xs text-[#8B7FE8]" style={{ letterSpacing: "0.03em" }}>
                  Ton élan, au quotidien.
                </p>
              </div>
            </div>
            <p className="text-sm text-[#EDEDFF]/45 leading-relaxed mb-6 max-w-xs">
              Le compagnon des entrepreneurs indépendants. Avance à ton rythme,
              progresser ensemble, prendre soin de toi.
            </p>

            {/* Socials */}
            <div className="flex items-center gap-3">
              {socials.map((s) => {
                const Icon = s.icon;
                return (
                  <a
                    key={s.label}
                    href={s.href}
                    aria-label={s.label}
                    className="w-9 h-9 rounded-xl bg-[#1A1836] border border-[#22204A] flex items-center justify-center text-[#EDEDFF]/40 hover:text-white hover:border-[#6D28D9]/40 transition-all duration-200"
                  >
                    <Icon size={16} />
                  </a>
                );
              })}
            </div>
          </div>

          {/* Links */}
          {Object.entries(links).map(([category, items]) => (
            <div key={category}>
              <p className="text-xs font-semibold text-[#EDEDFF]/40 uppercase tracking-[0.08em] mb-4">
                {category}
              </p>
              <ul className="flex flex-col gap-3">
                {items.map((link) => (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      className="text-sm text-[#EDEDFF]/55 hover:text-white transition-colors duration-200"
                    >
                      {link.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Disclaimer */}
        <div className="mb-8 p-4 rounded-xl bg-[#1A1836] border border-[#22204A]">
          <p className="text-xs text-[#EDEDFF]/30 text-center leading-relaxed">
            ⚠️ kolyb est un outil de bien-être et de productivité — pas un dispositif médical.
            Si tu traverses une période difficile, n&apos;hésite pas à consulter un professionnel de santé.
          </p>
        </div>

        {/* Bottom */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-6 border-t border-[#22204A]">
          <p className="text-xs text-[#EDEDFF]/25">
            © {year} kolyb — Tous droits réservés
          </p>
          <p className="text-xs text-[#EDEDFF]/25 flex items-center gap-1.5">
            Fait avec <Heart size={11} className="text-[#FF4D6A]" fill="#FF4D6A" /> en France
            <span className="mx-2 text-[#22204A]">·</span>
            Hébergé en EU
            <span className="mx-2 text-[#22204A]">·</span>
            RGPD ✓
          </p>
        </div>
      </div>
    </footer>
  );
}
