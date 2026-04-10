import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Problem from "@/components/Problem";
import Features from "@/components/Features";
import HowItWorks from "@/components/HowItWorks";
import Benefits from "@/components/Benefits";
import FAQ from "@/components/FAQ";
import Contact from "@/components/Contact";
import Footer from "@/components/Footer";

function Divider() {
  return (
    <div className="w-full px-8">
      <div className="max-w-6xl mx-auto h-px bg-gradient-to-r from-transparent via-[#22204A] to-transparent" />
    </div>
  );
}

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0D0B1E] overflow-x-hidden">
      <Navbar />
      <Hero />
      <Divider />
      <Problem />
      <Divider />
      <Features />
      <Divider />
      <HowItWorks />
      <Divider />
      <Benefits />
      <Divider />
      <FAQ />
      <Divider />
      <Contact />
      <Footer />
    </main>
  );
}
