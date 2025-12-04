import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';

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
    const { scrollYProgress } = useScroll({
        target: containerRef,
        offset: ["start start", "end end"]
    });

    return (
        <div ref={containerRef} className="h-[500vh] bg-black relative">
            <div className="sticky top-0 h-screen w-full overflow-hidden flex items-center justify-center">
                {dataPoints.map((text, index) => (
                    <TextItem
                        key={index}
                        text={text}
                        index={index}
                        total={dataPoints.length}
                        progress={scrollYProgress}
                    />
                ))}
            </div>
        </div>
    );
};

const TextItem = ({ text, index, total, progress }: { text: string, index: number, total: number, progress: any }) => {
    // Calculate trigger points
    // We want them to appear one by one as we scroll down.
    // Total scroll distance is 1 (0 to 1).
    // We have 'total' items.
    // Item i appears at i / total.

    const step = 1 / total;
    const start = index * step;

    // Opacity: 0 -> 1 at 'start', then STAYS at 1.
    // We use a small buffer for the fade-in (e.g., 10% of the step).
    const fadeInEnd = start + (step * 0.5);

    const opacity = useTransform(
        progress,
        [start, fadeInEnd],
        [0, 1]
    );

    // Scale: Starts small/normal and grows HUGE to be oppressive
    // It grows from the moment it appears until the VERY END of the section.
    const scale = useTransform(
        progress,
        [start, 1],
        [0.5, 3 + (index * 0.5)] // Later items grow even bigger or differently
    );

    // Random positioning logic (deterministic based on index)
    // We use useMemo to keep it stable, but since this component is re-rendered by parent map, 
    // and index is stable, we can just calculate it.
    // However, to be safe and "React-y", we can just compute it.

    // Pseudo-random based on index
    const randomTop = ((index * 37) % 80) - 40; // -40% to +40%
    const randomLeft = ((index * 23) % 80) - 40; // -40% to +40%
    const isRed = index % 3 === 0; // Every 3rd item is red

    return (
        <motion.div
            style={{
                opacity,
                scale,
                top: `calc(50% + ${randomTop}%)`,
                left: `calc(50% + ${randomLeft}%)`,
                x: "-50%",
                y: "-50%"
            }}
            className="absolute w-max max-w-[80vw] text-center z-10 pointer-events-none"
        >
            <h2
                className={`font-black tracking-tighter uppercase ${isRed ? 'text-red-600' : 'text-white'}`}
                style={{
                    fontSize: 'clamp(2rem, 6vw, 6rem)',
                    lineHeight: 0.9,
                    textShadow: isRed ? '0 0 20px rgba(220, 38, 38, 0.5)' : '0 0 10px rgba(255,255,255,0.3)'
                }}
            >
                {text}
            </h2>
        </motion.div>
    );
};
