import { useState } from 'react';
import { HeroFake } from './components/HeroFake';
import { RealityCheck } from './components/RealityCheck';
import { Preloader } from './components/Preloader';

function App() {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <main className="bg-black min-h-screen w-full">
      {isLoading ? (
        <Preloader onComplete={() => setIsLoading(false)} />
      ) : (
        <>
          <HeroFake />
          <RealityCheck />
        </>
      )}
    </main>
  );
}

export default App;
