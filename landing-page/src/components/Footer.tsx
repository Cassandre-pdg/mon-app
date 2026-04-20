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
    { label: "Mentions légales", href: "https://cassandre-pdg.github.io/kolyb-support/mentions-legales.html" },
    { label: "Confidentialité", href: "https://cassandre-pdg.github.io/kolyb-support/confidentialite.html" },
    { label: "CGU", href: "https://cassandre-pdg.github.io/kolyb-support/cgu.html" },
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
    <footer className="relative pt-24 pb-14">
      {/* Gradient top border */}
      <div className="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-[#6D28D9]/40 to-transparent" />

      <div className="wrap">
        {/* Main grid */}
        <div className="footer-princ grid grid-cols-2 md:grid-cols-[2fr_1fr_1fr_1fr] gap-14 pb-20">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <div className="flex items-center gap-2.5 mb-6">
              <KolybIcon size={30} variant="violet" animate={false} />
              <span className="text-lg font-bold text-white" style={{ letterSpacing: "-0.02em" }}>
                kolyb
              </span>
            </div>
            <p className="sous-titre-foot text-sm text-[#8B7FE8] mb-4" style={{ letterSpacing: "0.03em" }}>
              Ton élan, au quotidien.
            </p>
            <p className="text-sm text-[#EDEDFF]/32 leading-relaxed max-w-[200px]">
              Le compagnon des entrepreneurs.
            </p>

            {/* Social icons */}
            <div className="icon-footer flex items-center gap-3 mt-10">
              {socials.map((s) => {
                const Icon = s.icon;
                return (
                  <a
                    key={s.label}
                    href={s.href}
                    aria-label={s.label}
                    className="w-8 h-8 rounded-lg bg-[#1A1836] border border-[#22204A] flex items-center justify-center text-[#EDEDFF]/32 hover:text-white hover:bg-[#6D28D9]/25 hover:border-[#6D28D9]/35 transition-all duration-200"
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
              <p className="text-[10px] font-semibold text-[#EDEDFF]/28 uppercase tracking-[0.12em] mb-7">
                {category}
              </p>
              <ul className="flex flex-col gap-5">
                {items.map((link) => (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      className="text-sm text-[#EDEDFF]/42 hover:text-[#EDEDFF]/90 transition-colors duration-200"
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
        <div className="pt-8 border-t border-[#1A1836] flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-4 flex-wrap">
            <p className="text-xs text-[#EDEDFF]/20">
              © {year} kolyb · Tous droits réservés
            </p>
            <span className="text-[#22204A]">·</span>
            <a
              href="https://cassandre-pdg.github.io/kolyb-support/mentions-legales.html"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-[#EDEDFF]/20 hover:text-[#EDEDFF]/50 transition-colors duration-200"
            >
              Mentions légales
            </a>
            <span className="text-[#22204A]">·</span>
            <a
              href="https://cassandre-pdg.github.io/kolyb-support/confidentialite.html"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-[#EDEDFF]/20 hover:text-[#EDEDFF]/50 transition-colors duration-200"
            >
              Confidentialité
            </a>
            <span className="text-[#22204A]">·</span>
            <a
              href="https://cassandre-pdg.github.io/kolyb-support/cgu.html"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-[#EDEDFF]/20 hover:text-[#EDEDFF]/50 transition-colors duration-200"
            >
              CGU
            </a>
          </div>
          <div className="flex items-center gap-5 text-xs text-[#EDEDFF]/20">
            <span className="flex items-center gap-1.5">
              Fait avec <Heart size={10} className="text-[#FF4D6A]" fill="#FF4D6A" /> en France
            </span>
            <span className="text-[#22204A]">·</span>
            <span>🇪🇺 Hébergé EU</span>
            <span className="text-[#22204A]">·</span>
            <span className="text-[#00D4C8]/60">RGPD ✓</span>
          </div>
        </div>

        {/* Disclaimer */}
        <p className="text-[10px] text-[#EDEDFF]/14 text-center mt-8 max-w-2xl mx-auto leading-relaxed">
          kolyb est un outil de bien-être, pas un dispositif médical. Si tu traverses une période difficile, n&apos;hésite pas à consulter un professionnel de santé.
        </p>
      </div>
    </footer>
  );
}
