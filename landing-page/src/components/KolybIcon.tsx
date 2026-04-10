"use client";

import { motion, useAnimation } from "framer-motion";
import { useState } from "react";

interface KolybIconProps {
  size?: number;
  variant?: "dark" | "violet";
  animate?: boolean;
  className?: string;
}

export default function KolybIcon({
  size = 80,
  variant = "violet",
  animate = true,
  className = "",
}: KolybIconProps) {
  const controls = useAnimation();
  const [isAnimating, setIsAnimating] = useState(false);

  const bgColor = variant === "violet" ? "#6D28D9" : "#1A1836";
  const hublotColor = variant === "violet" ? "#6D28D9" : "#1A1836";

  const handleClick = async () => {
    if (!animate || isAnimating) return;
    setIsAnimating(true);

    // Frémit
    await controls.start({
      y: [0, -4, 0, -4, 0],
      transition: { duration: 0.3, ease: "easeInOut" },
    });

    // Décollage
    await controls.start({
      y: [0, -size * 0.3],
      scale: [1, 0.95],
      transition: { duration: 0.4, ease: [0.4, 0, 0.2, 1] },
    });

    // En orbite — retour
    await controls.start({
      y: 0,
      scale: 1,
      transition: { duration: 0.5, type: "spring", stiffness: 300, damping: 20 },
    });

    setIsAnimating(false);
  };

  return (
    <motion.div
      className={`cursor-pointer select-none ${className}`}
      animate={controls}
      whileHover={animate ? { scale: 1.05 } : {}}
      whileTap={animate ? { scale: 0.95 } : {}}
      onClick={handleClick}
      style={{ width: size, height: size }}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width={size}
        height={size}
        viewBox="0 0 1024 1024"
      >
        {/* Fond */}
        <rect width="1024" height="1024" rx="220" fill={bgColor} />

        {/* Étoiles */}
        <motion.circle
          cx="310" cy="200" r="18"
          fill="white" fillOpacity="0.65"
          animate={animate ? { opacity: [0.65, 1, 0.65] } : {}}
          transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.circle
          cx="740" cy="172" r="14"
          fill="white" fillOpacity="0.52"
          animate={animate ? { opacity: [0.52, 0.9, 0.52] } : {}}
          transition={{ duration: 4, repeat: Infinity, ease: "easeInOut", delay: 1 }}
        />
        <motion.circle
          cx="718" cy="290" r="9"
          fill="white" fillOpacity="0.40"
          animate={animate ? { opacity: [0.4, 0.8, 0.4] } : {}}
          transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
        />

        {/* Ogive */}
        <path d="M380 560 L510 220 Q512 216 514 220 L644 560 Z" fill="white" />

        {/* Corps */}
        <rect x="400" y="556" width="224" height="230" rx="40" fill="white" />

        {/* Hublot */}
        <circle cx="512" cy="630" r="62" fill={hublotColor} />
        <circle cx="512" cy="630" r="36" fill="white" fillOpacity="0.78" />

        {/* Ailerons */}
        <path d="M400 610 L296 730 L400 692 Z" fill="white" fillOpacity="0.88" />
        <path d="M624 610 L728 730 L624 692 Z" fill="white" fillOpacity="0.88" />

        {/* Flammes */}
        <motion.ellipse
          cx="474" cy="808" rx="38" ry="72"
          fill="white" fillOpacity="0.42"
          animate={animate ? { ry: [72, 85, 72], fillOpacity: [0.42, 0.6, 0.42] } : {}}
          transition={{ duration: 0.8, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.ellipse
          cx="512" cy="824" rx="50" ry="90"
          fill="white" fillOpacity="0.65"
          animate={animate ? { ry: [90, 108, 90], fillOpacity: [0.65, 0.85, 0.65] } : {}}
          transition={{ duration: 0.6, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.ellipse
          cx="550" cy="808" rx="38" ry="72"
          fill="white" fillOpacity="0.42"
          animate={animate ? { ry: [72, 85, 72], fillOpacity: [0.42, 0.6, 0.42] } : {}}
          transition={{ duration: 0.8, repeat: Infinity, ease: "easeInOut", delay: 0.2 }}
        />
      </svg>
    </motion.div>
  );
}
