import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import type { BlogArticle } from "@/lib/blog";

const APP_STORE_URL =
  "https://apps.apple.com/fr/app/kolyb-productivit%C3%A9-r%C3%A9seau/id6763140978";

export interface FeatureFaq {
  q: string;
  a: string;
}

export default function FeaturePageLayout({
  color,
  emoji,
  badgeLabel,
  h1,
  subtitle,
  problemParagraphs,
  details,
  faqs,
  relatedArticles,
}: {
  color: string;
  emoji: string;
  badgeLabel: string;
  h1: string;
  subtitle: string;
  problemParagraphs: string[];
  details: string[];
  faqs: FeatureFaq[];
  relatedArticles: BlogArticle[];
}) {
  const faqJsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: { "@type": "Answer", text: faq.a },
    })),
  };

  return (
    <main className="min-h-screen bg-[#0D0B1E]">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
      <Navbar />

      {/* Hero */}
      <section className="section" style={{ paddingTop: "clamp(120px, 16vw, 160px)", paddingBottom: 40 }}>
        <div className="wrap-md" style={{ textAlign: "center" }}>
          <div style={{ fontSize: 52, marginBottom: 20 }}>{emoji}</div>
          <span
            className="badge"
            style={{
              background: `${color}18`,
              color,
              border: `1px solid ${color}30`,
              fontSize: 11,
              letterSpacing: "0.08em",
              textTransform: "uppercase",
              fontWeight: 600,
            }}
          >
            {badgeLabel}
          </span>
          <h1
            style={{
              fontSize: "clamp(2rem, 5vw, 3rem)",
              fontWeight: 800,
              color: "#fff",
              letterSpacing: "-0.03em",
              lineHeight: 1.12,
              margin: "16px 0 18px",
            }}
          >
            {h1}
          </h1>
          <p
            style={{
              fontSize: 17,
              color: "rgba(237,237,255,0.6)",
              lineHeight: 1.7,
              maxWidth: 560,
              margin: "0 auto 32px",
            }}
          >
            {subtitle}
          </p>
          <a
            href={APP_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-primary"
            style={{ margin: "0 auto" }}
          >
            Télécharger sur l&apos;App Store
          </a>
        </div>
      </section>

      {/* Problem */}
      <section className="section" style={{ paddingTop: 24, paddingBottom: 24 }}>
        <div className="wrap-md" style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          {problemParagraphs.map((p, i) => (
            <p key={i} style={{ fontSize: 16, lineHeight: 1.78, color: "rgba(237,237,255,0.72)" }}>
              {p}
            </p>
          ))}
        </div>
      </section>

      {/* Details */}
      <section className="section" style={{ paddingTop: 24 }}>
        <div className="wrap-md">
          <div className="card" style={{ padding: 36 }}>
            <p
              style={{
                fontSize: 12,
                fontWeight: 600,
                letterSpacing: "0.08em",
                textTransform: "uppercase",
                color,
                marginBottom: 20,
              }}
            >
              Ce que ça change concrètement
            </p>
            <ul style={{ display: "flex", flexDirection: "column", gap: 16 }}>
              {details.map((d) => (
                <li key={d} style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
                  <span
                    style={{
                      width: 22,
                      height: 22,
                      borderRadius: "50%",
                      background: `${color}20`,
                      color,
                      flexShrink: 0,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 12,
                      fontWeight: 700,
                      marginTop: 1,
                    }}
                  >
                    ✓
                  </span>
                  <span style={{ fontSize: 15, color: "rgba(237,237,255,0.8)", lineHeight: 1.6 }}>{d}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Mini FAQ */}
      <section className="section" style={{ paddingTop: 40 }}>
        <div className="wrap-md">
          <p className="eyebrow" style={{ textAlign: "center" }}>
            Questions fréquentes
          </p>
          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginTop: 8 }}>
            {faqs.map((faq) => (
              <div
                key={faq.q}
                style={{
                  background: "rgba(26,24,54,0.5)",
                  border: "1px solid #22204A",
                  borderRadius: 16,
                  padding: "20px 24px",
                }}
              >
                <p style={{ fontSize: 15, fontWeight: 600, color: "#fff", marginBottom: 8 }}>{faq.q}</p>
                <p style={{ fontSize: 14, color: "rgba(237,237,255,0.6)", lineHeight: 1.65 }}>{faq.a}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Related articles */}
      {relatedArticles.length > 0 && (
        <section className="section" style={{ paddingTop: 24 }}>
          <div className="wrap-md">
            <p className="eyebrow" style={{ textAlign: "center" }}>
              Pour aller plus loin
            </p>
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
                gap: 16,
                marginTop: 8,
              }}
            >
              {relatedArticles.map((article) => (
                <Link
                  key={article.slug}
                  href={`/blog/${article.slug}`}
                  className="card"
                  style={{ display: "block", textDecoration: "none" }}
                >
                  <p style={{ fontSize: 15, fontWeight: 700, color: "#fff", marginBottom: 8, lineHeight: 1.35 }}>
                    {article.title}
                  </p>
                  <p style={{ fontSize: 13, color: "rgba(237,237,255,0.5)", lineHeight: 1.55 }}>
                    {article.description}
                  </p>
                </Link>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* Final CTA */}
      <section className="section">
        <div className="wrap-md">
          <div
            style={{
              padding: "36px 32px",
              borderRadius: 20,
              background: "linear-gradient(135deg, rgba(109,40,217,0.16) 0%, rgba(0,212,200,0.08) 100%)",
              border: "1px solid rgba(109,40,217,0.25)",
              textAlign: "center",
            }}
          >
            <p style={{ fontSize: 19, fontWeight: 700, color: "#fff", marginBottom: 8 }}>
              Prêt·e à essayer ?
            </p>
            <p style={{ fontSize: 14, color: "rgba(237,237,255,0.55)", marginBottom: 24 }}>
              Gratuit pour commencer, sans carte bancaire.
            </p>
            <a
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary"
              style={{ margin: "0 auto" }}
            >
              Télécharger sur l&apos;App Store
            </a>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
