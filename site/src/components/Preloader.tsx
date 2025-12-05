import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

export const Preloader = ({ onComplete }: { onComplete: () => void }) => {
    const [progress, setProgress] = useState(0);
    const [text, setText] = useState("INITIALIZING SYSTEM...");

    useEffect(() => {
        const minDuration = 2000;
        const startTime = Date.now();

        const updateProgress = () => {
            const elapsed = Date.now() - startTime;
            const calculatedProgress = Math.min(100, Math.floor((elapsed / minDuration) * 100));

            setProgress(calculatedProgress);

            if (calculatedProgress < 30) setText("MOUNTING VOLUMES...");
            else if (calculatedProgress < 60) setText("LOADING ASSETS...");
            else if (calculatedProgress < 90) setText("CALIBRATING OPTICS...");
            else setText("SYSTEM READY.");

            if (elapsed < minDuration) {
                requestAnimationFrame(updateProgress);
            } else {
                // Ensure fonts are ready before finishing
                document.fonts.ready.then(() => {
                    setProgress(100);
                    setTimeout(onComplete, 500);
                });
            }
        };

        requestAnimationFrame(updateProgress);
    }, [onComplete]);

    return (
        <div className="fixed inset-0 bg-black z-50 flex flex-col items-center justify-center font-mono text-green-500">
            <div className="w-80">
                <div className="mb-2 flex justify-between text-sm">
                    <span>{text}</span>
                    <span>{progress}%</span>
                </div>
                <div className="h-1 w-full bg-green-900/30">
                    <motion.div
                        className="h-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]"
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        transition={{ ease: "linear", duration: 0.1 }}
                    />
                </div>
                <div className="mt-2 text-xs text-green-700/80 animate-pulse">
                    _
                </div>
            </div>
        </div>
    );
};
