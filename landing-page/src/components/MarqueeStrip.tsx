const ITEMS = [
  "Progression visible",
  "Score quotidien",
  "Check-in mental",
  "Suivi du niveau",
  "Salon Communauté",
  "Clarté mentale",
  "Routine intelligente",
  "Système de discipline",
  "Focus extrême",
  "Environnement adaptatif",
];

export default function MarqueeStrip() {
  const repeated = [...ITEMS, ...ITEMS, ...ITEMS];
  return (
    <div className="marquee-wrapper" aria-hidden="true">
      <div className="marquee-track">
        {repeated.map((item, i) => (
          <span key={i} className="marquee-item">
            {item}
            <span className="marquee-dot">✦</span>
          </span>
        ))}
      </div>
    </div>
  );
}
