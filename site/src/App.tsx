import { HeroFake } from './components/HeroFake';
import { RealityCheck } from './components/RealityCheck';
import { CallToAction } from './components/CallToAction';

function App() {
  return (
    <main className="bg-black min-h-screen w-full">
      <HeroFake />
      <RealityCheck />
      <CallToAction />
    </main>
  );
}

export default App;
