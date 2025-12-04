import { useRef, useLayoutEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const HeroFake = () => {
    const containerRef = useRef<HTMLDivElement>(null);
    const contentRef = useRef<HTMLDivElement>(null);
    const svgPathRef = useRef<SVGPathElement>(null);
    const annotationRef = useRef<HTMLSpanElement>(null);
    const bottomTextRef = useRef<HTMLDivElement>(null);

    useLayoutEffect(() => {
        const ctx = gsap.context(() => {
            const tl = gsap.timeline({
                scrollTrigger: {
                    trigger: containerRef.current,
                    start: "top top",
                    end: "+=2000",
                    pin: true,
                    scrub: 1,
                }
            });

            // Action 1: Animate the SVG stroke
            if (svgPathRef.current) {
                const length = svgPathRef.current.getTotalLength();
                gsap.set(svgPathRef.current, { strokeDasharray: length, strokeDashoffset: length });
                tl.to(svgPathRef.current, {
                    strokeDashoffset: 0,
                    autoAlpha: 1,
                    duration: 2,
                    ease: "power1.inOut"
                });
            }

            // Action 2: Fade/Pop in the 'ou pas' text
            if (annotationRef.current) {
                tl.to(annotationRef.current, {
                    autoAlpha: 1,
                    scale: 1,
                    rotation: -10,
                    duration: 1,
                    ease: "back.out(1.7)"
                }, "-=1");
            }

            // Wait a bit
            tl.to({}, { duration: 1 });

            // Glitch / Exit effect
            if (contentRef.current) {
                tl.to(contentRef.current, {
                    opacity: 0,
                    scale: 1.1,
                    filter: "invert(1) hue-rotate(180deg)",
                    duration: 2,
                    ease: "power2.in"
                }, "exit");

                // Shake effect
                tl.to(contentRef.current, {
                    x: "random(-10, 10)",
                    duration: 0.1,
                    repeat: 20,
                    yoyo: true
                }, "exit");
            }

            if (bottomTextRef.current) {
                tl.to(bottomTextRef.current, {
                    opacity: 0,
                    duration: 1
                }, "exit");
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
                                />
                            </svg>
                        </span>.
                        <span
                            ref={annotationRef}
                            className="absolute top-0 left-full ml-6 text-4xl md:text-5xl text-[#ff0000] whitespace-nowrap opacity-0"
                            style={{ fontFamily: "'Permanent Marker', cursive", transform: 'rotate(-20deg) scale(0.5)' }}
                        >
                            ou pas
                        </span>
                    </h1>
                    <p className="text-2xl md:text-3xl font-light text-gray-500">
                        Plus rapide. Plus puissant. <span className="font-semibold text-blue-600">Windows 11.</span>
                    </p>
                </div>

                {/* Fake UI Elements to make it look corporate */}
                <div
                    ref={bottomTextRef}
                    className="absolute bottom-10 text-sm text-gray-400"
                >
                    Défilez pour découvrir l'expérience ultime.
                </div>
            </div>
        </div>
    );
};
