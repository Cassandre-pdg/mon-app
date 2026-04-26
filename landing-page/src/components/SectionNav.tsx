"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const sections = [
  { id: "hero", label: "Accueil" },
  { id: "problem", label: "Le problème" },
  { id: "features", label: "Fonctionnalités" },
  { id: "how-it-works", label: "Comment ça marche" },
  { id: "benefits", label: "Avantages" },
  { id: "faq", label: "FAQ" },
  { id: "contact", label: "Contact" },
];

export default function SectionNav() {
  const [active, setActive] = useState("hero");
  const [hovered, setHovered] = useState<string | null>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActive(entry.target.id);
          }
        });
      },
      { rootMargin: "-40% 0px -40% 0px", threshold: 0 }
    );

    sections.forEach(({ id }) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });

    const onScroll = () => setVisible(window.scrollY > 200);
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();

    return () => {
      observer.disconnect();
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  return (
    <AnimatePresence>
      {visible && (
        <motion.nav
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 20 }}
          transition={{ duration: 0.4 }}
          aria-label="Navigation sections"
          style={{
            position: "fixed",
            right: "24px",
            top: "50%",
            transform: "translateY(-50%)",
            zIndex: 50,
            display: "flex",
            flexDirection: "column",
            gap: "10px",
          }}
        >
          {sections.map(({ id, label }) => {
            const isActive = active === id;
            const isHovered = hovered === id;
            return (
              <motion.button
                key={id}
                onClick={() => {
                  document.getElementById(id)?.scrollIntoView({ behavior: "smooth" });
                }}
                onMouseEnter={() => setHovered(id)}
                onMouseLeave={() => setHovered(null)}
                aria-label={`Aller à ${label}`}
                style={{
                  position: "relative",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "flex-end",
                  gap: "8px",
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  padding: "4px 0",
                }}
                whileHover={{ scale: 1.05 }}
              >
                {/* Tooltip label */}
                <AnimatePresence>
                  {isHovered && (
                    <motion.span
                      initial={{ opacity: 0, x: 8 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 8 }}
                      transition={{ duration: 0.15 }}
                      style={{
                        fontSize: "11px",
                        fontWeight: 600,
                        color: isActive ? "#C4B5FD" : "rgba(237,237,255,0.55)",
                        whiteSpace: "nowrap",
                        letterSpacing: "0.04em",
                        textTransform: "uppercase",
                      }}
                    >
                      {label}
                    </motion.span>
                  )}
                </AnimatePresence>

                {/* Dot */}
                <motion.span
                  animate={{
                    width: isActive ? 16 : 6,
                    height: isActive ? 6 : 6,
                    background: isActive
                      ? "linear-gradient(90deg, #8B7FE8, #00D4C8)"
                      : isHovered
                      ? "rgba(139,127,232,0.6)"
                      : "rgba(139,127,232,0.25)",
                  }}
                  transition={{ duration: 0.25, ease: "easeInOut" }}
                  style={{
                    borderRadius: "9999px",
                    display: "block",
                    flexShrink: 0,
                  }}
                />
              </motion.button>
            );
          })}
        </motion.nav>
      )}
    </AnimatePresence>
  );
}
