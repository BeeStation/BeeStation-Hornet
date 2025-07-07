import { NtosWindow } from '../layouts';
import { Section, Box, Button } from '../components';
import { Component } from 'react';
import { useBackend } from '../backend';

const rawLogo = String.raw`
  ██████╗ ██████╗ ███████╗██╗  ██╗███████╗██████╗
  ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝██╔════╝██╔══██╗
  ██████╔╝██████╔╝█████╗   ╚███╔╝ █████╗  ██████╔╝
  ██╔══██╗██╔══██╗██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗
  ██████╔╝██║  ██║███████╗██╔╝ ██╗███████╗██║  ██║
  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                      v1.2
        -==[ HELLRAISERS CRACK TEAM ]==-`;

const tips = [
  'Tip: Proudly made by Daxter',
  'Tip: Think of me if you get rich, got it?',
  'Tip: Security never checks your hardware parts.',
  'Tip: DO NOT CLOSE THE WINDOW. IT WILL MAKE THE DEVICE EXPLODE!',
  'Tip: Dont forget to smile for the camera! (If you get caught)',
  'Tip: Crows remember faces.',
  'Tip: Pigeons can do math roughly as well as monkeys.',
  'Tip: Peeling an orange from the bottom is easier.',
  'Tip: Ducks have regional accents.',
];

const FPS = 40;
const tickInterval = 1000 / FPS;

export const virus_breacher = () => (
  <NtosWindow title="BrexerTrojn.exe" width={450} height={400}>
    <NtosWindow.Content>
      <BreacherConsole />
    </NtosWindow.Content>
  </NtosWindow>
);

class BreacherConsole extends Component {
  constructor(props) {
    super(props);
    this.state = {
      frame: 0,
      progress: 0,
      tipIdx: 0,
    };
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  tick() {
    const { frame, progress } = this.state;

    // stop filling once we hit 100%
    const reachedMax = progress >= 100;
    const step = reachedMax ? 0 : Math.random() * 0.3 + 0.1; // slow fill until 100
    const nextProg = Math.min(progress + step, 100);

    this.setState((prev) => ({
      frame: prev.frame + 1,
      progress: nextProg,
      tipIdx: prev.frame % 120 === 0 ? Math.floor(Math.random() * tips.length) : prev.tipIdx,
    }));
  }

  // linear RGB interpolation helper
  interp(a, b, t) {
    return a.map((c, i) => Math.round(c + (b[i] - c) * t));
  }

  render() {
    const { frame, progress, tipIdx } = this.state;
    const { act } = useBackend();

    /* ╭── colour fade ───────────────────╮ */
    const fadeCols = [
      [255, 0, 85],
      [255, 51, 119],
      [255, 102, 153],
      [255, 51, 119],
    ];
    const seg = Math.floor(frame / 60) % fadeCols.length;
    const next = (seg + 1) % fadeCols.length;
    const rawT = (frame % 60) / 60;
    const t = (1 - Math.cos(Math.PI * rawT)) / 2; // cosine‑ease
    const logoColour = `rgb(${this.interp(fadeCols[seg], fadeCols[next], t).join(',')})`;

    /* ╭── gentle sway ───────────────────╮ */
    const filled = Math.floor(progress / 4);
    const bar = '■'.repeat(filled) + '□'.repeat(25 - filled);

    const lines = rawLogo.split('\n');

    return (
      <Section fill scrollable backgroundColor="black" style={{ whiteSpace: 'pre-wrap' }}>
        {lines.map((line, i) => (
          <Box
            key={i}
            style={{ transform: `translateX(${Math.sin(frame / 15 + i) * 4}px)` }}
            color={logoColour}
            fontFamily="monospace">
            {line}
          </Box>
        ))}

        <Box mt={2} color="#00ff00" fontFamily="monospace">
          [ {bar} ] {Math.floor(progress)}%
        </Box>

        {/* ── action buttons ───────────────────────────── */}
        <Box mt={1} style={{ display: 'flex', gap: '0.5rem' }}>
          <Button
            style={{
              backgroundColor: 'black',
              border: '1px solid #ff004d',
              color: '#ff004d',
              fontFamily: 'monospace',
              padding: '0.4rem 1rem',
              textTransform: 'uppercase',
              cursor: 'pointer',
              textShadow: '0 0 5px #ff004d',
            }}
            onClick={() => act('PC_exit')}>
            Disarm
          </Button>

          {progress >= 100 && (
            <Button
              style={{
                backgroundColor: 'black',
                border: '1px solid #ffff00',
                color: '#ffff00',
                fontFamily: 'monospace',
                padding: '0.4rem 1rem',
                textTransform: 'uppercase',
                cursor: 'pointer',
                textShadow: '0 0 5px #ffff00',
              }}
              onClick={() => act('Detonate')}>
              Detonate
            </Button>
          )}
        </Box>

        <Box mt={1} color="#ffea00" fontFamily="monospace">
          {tips[tipIdx]}
        </Box>
      </Section>
    );
  }
}

export const interfaces = {
  virus_breacher,
};
