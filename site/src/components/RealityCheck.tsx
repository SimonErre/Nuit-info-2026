import { useRef, useLayoutEffect, useState } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ArrowRight } from 'lucide-react';

gsap.registerPlugin(ScrollTrigger);

const dataPoints = [
    { text: "14 Octobre 2025", color: "#ff3333", glow: "rgba(255, 51, 51, 0.8)", top: -25, left: 28, size: "clamp(10rem, 6vw, 5rem)" },
    { text: "Windows 10 meurt.", color: "#ffffff", glow: "rgba(255, 255, 255, 0.5)", top: 8, left: -1, size: "clamp(20rem, 8vw, 7rem)" },
    { text: "240 Millions de PC...", color: "#ff9500", glow: "rgba(255, 149, 0, 0.8)", top: -35, left: -15, size: "clamp(8rem, 7vw, 6rem)" },
    { text: "...bons pour la casse.", color: "#ffcc00", glow: "rgba(255, 204, 0, 0.8)", top: 25, left: 12, size: "clamp(2rem, 5vw, 4.5rem)" },
    { text: "480 Millions de kg de CO2", color: "#ff0000", glow: "rgba(255, 0, 0, 0.9)", top: -15, left: -15, size: "clamp(8rem, 6vw, 5.5rem)" },
    { text: "48 Tours Eiffel.", color: "#ffaa00", glow: "rgba(255, 170, 0, 0.8)", top: 38, left: -18, size: "clamp(10rem, 7vw, 6rem)" },
    { text: "Pour une mise à jour.", color: "#ff4466", glow: "rgba(255, 68, 102, 0.8)", top: 10, left: -10, size: "clamp(7rem, 5vw, 4.5rem)" },
    { text: "OBSOLESCENCE.", color: "#ff2222", glow: "rgba(255, 34, 34, 0.9)", top: 40, left: 1, size: "clamp(3.5rem, 9vw, 8rem)" },
    { text: "Déchets électroniques.", color: "#ffffff", glow: "rgba(255, 255, 255, 0.5)", top: -30, left: 20, size: "clamp(4rem, 6vw, 5rem)" },
    { text: "Sécurité compromise.", color: "#ff5555", glow: "rgba(255, 85, 85, 0.8)", top: 20, left: -25, size: "clamp(3rem, 6vw, 4rem)" },
    { text: "Inégalité numérique.", color: "#ff8800", glow: "rgba(255, 136, 0, 0.8)", top: 20, left: 25, size: "clamp(8rem, 5vw, 4rem)" },
    { text: "Pollution accrue.", color: "#ff0000", glow: "rgba(255, 0, 0, 0.9)", top: -40, left: -50, size: "clamp(8rem, 7vw, 6rem)" },
];

export const RealityCheck = () => {
    const [showIframe, setShowIframe] = useState(false);
    // Empêche le scroll quand l'iframe est affiché
    useLayoutEffect(() => {
        if (showIframe) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
        return () => {
            document.body.style.overflow = '';
        };
    }, [showIframe]);
    const containerRef = useRef<HTMLDivElement>(null);
    const textsRef = useRef<(HTMLDivElement | null)[]>([]);
    const ctaRef = useRef<HTMLDivElement>(null);

    useLayoutEffect(() => {
        const ctx = gsap.context(() => {
            const tl = gsap.timeline({
                scrollTrigger: {
                    trigger: containerRef.current,
                    start: "top top",
                    end: "+=5000", // Long scroll for drama
                    pin: true,
                    scrub: 1,
                }
            });

            // 1. Chaos Accumulation
            dataPoints.forEach((_, index) => {
                const textEl = textsRef.current[index];
                if (!textEl) return;

                // Randomize entrance slightly
                const randomX = (Math.random() - 0.5) * 30;
                const randomY = (Math.random() - 0.5) * 30;

                tl.fromTo(textEl,
                    { opacity: 0, scale: 0, x: randomX, y: randomY },
                    { opacity: 1, scale: 1, x: 0, y: 0, duration: 1, ease: "power2.out" },
                    index * 0.5 // Stagger overlap
                );
            });

            // Hold the chaos for a moment
            tl.to({}, { duration: 2 });

            // 2. The Clearing Effect (Exit Chaos)
            tl.to(textsRef.current, {
                opacity: 0,
                y: -100,
                filter: "blur(10px)",
                scale: 0.5,
                duration: 2,
                stagger: {
                    amount: 1,
                    from: "random"
                },
                ease: "power2.in"
            }, "clearing");

            // 3. Background Shift
            tl.to(containerRef.current, {
                backgroundColor: "#022c22", // Dark Forest Green
                duration: 3,
                ease: "power2.inOut"
            }, "clearing");

            // 4. The Reveal (CTA)
            if (ctaRef.current) {
                tl.fromTo(ctaRef.current,
                    { opacity: 0, scale: 0.9, y: 50 },
                    { opacity: 1, scale: 1, y: 0, duration: 2, ease: "power2.out" },
                    "-=1.5" // Overlap with clearing
                );
            }

        }, containerRef);

        return () => ctx.revert();
    }, []);

    return (
        <div ref={containerRef} className="h-screen w-full bg-black relative overflow-hidden flex items-center justify-center">
            {/* Chaos Layer */}
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                {dataPoints.map((item, index) => {
                    return (
                        <div
                            key={index}
                            ref={el => { textsRef.current[index] = el; }}
                            className="absolute text-center font-black tracking-tighter uppercase"
                            style={{
                                top: `calc(50% + ${item.top}%)`,
                                left: `calc(50% + ${item.left}%)`,
                                transform: 'translate(-50%, -50%)',
                                fontSize: item.size,
                                lineHeight: 1,
                                color: item.color,
                                textShadow: `0 0 15px ${item.glow}, 0 0 40px ${item.glow}, 0 0 80px ${item.glow}, 0 4px 8px rgba(0,0,0,0.9)`,
                                WebkitTextStroke: '2px rgba(0,0,0,0.5)',
                                opacity: 0, // Initial state handled by GSAP
                                willChange: 'transform, opacity, filter'
                            }}
                        >
                            {item.text}
                        </div>
                    );
                })}
            </div>

            {/* Solution / CTA Layer */}
            <div ref={ctaRef} className="relative z-20 text-center px-6 max-w-4xl opacity-0" style={{ willChange: 'transform, opacity' }}>
                <h2 className="text-4xl md:text-6xl font-bold text-white mb-8">
                    Arrêtez le massacre.
                </h2>
                <p className="text-xl md:text-2xl text-gray-300 mb-12 font-light">
                    Passez à un monde meilleur avec <span className="text-green-400 font-semibold">NIRD</span>.
                </p>

                <button
                    className="group relative inline-flex items-center gap-3 px-8 py-4 bg-white text-black rounded-full text-lg font-bold tracking-wide overflow-hidden transition-all hover:bg-green-400 hover:scale-105 active:scale-95"
                    onClick={() => setShowIframe(true)}
                >
                    <span className="relative z-10">REJOINDRE LE MOUVEMENT</span>
                    <ArrowRight className="w-5 h-5 relative z-10 group-hover:translate-x-1 transition-transform" />
                    <div className="absolute inset-0 bg-green-400 opacity-0 group-hover:opacity-20 transition-opacity blur-lg" />
                </button>
            </div>

            {/* Iframe du jeu Godot */}
            {showIframe && (
                <div className="fixed inset-0 z-50 bg-black bg-opacity-90">
                    <iframe
                        src="/game/maya.html"
                        title="Jeu Godot"
                        className="absolute top-0 left-0 w-screen h-screen"
                        style={{ border: 'none', margin: 0, padding: 0 }}
                        allowFullScreen
                    />
                    <button
                        className="absolute top-4 right-4 px-6 py-3 bg-green-400 text-black rounded-full font-bold z-50"
                        onClick={() => setShowIframe(false)}
                    >
                        Fermer
                    </button>
                </div>
            )}
        </div>
    );
};
