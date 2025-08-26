import '../styles/virus_breacher_animation.scss';

import { Component } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

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
const tickInterval = 200; // 5fps – plenty for a progress bar

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
    const step = reachedMax ? 0 : Math.random() * 2 + 1;
    const nextProg = Math.min(progress + step, 100);

    this.setState((prev) => ({
      frame: prev.frame + 1,
      progress: nextProg,
      tipIdx:
        prev.frame % 120 === 0
          ? Math.floor(Math.random() * tips.length)
          : prev.tipIdx,
    }));
  }

  render() {
    const { frame, progress, tipIdx } = this.state;
    const { act } = useBackend();

    const filled = Math.floor(progress / 4);
    const bar = '■'.repeat(filled) + '□'.repeat(25 - filled);
    const lines = rawLogo.trimEnd().split('\n');

    return (
      <Section
        fill
        scrollable
        backgroundColor="black"
        style={{ whiteSpace: 'pre-wrap' }}
      >
        <div className="logo-container">
          {lines.map((line, i) => (
            <Box
              key={i}
              className="logo-line"
              style={{ '--i': i }}
              fontFamily="monospace"
            >
              {line}
            </Box>
          ))}
        </div>

        <Box mt={2} className="progress-bar">
          [ {bar} ] {Math.floor(progress)}%
        </Box>

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
            onClick={() => act('PC_exit')}
          >
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
              onClick={() => act('Detonate')}
            >
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
