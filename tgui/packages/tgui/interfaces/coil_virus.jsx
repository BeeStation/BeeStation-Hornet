import { NtosWindow } from '../layouts';
import { Section, Box, Button } from '../components';
import { Component } from 'react';
import { useBackend } from '../backend';

const asciiLogo = String.raw`
   _____         _  _
  /  __ \       (_)| |
  | /  \/  ___   _ | |__   __ _ __  ___
  | |     / _ \ | || |\ \ / /| '__|/ __|
  | \__/\| (_) || || | \ V / | |   \__ \
   \____/ \___/ |_||_|  \_/  |_|   |___/ v1.0

       -==[ HELLRAISERS CRACK TEAM ]==-
`;

const scriptLines = [
  'Auth bypass accepted...',
  '',
  'Mounting spool driver...',
  '',
  'Streaming coil payload...',
  '',
  '32-bit stub installed.',
  '',
  'Loading...',
];

const FPS = 55;
const tickInterval = 1000 / FPS;
const colourCycle = ['#00dfff', '#00ff00', '#ffea00', '#ff6b00', '#ff006e'];

export const coil_virus = (_props) => {
  const { act } = useBackend();

  return (
    <NtosWindow title="coil_virus.exe" width={400} height={550}>
      <NtosWindow.Content>
        <CoilVirusConsole act={act} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

class CoilVirusConsole extends Component {
  constructor(props) {
    super(props);
    this.state = {
      frame: 0,
      lineIdx: 0,
      charIdx: 0,
      loadingStarted: false,
      progress: 0,
    };
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  tick() {
    const { frame, lineIdx, charIdx, loadingStarted, progress } = this.state;

    if (!loadingStarted) {
      if (lineIdx < scriptLines.length) {
        const currentLine = scriptLines[lineIdx];
        if (charIdx < currentLine.length) {
          this.setState({ charIdx: charIdx + 1, frame: frame + 1 });
        } else {
          if (frame % 20 === 0) {
            this.setState({ lineIdx: lineIdx + 1, charIdx: 0, frame: 0 });
          } else {
            this.setState({ frame: frame + 1 });
          }
        }
      } else {
        // All lines typed, begin loading bar after slight pause
        this.setState({ loadingStarted: true, frame: 0, progress: 0 }); // reset progress here
      }
      // NO progress increment here
    } else {
      // Loading started, increment progress until 100%
      if (progress < 100) {
        const step = Math.random() * 0.5 + 0.1;
        this.setState({ progress: Math.min(progress + step, 100), frame: frame + 1 });
      } else {
        // Progress reached 100%, stop incrementing frame for stable blinking cursor
        this.setState({ frame: (frame + 1) % (colourCycle.length * 5) });
      }
    }
  }

  render() {
    const { frame, lineIdx, charIdx, loadingStarted, progress } = this.state;
    const colour = colourCycle[Math.floor(frame / 5) % colourCycle.length];
    const filledLength = Math.floor(progress / 5);
    const bar = '■'.repeat(filledLength) + '□'.repeat(20 - filledLength);

    return (
      <Section fill scrollable backgroundColor="black" style={{ whiteSpace: 'pre-wrap' }}>
        {asciiLogo.split('\n').map((ln, i) => (
          <Box
            key={i}
            color={colour}
            fontFamily="monospace"
            mb={ln === '' ? 1 : 0}
            style={ln === '' ? { minHeight: '1em' } : {}}>
            {ln === '' ? '\u00A0' : ln} {/* non-breaking space to force line height */}
          </Box>
        ))}
        <Box mt={1} />

        {/* Show typed script lines */}
        {scriptLines.slice(0, lineIdx).map((ln, i) => (
          <Box
            key={i}
            color="#00ff00"
            fontFamily="monospace"
            mb={ln === '' ? 1 : 0}
            style={ln === '' ? { minHeight: '1em' } : {}}>
            {ln === '' ? '\u00A0' : ln}
          </Box>
        ))}

        {/* Current line typing */}
        {!loadingStarted && lineIdx < scriptLines.length && (
          <Box color="#00ff00" fontFamily="monospace">
            {scriptLines[lineIdx].substring(0, charIdx)}
            <span style={{ visibility: frame % 10 < 5 ? 'visible' : 'hidden' }}>█</span>
          </Box>
        )}

        {/* After loading started, show progress bar */}
        {loadingStarted && (
          <>
            <Box mt={2} />
            <Box color="#00ff00" fontFamily="monospace">
              [ {bar} ] {Math.floor(progress)}%
            </Box>
            {progress >= 100 && (
              <Box mt={1} style={{ display: 'flex', gap: '0.5rem' }}>
                <Button
                  style={{
                    backgroundColor: 'black',
                    border: '1px solid #38f5ff',
                    color: '#38f5ff',
                    fontFamily: 'monospace',
                    padding: '0.4rem 1rem',
                    textTransform: 'uppercase',
                    cursor: 'pointer',
                    textShadow: '0 0 5px #38f5ff',
                  }}
                  onClick={() => this.props.act('Detonate')}>
                  Fire!
                </Button>
              </Box>
            )}
          </>
        )}
      </Section>
    );
  }
}
