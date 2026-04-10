import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Problem from "@/components/Problem";
import Features from "@/components/Features";
import HowItWorks from "@/components/HowItWorks";
import Benefits from "@/components/Benefits";
import FAQ from "@/components/FAQ";
import Contact from "@/components/Contact";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0D0B1E] overflow-x-hidden">
      <Navbar />
      <Hero />
      <Problem />
      <Features />
      <HowItWorks />
      <Benefits />
      <FAQ />
      <Contact />
      <Footer />
    </main>
  );
}
