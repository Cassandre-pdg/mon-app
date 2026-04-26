import type { Metadata } from "next";
import AuditQuiz from "@/components/AuditQuiz";

export const metadata: Metadata = {
  title: "Audit de productivité · Kolyb",
  description:
    "Mesure ta productivité réelle en 2 minutes. Découvre ton profil psychoproductif et les blocages invisibles qui te freinent.",
  openGraph: {
    title: "Quel est ton vrai niveau de productivité ?",
    description:
      "9 questions · Résultats personnalisés · 100% gratuit. Découvre ton profil et les blocages qui te coûtent des heures.",
    type: "website",
  },
};

export default function AuditPage() {
  return <AuditQuiz />;
}
