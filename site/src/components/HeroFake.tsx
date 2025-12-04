import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, useLayoutEffect } from 'react';
import gsap from 'gsap';

export const HeroFake = () => {
    const containerRef = useRef<HTMLDivElement>(null);
    const svgPathRef = useRef<SVGPathElement>(null);
    const annotationRef = useRef<HTMLSpanElement>(null);

    const { scrollYProgress } = useScroll({
        target: containerRef,
        offset: ["start start", "end start"]
    });

    // Glitch effect values
    const opacity = useTransform(scrollYProgress, [0.8, 0.9], [1, 0]);
    const scale = useTransform(scrollYProgress, [0.8, 0.9], [1, 1.1]);
    const x = useTransform(scrollYProgress, [0.8, 0.82, 0.84, 0.86, 0.88, 0.9], [0, -10, 10, -10, 10, 0]);
    const filter = useTransform(scrollYProgress, [0.8, 0.9], ["none", "invert(1) hue-rotate(180deg)"]);

    useLayoutEffect(() => {
        const ctx = gsap.context(() => {
            const tl = gsap.timeline({ delay: 1.5 });

            // Action 1: Animate the SVG stroke
            if (svgPathRef.current) {
                const length = svgPathRef.current.getTotalLength();
                gsap.set(svgPathRef.current, { strokeDasharray: length, strokeDashoffset: length });
                tl.to(svgPathRef.current, {
                    strokeDashoffset: 0,
                    autoAlpha: 1,
                    duration: 0.4,
                    ease: "power1.inOut"
                });
            }

            // Action 2: Fade/Pop in the 'ou pas' text
            if (annotationRef.current) {
                tl.fromTo(annotationRef.current,
                    { opacity: 0, scale: 0.5, rotation: -20 },
                    { opacity: 1, scale: 1, rotation: -10, duration: 0.3, ease: "back.out(1.7)" },
                    "-=0.1"
                );
            }

        }, containerRef);

        return () => ctx.revert();
    }, []);

    return (
        <div ref={containerRef} className="h-[200vh] relative bg-white text-apple-text">
            <div className="sticky top-0 h-screen flex flex-col items-center justify-center overflow-hidden">
                <motion.div
                    style={{ opacity, scale, x, filter }}
                    className="text-center z-10 px-4"
                >
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                        className="text-6xl md:text-8xl font-bold tracking-tighter mb-6 relative inline-block"
                    >
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
                            className="absolute top-0 left-full ml-6 text-4xl md:text-5xl text-[#ff0000] whitespace-nowrap"
                            style={{ fontFamily: "'Permanent Marker', cursive", transform: 'rotate(-10deg)' }}
                        >
                            ou pas
                        </span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
                        className="text-2xl md:text-3xl font-light text-gray-500"
                    >
                        Plus rapide. Plus puissant. <span className="font-semibold text-blue-600">Windows 11.</span>
                    </motion.p>
                </motion.div>

                {/* Fake UI Elements to make it look corporate */}
                <motion.div
                    style={{ opacity }}
                    className="absolute bottom-10 text-sm text-gray-400"
                >
                    Défilez pour découvrir l'expérience ultime.
                </motion.div>
            </div>
        </div>
    );
};
