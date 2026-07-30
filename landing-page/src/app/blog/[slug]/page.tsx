import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import BlogContent from "@/components/BlogContent";
import { getAllArticles, getArticleBySlug } from "@/lib/blog";

export function generateStaticParams() {
  return getAllArticles().map((article) => ({ slug: article.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const article = getArticleBySlug(slug);
  if (!article) return {};

  return {
    title: `${article.title} · Blog kolyb`,
    description: article.description,
    alternates: {
      canonical: `/blog/${article.slug}`,
    },
    openGraph: {
      title: article.title,
      description: article.description,
      url: `/blog/${article.slug}`,
      type: "article",
      publishedTime: article.publishedAt,
    },
  };
}

export default async function BlogArticlePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const article = getArticleBySlug(slug);
  if (!article) notFound();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: article.title,
    description: article.description,
    datePublished: article.publishedAt,
    dateModified: article.publishedAt,
    author: {
      "@type": "Organization",
      name: "kolyb",
    },
    publisher: {
      "@type": "Organization",
      name: "kolyb",
      logo: {
        "@type": "ImageObject",
        url: "https://kolyb.app/kolyb_icon.png",
      },
    },
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": `https://kolyb.app/blog/${article.slug}`,
    },
  };

  return (
    <main className="min-h-screen bg-[#0D0B1E]">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Navbar />

      <article className="section" style={{ paddingTop: "clamp(120px, 16vw, 160px)" }}>
        <div className="wrap-md">
          <Link
            href="/blog"
            style={{
              fontSize: 13,
              fontWeight: 600,
              color: "#8B7FE8",
              textDecoration: "none",
              display: "inline-block",
              marginBottom: 28,
            }}
          >
            ← Tous les articles
          </Link>

          <span className="badge badge-violet">{article.category}</span>

          <h1
            style={{
              fontSize: "clamp(1.9rem, 5vw, 2.75rem)",
              fontWeight: 800,
              color: "#fff",
              letterSpacing: "-0.03em",
              lineHeight: 1.15,
              marginBottom: 18,
            }}
          >
            {article.title}
          </h1>

          <div
            style={{
              display: "flex",
              gap: 14,
              fontSize: 13,
              color: "rgba(237,237,255,0.4)",
              marginBottom: 44,
            }}
          >
            <time dateTime={article.publishedAt}>
              {new Date(article.publishedAt).toLocaleDateString("fr-FR", {
                day: "numeric",
                month: "long",
                year: "numeric",
              })}
            </time>
            <span>·</span>
            <span>{article.readingTime} de lecture</span>
          </div>

          <BlogContent blocks={article.content} />

          <div
            style={{
              marginTop: 56,
              padding: "28px 28px",
              borderRadius: 20,
              background: "linear-gradient(135deg, rgba(109,40,217,0.16) 0%, rgba(0,212,200,0.08) 100%)",
              border: "1px solid rgba(109,40,217,0.25)",
              textAlign: "center",
            }}
          >
            <p style={{ fontSize: 16, fontWeight: 600, color: "#fff", marginBottom: 8 }}>
              Envie d&apos;essayer kolyb ?
            </p>
            <p style={{ fontSize: 14, color: "rgba(237,237,255,0.55)", marginBottom: 20 }}>
              Check-in, planificateur et communauté, gratuit pour commencer.
            </p>
            <Link
              href={article.relatedFeatureHref ?? "/#hero"}
              className="btn btn-primary"
              style={{ margin: "0 auto" }}
            >
              {article.relatedFeatureLabel ?? "Découvrir kolyb"}
            </Link>
          </div>
        </div>
      </article>

      <Footer />
    </main>
  );
}
