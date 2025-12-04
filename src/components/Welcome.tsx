import React, { useEffect, useRef } from 'react';
import gsap from 'gsap';
import './Welcome.css';

export default function Welcome() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Animation d'apparition
    gsap.fromTo(
      containerRef.current,
      { scale: 0.8, opacity: 0 },
      { scale: 1, opacity: 1, duration: 1, ease: 'power3.out' }
    );
  }, []);

  return (
    <div ref={containerRef} className="welcome-message">
      <svg className="welcome-logo" viewBox="0 0 64 64" fill="none">
        <circle cx="32" cy="32" r="30" stroke="#ffd700" strokeWidth="4" fill="#222" />
        <text x="32" y="40" textAnchor="middle" fontSize="28" fill="#ffd700" fontFamily="Montserrat, Arial, sans-serif">N</text>
      </svg>
      <h1 className="welcome-title">NIRD</h1>
      <div className="slogan">Numérique Inclusif, Responsable et Durable</div>
      <div className="subtitle">
        C’est précisément l’ambition de la démarche NIRD :<br />
        permettre aux établissements scolaires d’adopter progressivement un Numérique Inclusif, Responsable et Durable,<br />
        en redonnant du pouvoir d’agir aux équipes éducatives et en renforçant leur autonomie technologique.
      </div>
      <div className="welcome-loader" />
    </div>
  );
}