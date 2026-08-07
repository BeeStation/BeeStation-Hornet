import '../styles/virus_coil_animation.scss';

import { Component } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

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
  'Streaming coil payload...',
  '',
  '32-bit stub installed.',
  '',
  'Loading...',
];

const FPS = 45;
const tickInterval = 1000 / FPS;

export const virus_coil = (_props) => {
  const { act } = useBackend();

  return (
    <NtosWindow title="Coilvrs.exe" width={400} height={550}>
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
    const { lineIdx, charIdx, loadingStarted, progress } = this.state;

    if (!loadingStarted) {
      if (lineIdx < scriptLines.length) {
        const currentLine = scriptLines[lineIdx];
        if (charIdx < currentLine.length) {
          this.setState({ charIdx: charIdx + 1 });
        } else {
          // Delay before moving to next line
          this.setState((prev) => ({
            frameDelay: (prev.frameDelay || 0) + 1,
          }));
          if ((this.state.frameDelay || 0) >= 20) {
            this.setState({ lineIdx: lineIdx + 1, charIdx: 0, frameDelay: 0 });
          }
        }
      } else {
        this.setState({ loadingStarted: true, progress: 0 });
      }
    } else {
      if (progress < 100) {
        const step = Math.random() * 0.5 + 0.1;
        this.setState({ progress: Math.min(progress + step, 100) });
      }
    }
  }

  render() {
    const { frame, lineIdx, charIdx, loadingStarted, progress } = this.state;
    const filledLength = Math.floor(progress / 5);
    const bar = '■'.repeat(filledLength) + '□'.repeat(20 - filledLength);

    return (
      <Section
        fill
        scrollable
        backgroundColor="black"
        style={{ whiteSpace: 'pre-wrap' }}
      >
        {/* ASCII Logo */}
        {asciiLogo.split('\n').map((ln, i) => (
          <Box
            key={i}
            className="ascii-logo-line"
            mb={ln === '' ? 1 : 0}
            style={ln === '' ? { minHeight: '1em' } : {}}
          >
            {ln === '' ? '\u00A0' : ln}
          </Box>
        ))}

        <Box mt={1} />

        {/* Fully typed script lines */}
        {scriptLines.slice(0, lineIdx).map((ln, i) => (
          <Box
            key={i}
            className="script-line"
            mb={ln === '' ? 1 : 0}
            style={ln === '' ? { minHeight: '1em' } : {}}
          >
            {ln === '' ? '\u00A0' : ln}
          </Box>
        ))}

        {/* Typing animation of current line */}
        {!loadingStarted && lineIdx < scriptLines.length && (
          <Box className="script-line">
            {scriptLines[lineIdx].substring(0, charIdx)}
            <span className="cursor">█</span>
          </Box>
        )}

        {/* Loading bar */}
        {loadingStarted && (
          <>
            <Box mt={2} />
            <Box className="progress-bar">
              <span className="bar-fill">[ {bar} ]</span>
              <span className="bar-percent">{Math.floor(progress)}%</span>
            </Box>

            {/* Fire button */}
            {progress >= 100 && (
              <Box mt={1} style={{ display: 'flex', gap: '0.5rem' }}>
                <Button
                  className="detonate-button"
                  onClick={() => this.props.act('Detonate')}
                >
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
