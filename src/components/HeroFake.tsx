import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';

export const HeroFake = () => {
    const containerRef = useRef<HTMLDivElement>(null);
    const { scrollYProgress } = useScroll({
        target: containerRef,
        offset: ["start start", "end start"]
    });

    // Glitch effect values
    const opacity = useTransform(scrollYProgress, [0.8, 0.9], [1, 0]);
    const scale = useTransform(scrollYProgress, [0.8, 0.9], [1, 1.1]);
    const x = useTransform(scrollYProgress, [0.8, 0.82, 0.84, 0.86, 0.88, 0.9], [0, -10, 10, -10, 10, 0]);
    const filter = useTransform(scrollYProgress, [0.8, 0.9], ["none", "invert(1) hue-rotate(180deg)"]);

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
                        className="text-6xl md:text-8xl font-bold tracking-tighter mb-6"
                    >
                        Le Futur est là.
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
