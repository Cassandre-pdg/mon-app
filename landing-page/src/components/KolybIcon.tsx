"use client";

import { motion, useAnimation } from "framer-motion";
import { useState } from "react";
import Image from "next/image";

interface KolybIconProps {
  size?: number;
  variant?: "dark" | "violet";
  animate?: boolean;
  className?: string;
}

export default function KolybIcon({
  size = 80,
  animate = true,
  className = "",
}: KolybIconProps) {
  const controls = useAnimation();
  const [isAnimating, setIsAnimating] = useState(false);

  const handleClick = async () => {
    if (!animate || isAnimating) return;
    setIsAnimating(true);

    await controls.start({
      scale: [1, 1.08, 0.96, 1.04, 1],
      transition: { duration: 0.4, ease: "easeInOut" },
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
      style={{ width: size, height: size, borderRadius: size * 0.215, overflow: "hidden" }}
    >
      <Image
        src="/kolyb_icon.png"
        alt="kolyb"
        width={size}
        height={size}
        style={{ width: size, height: size, display: "block" }}
        priority
      />
    </motion.div>
  );
}
