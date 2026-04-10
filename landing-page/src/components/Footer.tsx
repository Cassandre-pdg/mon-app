"use client";

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
    { label: "Confidentialité", href: "#" },
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
    <footer className="relative pt-16 pb-10 px-6">
      {/* Gradient top border */}
      <div className="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-[#6D28D9]/50 to-transparent" />

      <div className="max-w-6xl mx-auto">
        {/* Main grid */}
        <div className="grid grid-cols-2 md:grid-cols-[2fr_1fr_1fr_1fr] gap-10 pb-14">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <div className="flex items-center gap-2.5 mb-3">
              <KolybIcon size={32} variant="violet" animate={false} />
              <span
                className="text-lg font-bold text-white"
                style={{ letterSpacing: "-0.02em" }}
              >
                kolyb
              </span>
            </div>
            <p
              className="text-sm text-[#8B7FE8] mb-4"
              style={{ letterSpacing: "0.03em" }}
            >
              Ton élan, au quotidien.
            </p>
            <p className="text-sm text-[#EDEDFF]/35 leading-relaxed max-w-[200px]">
              Le compagnon des entrepreneurs indépendants.
            </p>

            {/* Social icons */}
            <div className="flex items-center gap-2 mt-6">
              {socials.map((s) => {
                const Icon = s.icon;
                return (
                  <a
                    key={s.label}
                    href={s.href}
                    aria-label={s.label}
                    className="w-8 h-8 rounded-lg bg-[#1A1836] flex items-center justify-center text-[#EDEDFF]/35 hover:text-white hover:bg-[#6D28D9]/25 transition-all duration-200"
                  >
                    <Icon size={14} />
                  </a>
                );
              })}
            </div>
          </div>

          {/* Link columns */}
          {Object.entries(links).map(([category, items]) => (
            <div key={category}>
              <p className="text-[10px] font-semibold text-[#EDEDFF]/30 uppercase tracking-[0.1em] mb-5">
                {category}
              </p>
              <ul className="flex flex-col gap-3">
                {items.map((link) => (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      className="text-sm text-[#EDEDFF]/45 hover:text-[#EDEDFF] transition-colors duration-200"
                    >
                      {link.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Bottom bar */}
        <div className="pt-6 border-t border-[#1A1836] flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-xs text-[#EDEDFF]/20">
            © {year} kolyb — Tous droits réservés
          </p>
          <div className="flex items-center gap-5 text-xs text-[#EDEDFF]/20">
            <span className="flex items-center gap-1.5">
              Fait avec <Heart size={10} className="text-[#FF4D6A]" fill="#FF4D6A" /> en France
            </span>
            <span className="text-[#22204A]">·</span>
            <span>🇪🇺 Hébergé EU</span>
            <span className="text-[#22204A]">·</span>
            <span className="text-[#00D4C8]/70">RGPD ✓</span>
          </div>
        </div>

        {/* Disclaimer — minimal inline */}
        <p className="text-[10px] text-[#EDEDFF]/15 text-center mt-5 max-w-2xl mx-auto leading-relaxed">
          kolyb est un outil de bien-être — pas un dispositif médical. Si tu traverses une période difficile, n&apos;hésite pas à consulter un professionnel de santé.
        </p>
      </div>
    </footer>
  );
}
