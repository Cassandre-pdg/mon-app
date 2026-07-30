import type { Metadata } from "next";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { getAllArticles } from "@/lib/blog";

export const metadata: Metadata = {
  title: "Le blog kolyb : bien-être, productivité et vie d'indépendant",
  description:
    "Des articles pour avancer sereinement en solo : lutter contre l'isolement, éviter le surmenage, mieux t'organiser au quotidien en tant qu'entrepreneur indépendant.",
  alternates: {
    canonical: "/blog",
  },
  openGraph: {
    title: "Le blog kolyb : bien-être, productivité et vie d'indépendant",
    description:
      "Des articles pour avancer sereinement en solo, écrits pour et par la réalité des entrepreneurs indépendants.",
    url: "/blog",
    type: "website",
  },
};

export default function BlogIndexPage() {
  const articles = getAllArticles();

  return (
    <main className="min-h-screen bg-[#0D0B1E]">
      <Navbar />

      <section className="section" style={{ paddingTop: "clamp(120px, 16vw, 160px)" }}>
        <div className="wrap-md" style={{ textAlign: "center", marginBottom: 56 }}>
          <p className="eyebrow">Le blog</p>
          <h1 className="section-title">
            Avancer en solo,{" "}
            <span className="gradient-text">sans se perdre en route</span>
          </h1>
          <p className="section-sub">
            Des articles sur le bien-être, la productivité et la vie d&apos;indépendant, écrits pour la réalité des entrepreneurs solo.
          </p>
        </div>

        <div className="wrap">
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
              gap: 24,
            }}
          >
            {articles.map((article) => (
              <Link
                key={article.slug}
                href={`/blog/${article.slug}`}
                className="card"
                style={{ display: "block", textDecoration: "none" }}
              >
                <span className="badge badge-violet">{article.category}</span>
                <h2
                  style={{
                    fontSize: 19,
                    fontWeight: 700,
                    color: "#fff",
                    letterSpacing: "-0.015em",
                    lineHeight: 1.3,
                    marginBottom: 10,
                  }}
                >
                  {article.title}
                </h2>
                <p
                  style={{
                    fontSize: 14.5,
                    color: "rgba(237,237,255,0.55)",
                    lineHeight: 1.65,
                    marginBottom: 18,
                  }}
                >
                  {article.description}
                </p>
                <span style={{ fontSize: 12.5, color: "#8B7FE8", fontWeight: 600 }}>
                  {article.readingTime} de lecture
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
