import { useRef, useLayoutEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ArrowRight } from 'lucide-react';

gsap.registerPlugin(ScrollTrigger);

const dataPoints = [
    "14 Octobre 2025",
    "Windows 10 meurt.",
    "240 Millions de PC...",
    "...bons pour la casse.",
    "480 Millions de kg de déchets.",
    "L'équivalent de 48 Tours Eiffel.",
    "Tout ça pour une mise à jour.",
    "N'acceptez pas l'obsolescence."
];

export const RealityCheck = () => {
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
                const randomX = (Math.random() - 0.5) * 50;
                const randomY = (Math.random() - 0.5) * 50;

                tl.fromTo(textEl,
                    { opacity: 0, scale: 0, x: randomX, y: randomY },
                    { opacity: 1, scale: 1 + (index * 0.2), x: 0, y: 0, duration: 1, ease: "power2.out" },
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
                {dataPoints.map((text, index) => {
                    // Deterministic random positions for layout
                    const randomTop = ((index * 37) % 60) - 30;
                    const randomLeft = ((index * 23) % 60) - 30;
                    const isRed = index % 3 === 0;

                    return (
                        <div
                            key={index}
                            ref={el => { textsRef.current[index] = el; }}
                            className={`absolute text-center font-black tracking-tighter uppercase ${isRed ? 'text-red-600' : 'text-white'}`}
                            style={{
                                top: `calc(50% + ${randomTop}%)`,
                                left: `calc(50% + ${randomLeft}%)`,
                                transform: 'translate(-50%, -50%)',
                                fontSize: 'clamp(2rem, 5vw, 5rem)',
                                lineHeight: 0.9,
                                textShadow: isRed ? '0 0 20px rgba(220, 38, 38, 0.5)' : '0 0 10px rgba(255,255,255,0.3)',
                                opacity: 0 // Initial state handled by GSAP
                            }}
                        >
                            {text}
                        </div>
                    );
                })}
            </div>

            {/* Solution / CTA Layer */}
            <div ref={ctaRef} className="relative z-20 text-center px-6 max-w-4xl opacity-0">
                <h2 className="text-4xl md:text-6xl font-bold text-white mb-8">
                    Arrêtez le massacre.
                </h2>
                <p className="text-xl md:text-2xl text-gray-300 mb-12 font-light">
                    Passez à un monde meilleur avec <span className="text-green-400 font-semibold">NIRD</span>.
                </p>

                <button
                    className="group relative inline-flex items-center gap-3 px-8 py-4 bg-white text-black rounded-full text-lg font-bold tracking-wide overflow-hidden transition-all hover:bg-green-400 hover:scale-105 active:scale-95"
                >
                    <span className="relative z-10">REJOINDRE LE MOUVEMENT</span>
                    <ArrowRight className="w-5 h-5 relative z-10 group-hover:translate-x-1 transition-transform" />
                    <div className="absolute inset-0 bg-green-400 opacity-0 group-hover:opacity-20 transition-opacity blur-lg" />
                </button>
            </div>
        </div>
    );
};
