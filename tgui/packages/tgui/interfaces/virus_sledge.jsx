import '../styles/virus_sledge_animation.scss';

import { Component } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

const asciiLogo = String.raw`
  ________.__                .__
 /   _____|  |   ____   ____ |  |__ _____    ____________
 \_____  \|  | _/ __ \ / ___\|  |  \\__  \  /     \_  __ \
 /        |  |_\  ___// /_/  |   Y  \/ __ \|  Y Y  |  | \/
/_______  |____/\___  \___  /|___|  (____  |__|_|  |__|
        \/          \/_____/      \/     \/      \/    v1.0

             -==[ HELLRAISERS CRACK TEAM ]==-
`;

/* ───── constants ─────────────────────────────────────────────── */
const CODE_LENGTH = 8;
const randChar = () => String.fromCharCode(65 + Math.floor(Math.random() * 26));
const FPS = 50;
const tick = 1000 / FPS;
const LOCK = FPS * 1; // frames per letter‑lock

/* ────── exported wrapper ─────────────────────────────────────── */
export const virus_sledge = () => {
  const { act } = useBackend();
  return (
    <NtosWindow title="Sleghamr.exe" width={500} height={520}>
      <NtosWindow.Content>
        <VirusSledgeKey act={act} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

/* ────── main component ───────────────────────────────────────── */
class VirusSledgeKey extends Component {
  constructor(props) {
    super(props);
    this.state = {
      frame: 0,
      deciphered: 0,
      finalCode: Array.from({ length: CODE_LENGTH }, randChar).join(''),
      keyActivated: false,
      detonateSent: false,
    };
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tick);
  }
  componentWillUnmount() {
    clearInterval(this.timer);
  }

  /* typing cadence only (CSS does the rest) */
  tick() {
    this.setState((prev) => {
      const { frame, deciphered, keyActivated } = prev;

      if (deciphered < CODE_LENGTH) {
        if (frame >= LOCK) {
          return { ...prev, deciphered: deciphered + 1, frame: 0 };
        }
        return { ...prev, frame: frame + 1 };
      }

      if (!keyActivated) return { ...prev, keyActivated: true };
      return prev; // nothing else to animate in JS
    });
  }

  render() {
    const { deciphered, finalCode, keyActivated, detonateSent } = this.state;

    /* build letter spans */
    const letters = Array.from({ length: CODE_LENGTH }, (_, i) => (
      <span
        key={i}
        className={`virus-code-letter ${i < deciphered ? 'decoded' : 'decoding'}`}
      >
        {i < deciphered ? finalCode[i] : randChar()}
      </span>
    ));

    return (
      <Section
        fill
        scrollable
        backgroundColor="black"
        style={{ whiteSpace: 'pre-wrap' }}
      >
        {/* logo lines – CSS handles colour & bobbing */}
        {asciiLogo.split('\n').map((ln, idx) => (
          <Box key={idx} className="virus-logo-line">
            {ln || '\u00A0'}
          </Box>
        ))}

        <Box mt={2} />

        {!keyActivated && (
          <Box className="virus-key-activated" style={{ color: '#00ffff' }}>
            Generating key...
          </Box>
        )}

        <Box
          mb={1}
          style={{ display: 'flex', justifyContent: 'center', gap: '0.2rem' }}
        >
          {letters}
        </Box>

        {keyActivated && (
          <>
            <Box className="virus-key-activated">Key Activated</Box>
            {!detonateSent && (
              <Button
                className="virus-button"
                onClick={() => {
                  this.props.act('Detonate');
                  this.setState({ detonateSent: true });
                }}
              >
                PURGE
              </Button>
            )}
          </>
        )}
      </Section>
    );
  }
}
