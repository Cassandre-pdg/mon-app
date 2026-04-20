import { ImageResponse } from "next/og";

export const runtime = "edge";
export const alt = "kolyb — Ton élan, au quotidien.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function OgImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "1200px",
          height: "630px",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          background: "#0D0B1E",
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Background glow */}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -60%)",
            width: "700px",
            height: "500px",
            borderRadius: "50%",
            background: "radial-gradient(circle, rgba(109,40,217,0.35) 0%, transparent 70%)",
          }}
        />
        <div
          style={{
            position: "absolute",
            bottom: "-50px",
            right: "100px",
            width: "300px",
            height: "300px",
            borderRadius: "50%",
            background: "radial-gradient(circle, rgba(0,212,200,0.12) 0%, transparent 70%)",
          }}
        />

        {/* Icon */}
        <div
          style={{
            width: "88px",
            height: "88px",
            borderRadius: "24px",
            background: "#1A1836",
            border: "1.5px solid #22204A",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            marginBottom: "28px",
          }}
        >
          <svg width="52" height="52" viewBox="0 0 52 52" fill="none">
            <circle cx="26" cy="26" r="16" stroke="#6D28D9" strokeWidth="2.5" />
            <circle cx="26" cy="26" r="7" fill="#8B7FE8" />
            <circle cx="26" cy="10" r="3" fill="#C4B5FD" />
          </svg>
        </div>

        {/* App name */}
        <div
          style={{
            fontSize: "52px",
            fontWeight: 700,
            color: "#FFFFFF",
            letterSpacing: "-0.03em",
            marginBottom: "16px",
          }}
        >
          kolyb
        </div>

        {/* Tagline */}
        <div
          style={{
            fontSize: "28px",
            fontWeight: 500,
            color: "#C4B5FD",
            letterSpacing: "-0.01em",
            marginBottom: "32px",
          }}
        >
          Ton élan, au quotidien.
        </div>

        {/* Description */}
        <div
          style={{
            fontSize: "17px",
            color: "rgba(237,237,255,0.55)",
            textAlign: "center",
            maxWidth: "560px",
            lineHeight: 1.5,
          }}
        >
          L'app compagnon des entrepreneurs indépendants.
          Check-in, planificateur, sommeil et communauté.
        </div>

        {/* Bottom pill */}
        <div
          style={{
            position: "absolute",
            bottom: "44px",
            display: "flex",
            alignItems: "center",
            gap: "8px",
            background: "rgba(109,40,217,0.20)",
            border: "1px solid rgba(139,127,232,0.35)",
            borderRadius: "100px",
            padding: "8px 20px",
            fontSize: "14px",
            color: "#8B7FE8",
            fontWeight: 500,
          }}
        >
          ✦ Beta ouverte — places limitées
        </div>
      </div>
    ),
    { ...size }
  );
}
