import { HeroFake } from './components/HeroFake';
import { RealityCheck } from './components/RealityCheck';

function App() {
  return (
    <main className="bg-black min-h-screen w-full">
      <HeroFake />
      <RealityCheck />
    </main>
  );
}

export default App;
