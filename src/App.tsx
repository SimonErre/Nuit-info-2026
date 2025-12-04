import './App.css'
import Welcome from './components/Welcome'
import React, { useEffect, useState } from 'react';

const cardsData = [
  {
    title: 'Obsolescence programmée',
    description: 'Jeter des ordinateurs fonctionnels à cause de mises à jour propriétaires.'
  },
  {
    title: 'Dépendance aux GAFAM',
    description: 'Utiliser uniquement des solutions fermées et propriétaires.'
  },
  {
    title: 'Exclusion numérique',
    description: 'Ne pas adapter les outils pour tous les publics.'
  },
  {
    title: 'Surconsommation',
    description: 'Remplacer systématiquement le matériel au lieu de le réparer ou réutiliser.'
  },
  {
    title: 'Absence de contribution',
    description: 'Ne pas encourager la participation et le partage dans la communauté.'
  },
  {
    title: 'Non-respect de la vie privée',
    description: 'Collecter des données sans transparence ni consentement.'
  },
];

function getRandomPosition() {
  const top = Math.random() * 80 + 5;
  const left = Math.random() * 80 + 5;
  return { top: `${top}%`, left: `${left}%` };
}

function App() {
  const [showWelcome, setShowWelcome] = useState(true);
  type Card = {
    title: string;
    description: string;
    position: { top: string; left: string };
  };
  const [cards, setCards] = useState<Card[]>([]);

  useEffect(() => {
    if (!showWelcome) {
      setCards(cardsData.map(card => ({ ...card, position: getRandomPosition() })));
    }
  }, [showWelcome]);

  return (
    <div className="home">
      {showWelcome && <Welcome />}
      {!showWelcome && (
        <>
          <h1 className="nird-title">Mauvaises pratiques à éviter pour un numérique responsable</h1>
          <div className="cards-container">
            {cards.map((card, idx) => (
              <div
                key={idx}
                className="nird-card bad-card"
                style={{ position: 'absolute', ...card.position, animation: `cardIn 0.8s ${idx * 0.2}s both` }}
              >
                <h2>{card.title}</h2>
                <p>{card.description}</p>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  )
}

export default App
