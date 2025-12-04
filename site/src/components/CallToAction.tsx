import { motion } from 'framer-motion';
import { ArrowRight } from 'lucide-react';

export const CallToAction = () => {
    return (
        <div className="h-screen bg-black flex flex-col items-center justify-center relative overflow-hidden">
            {/* Subtle Gradient Background */}
            <div className="absolute inset-0 bg-gradient-to-b from-black via-black to-green-900/20 pointer-events-none" />

            <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                transition={{ duration: 1.5 }}
                className="z-10 text-center px-6 max-w-4xl"
            >
                <h2 className="text-4xl md:text-6xl font-bold text-white mb-8">
                    Arrêtez le massacre.
                </h2>
                <p className="text-xl md:text-2xl text-gray-300 mb-12 font-light">
                    Passez à un monde meilleur avec <span className="text-green-400 font-semibold">NIRD</span>.
                </p>

                <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className="group relative inline-flex items-center gap-3 px-8 py-4 bg-white text-black rounded-full text-lg font-bold tracking-wide overflow-hidden transition-all hover:bg-green-400"
                >
                    <span className="relative z-10">REJOINDRE LE MOUVEMENT</span>
                    <ArrowRight className="w-5 h-5 relative z-10 group-hover:translate-x-1 transition-transform" />

                    {/* Button Glow Effect */}
                    <div className="absolute inset-0 bg-green-400 opacity-0 group-hover:opacity-20 transition-opacity blur-lg" />
                </motion.button>
            </motion.div>
        </div>
    );
};
