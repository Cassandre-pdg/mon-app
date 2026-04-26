import Navbar from "@/components/Navbar";
import RocketHero from "@/components/RocketHero";
import MarqueeStrip from "@/components/MarqueeStrip";
import HorizontalShowcase from "@/components/HorizontalShowcase";
import ManifestoSection from "@/components/ManifestoSection";
import AnimatedStats from "@/components/AnimatedStats";
import HowItWorks from "@/components/HowItWorks";
import ImmersiveCTA from "@/components/ImmersiveCTA";
import Footer from "@/components/Footer";
import ScrollProgress from "@/components/ScrollProgress";

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0D0B1E] [overflow-x:clip]">
      <ScrollProgress />
      <Navbar />
      <RocketHero />
      <MarqueeStrip />
      <HorizontalShowcase />
      <ManifestoSection />
      <AnimatedStats />
      <HowItWorks />
      <ImmersiveCTA />
      <Footer />
    </main>
  );
}
