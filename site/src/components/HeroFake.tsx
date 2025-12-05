import { useRef, useLayoutEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const HeroFake = () => {
    const containerRef = useRef<HTMLDivElement>(null);
    const contentRef = useRef<HTMLDivElement>(null);
    const svgPathRef = useRef<SVGPathElement>(null);
    const annotationRef = useRef<HTMLSpanElement>(null);
    const svgPathRef2 = useRef<SVGPathElement>(null);
    const annotationRef2 = useRef<HTMLSpanElement>(null);
    const bottomTextRef = useRef<HTMLDivElement>(null);
    const noiseRef = useRef<HTMLDivElement>(null);

    useLayoutEffect(() => {
        const ctx = gsap.context(() => {
            const tl = gsap.timeline({
                scrollTrigger: {
                    trigger: containerRef.current,
                    start: "top top",
                    end: "+=3000", // Increased scroll distance for better pacing
                    pin: true,
                    scrub: 1,
                }
            });

            // --- VANDALISM 1: "est là" -> "ou pas" ---
            if (svgPathRef.current) {
                const length = svgPathRef.current.getTotalLength();
                gsap.set(svgPathRef.current, { strokeDasharray: length, strokeDashoffset: length });
                tl.to(svgPathRef.current, {
                    strokeDashoffset: 0,
                    autoAlpha: 1,
                    duration: 1,
                    ease: "power1.inOut"
                });
            }

            if (annotationRef.current) {
                tl.to(annotationRef.current, {
                    autoAlpha: 1,
                    scale: 1,
                    rotation: -10,
                    duration: 0.5,
                    ease: "back.out(1.7)"
                }, "-=0.5");
            }

            // Small pause
            tl.to({}, { duration: 0.5 });

            // --- VANDALISM 2: "Windows 11" -> "L'Obsolescence" ---
            if (svgPathRef2.current) {
                const length = svgPathRef2.current.getTotalLength();
                gsap.set(svgPathRef2.current, { strokeDasharray: length, strokeDashoffset: length });
                tl.to(svgPathRef2.current, {
                    strokeDashoffset: 0,
                    autoAlpha: 1,
                    duration: 1,
                    ease: "rough({ template: none.out, strength: 1, points: 20, taper: 'none', randomize: true, clamp: false})"
                });
            }

            if (annotationRef2.current) {
                tl.to(annotationRef2.current, {
                    autoAlpha: 1,
                    scale: 1,
                    rotation: 5,
                    duration: 0.5,
                    ease: "elastic.out(1, 0.3)"
                }, "-=0.5");
            }

            // Small pause before chaos
            tl.to({}, { duration: 1 });

            // --- EXIT: System Failure (White -> Black) ---
            tl.addLabel("systemFailure");

            // 1. Darken Background
            tl.to(containerRef.current, {
                backgroundColor: "#000000",
                duration: 3,
                ease: "power2.inOut"
            }, "systemFailure");

            // 2. Invert Text Colors to stay visible
            if (contentRef.current) {
                // Animate main text color
                tl.to(contentRef.current.querySelectorAll("h1, p"), {
                    color: "#ffffff",
                    duration: 3,
                    ease: "power2.inOut"
                }, "systemFailure");

                // Keep the blue text blue or make it pop
                tl.to(contentRef.current.querySelector(".text-blue-600"), {
                    color: "#3b82f6", // Keep it blue or change to something else
                    duration: 3
                }, "systemFailure");

                // Glitch/Shake effect (kept but modified)
                tl.to(contentRef.current, {
                    scale: 1.05,
                    filter: "blur(2px)",
                    duration: 3,
                    ease: "power2.in"
                }, "systemFailure");

                tl.to(contentRef.current, {
                    x: "random(-5, 5)",
                    y: "random(-5, 5)",
                    duration: 0.1,
                    repeat: 30,
                    yoyo: true
                }, "systemFailure");
            }

            // 3. Fade in Noise Overlay
            if (noiseRef.current) {
                tl.to(noiseRef.current, {
                    opacity: 0.3,
                    duration: 3,
                    ease: "power2.in"
                }, "systemFailure");
            }

            if (bottomTextRef.current) {
                tl.to(bottomTextRef.current, {
                    opacity: 0,
                    duration: 1
                }, "systemFailure");
            }

        }, containerRef);

        return () => ctx.revert();
    }, []);

    return (
        <div ref={containerRef} className="h-screen relative bg-white text-apple-text overflow-hidden">
            <div className="h-full flex flex-col items-center justify-center">
                <div
                    ref={contentRef}
                    className="text-center z-10 px-4"
                    style={{ willChange: 'transform, opacity, filter' }}
                >
                    <h1 className="text-6xl md:text-8xl font-bold tracking-tighter mb-6 relative inline-block">
                        Le Futur <span className="relative inline-block">
                            est là
                            <svg
                                className="absolute top-1/2 left-0 w-[110%] h-[150%] pointer-events-none overflow-visible"
                                style={{ transform: 'translate(-5%, -50%)' }}
                                viewBox="0 0 100 40"
                                preserveAspectRatio="none"
                            >
                                <path
                                    ref={svgPathRef}
                                    d="M-5,25 C20,10 50,30 105,15"
                                    fill="none"
                                    stroke="#ff0000"
                                    strokeWidth="4"
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    className="opacity-0"
                                    style={{ willChange: 'stroke-dashoffset, opacity' }}
                                />
                            </svg>
                        </span>.
                        <span
                            ref={annotationRef}
                            className="absolute top-0 left-full ml-6 text-4xl md:text-5xl text-[#ff0000] whitespace-nowrap opacity-0"
                            style={{
                                fontFamily: "'Permanent Marker', cursive",
                                transform: 'rotate(-20deg) scale(0.5)',
                                willChange: 'transform, opacity'
                            }}
                        >
                            ou pas
                        </span>
                    </h1>
                    <p className="text-2xl md:text-3xl font-light text-gray-500 mt-4">
                        Plus rapide. Plus puissant.
                        <span className="relative inline-block ml-2">
                            <span className="font-semibold text-blue-600">Windows 11.</span>
                            <svg
                                className="absolute top-1/2 left-0 w-[120%] h-[180%] pointer-events-none overflow-visible"
                                style={{ transform: 'translate(-10%, -50%)' }}
                                viewBox="0 0 150 60"
                                preserveAspectRatio="none"
                            >
                                <path
                                    ref={svgPathRef2}
                                    d="M0,30 L150,20 M10,40 L140,10"
                                    fill="none"
                                    stroke="#ff0000"
                                    strokeWidth="5"
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    className="opacity-0"
                                    style={{ willChange: 'stroke-dashoffset, opacity' }}
                                />
                            </svg>
                            <span
                                ref={annotationRef2}
                                className="absolute top-full left-1/2 -translate-x-1/2 mt-2 text-5xl md:text-6xl text-[#ff0000] whitespace-nowrap opacity-0 z-20"
                                style={{
                                    fontFamily: "'Permanent Marker', cursive",
                                    transform: 'rotate(5deg) scale(0.5) translateX(-50%)',
                                    textShadow: '2px 2px 0px rgba(0,0,0,0.1)',
                                    willChange: 'transform, opacity'
                                }}
                            >
                                L'Obsolescence
                            </span>
                        </span>
                    </p>
                </div>

                {/* Fake UI Elements to make it look corporate */}
                <div
                    ref={bottomTextRef}
                    className="absolute bottom-10 text-sm text-gray-400"
                >
                    Défilez pour découvrir l'expérience ultime.
                </div>

                {/* Noise Overlay */}
                <div
                    ref={noiseRef}
                    className="absolute inset-0 pointer-events-none opacity-0 z-50 mix-blend-overlay"
                    style={{
                        backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='1'/%3E%3C/svg%3E")`,
                        backgroundSize: '100px 100px'
                    }}
                />
            </div>
        </div>
    );
};
