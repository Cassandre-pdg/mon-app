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
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          {/* Logo */}
          <a href="#" className="flex items-center gap-3 group">
            <KolybIcon size={36} variant="violet" animate={false} />
            <span
              className="text-2xl font-bold text-white tracking-tight"
              style={{ letterSpacing: "-0.02em" }}
            >
              kolyb
            </span>
          </a>

          {/* Desktop nav */}
          <nav className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="text-sm font-medium text-[#EDEDFF]/70 hover:text-white transition-colors duration-200"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* CTA */}
          <div className="hidden md:flex items-center gap-3">
            <a
              href="#hero-form"
              className="px-6 py-3 bg-[#6D28D9] hover:bg-[#5B21B6] text-white text-sm font-semibold rounded-xl transition-all duration-200 hover:shadow-lg hover:shadow-purple-900/30"
            >
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
            className="fixed inset-x-0 top-16 z-40 bg-[#1A1836]/95 backdrop-blur-xl border-b border-[#22204A] md:hidden"
          >
            <nav className="max-w-6xl mx-auto px-6 py-6 flex flex-col gap-4">
              {navLinks.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className="text-base font-medium text-[#EDEDFF]/80 hover:text-white py-2 border-b border-[#22204A] last:border-0 transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <a
                href="#hero-form"
                onClick={() => setMobileOpen(false)}
                className="mt-2 px-5 py-3 bg-[#6D28D9] text-white text-sm font-semibold rounded-xl text-center transition-all hover:bg-[#5B21B6]"
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
