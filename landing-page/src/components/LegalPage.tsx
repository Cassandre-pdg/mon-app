import type { ReactNode } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export default function LegalPage({
  tag,
  title,
  lastUpdated,
  children,
}: {
  tag: string;
  title: string;
  lastUpdated: string;
  children: ReactNode;
}) {
  return (
    <main className="min-h-screen bg-[#0D0B1E]">
      <Navbar />

      <section className="section" style={{ paddingTop: "clamp(120px, 16vw, 160px)" }}>
        <div className="wrap-md">
          <div style={{ textAlign: "center", marginBottom: 48 }}>
            <span className="badge badge-violet">{tag}</span>
            <h1
              style={{
                fontSize: "clamp(1.7rem, 4vw, 2.25rem)",
                fontWeight: 700,
                color: "#fff",
                letterSpacing: "-0.02em",
                marginBottom: 10,
              }}
            >
              {title}
            </h1>
            <p style={{ fontSize: 13, color: "rgba(237,237,255,0.35)" }}>
              Dernière mise à jour : {lastUpdated}
            </p>
          </div>

          <div className="legal-content">{children}</div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
