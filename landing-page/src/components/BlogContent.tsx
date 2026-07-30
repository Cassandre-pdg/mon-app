import type { BlogBlock } from "@/lib/blog";

export default function BlogContent({ blocks }: { blocks: BlogBlock[] }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
      {blocks.map((block, i) => {
        switch (block.type) {
          case "h2":
            return (
              <h2
                key={i}
                style={{
                  fontSize: "clamp(1.4rem, 3vw, 1.8rem)",
                  fontWeight: 700,
                  color: "#fff",
                  letterSpacing: "-0.02em",
                  lineHeight: 1.25,
                  marginTop: 12,
                }}
              >
                {block.text}
              </h2>
            );
          case "h3":
            return (
              <h3
                key={i}
                style={{
                  fontSize: "1.1rem",
                  fontWeight: 650,
                  color: "#EDEDFF",
                  letterSpacing: "-0.01em",
                  marginTop: 4,
                }}
              >
                {block.text}
              </h3>
            );
          case "p":
            return (
              <p
                key={i}
                style={{
                  fontSize: 16,
                  lineHeight: 1.78,
                  color: "rgba(237,237,255,0.72)",
                }}
              >
                {block.text}
              </p>
            );
          case "list":
            return (
              <ul
                key={i}
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: 10,
                  paddingLeft: 4,
                  listStyle: "none",
                }}
              >
                {block.items.map((item, j) => (
                  <li
                    key={j}
                    style={{
                      display: "flex",
                      gap: 10,
                      fontSize: 15.5,
                      lineHeight: 1.6,
                      color: "rgba(237,237,255,0.72)",
                    }}
                  >
                    <span style={{ color: "#8B7FE8", flexShrink: 0 }}>•</span>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            );
          case "quote":
            return (
              <blockquote
                key={i}
                style={{
                  borderLeft: "3px solid #6D28D9",
                  background: "rgba(109,40,217,0.08)",
                  borderRadius: "0 12px 12px 0",
                  padding: "16px 20px",
                  fontSize: 16,
                  fontStyle: "italic",
                  color: "#C4B5FD",
                  lineHeight: 1.6,
                  margin: 0,
                }}
              >
                {block.text}
              </blockquote>
            );
          default:
            return null;
        }
      })}
    </div>
  );
}
