"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import KolybIcon from "./KolybIcon";

const navLinks = [
  { label: "Fonctionnalités", href: "#features" },
  { label: "Comment ça marche", href: "#how-it-works" },
  { label: "FAQ", href: "#faq" },
  { label: "Contact", href: "#contact" },
];

const auditLink = { label: "✦ Audit gratuit", href: "/audit" };

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <>
      <motion.header
        initial={{ y: -80, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          scrolled
            ? "bg-[#0D0B1E]/90 backdrop-blur-xl border-b border-[#22204A]"
            : "bg-transparent"
        }`}
      >
        <div className="wrap flex items-center justify-between h-16">
          {/* Logo */}
          <a href="#" className="flex items-center gap-3 group">
            <KolybIcon size={34} variant="violet" animate={false} />
            <span className="text-xl font-bold text-white" style={{ letterSpacing: "-0.02em" }}>
              kolyb
            </span>
          </a>

          {/* Desktop nav */}
          <nav className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="text-sm font-medium text-[#EDEDFF]/65 hover:text-white transition-colors duration-200"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* CTA */}
          <div className="hidden md:flex items-center gap-3">
            <a
              href={auditLink.href}
              style={{
                fontSize: 12, fontWeight: 600, letterSpacing: "0.01em",
                color: "#C4B5FD", textDecoration: "none",
                padding: "8px 14px", borderRadius: 99,
                background: "rgba(109,40,217,0.12)",
                border: "1px solid rgba(109,40,217,0.28)",
                transition: "background 0.2s, color 0.2s",
                whiteSpace: "nowrap",
              }}
            >
              {auditLink.label}
            </a>
            <a href="#hero-form" className="btn btn-primary" style={{ padding: "10px 22px", fontSize: "13px" }}>
              Rejoindre la beta
            </a>
          </div>

          {/* Mobile burger */}
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden p-2 text-white rounded-lg hover:bg-[#1A1836] transition-colors"
            aria-label="Menu"
          >
            {mobileOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </motion.header>

      {/* Mobile menu */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-x-0 top-16 z-40 bg-[#1A1836]/96 backdrop-blur-xl border-b border-[#22204A] md:hidden"
          >
            <nav className="wrap py-6 flex flex-col gap-1">
              {navLinks.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className="text-base font-medium text-[#EDEDFF]/75 hover:text-white py-3 border-b border-[#22204A] last:border-0 transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <a
                href={auditLink.href}
                onClick={() => setMobileOpen(false)}
                className="text-base font-semibold py-3 border-b border-[#22204A] transition-colors"
                style={{ color: "#C4B5FD" }}
              >
                {auditLink.label}
              </a>
              <a
                href="#hero-form"
                onClick={() => setMobileOpen(false)}
                className="btn btn-primary mt-4 mx-auto"
              >
                Rejoindre la beta
              </a>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
