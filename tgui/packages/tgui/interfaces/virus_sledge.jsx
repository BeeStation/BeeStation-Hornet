import { NtosWindow } from '../layouts';
import { Section, Box, Button } from '../components';
import { Component } from 'react';
import { useBackend } from '../backend';

// ============================================================================
//  $$\   $$\           $$\ $$\                    $$\
//  $$ |  $$ |          $$ |$$ |                   \__|
//  $$ |  $$ | $$$$$$\  $$ |$$ | $$$$$$\  $$$$$$\  $$\  $$$$$$$\  $$$$$$\   $$$$$$\   $$$$$$$\
//  $$$$$$$$ |$$  __$$\ $$ |$$ |$$  __$$\ \____$$\ $$ |$$  _____|$$  __$$\ $$  __$$\ $$  _____|
//  $$  __$$ |$$$$$$$$ |$$ |$$ |$$ |  \__|$$$$$$$ |$$ |\$$$$$$\  $$$$$$$$ |$$ |  \__|\$$$$$$\
//  $$ |  $$ |$$   ____|$$ |$$ |$$ |     $$  __$$ |$$ | \____$$\ $$   ____|$$ |       \____$$\
//  $$ |  $$ |\$$$$$$$\ $$ |$$ |$$ |     \$$$$$$$ |$$ |$$$$$$$  |\$$$$$$$\ $$ |      $$$$$$$  |
//  \__|  \__| \_______|\__|\__|\__|      \_______|\__|\_______/  \_______|\__|      \_______/
// ============================================================================
//                          ==[ HELLRAISERS CRACK TEAM ]==
// ============================================================================

const asciiLogo = String.raw`
  ________.__                .__
 /   _____|  |   ____   ____ |  |__ _____    ____________
 \_____  \|  | _/ __ \ / ___\|  |  \\__  \  /     \_  __ \
 /        |  |_\  ___// /_/  |   Y  \/ __ \|  Y Y  |  | \/
/_______  |____/\___  \___  /|___|  (____  |__|_|  |__|
        \/          \/_____/      \/     \/      \/    v1.0

             -==[ HELLRAISERS CRACK TEAM ]==-
`;

/* constants */
const CODE_LENGTH = 8; // 8‑letter code
const randChar = () => String.fromCharCode(65 + Math.floor(Math.random() * 26));
const FPS = 50;
const tickInterval = 1000 / FPS;
const DECODE_STEP_FRAMES = FPS * 1; // letter lock in seconds

const fadeCols = [
  [0, 255, 255],
  [0, 255, 0],
  [255, 255, 0],
  [255, 102, 0],
  [255, 0, 255],
];

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

class VirusSledgeKey extends Component {
  constructor(props) {
    super(props);
    const letters = Array.from({ length: CODE_LENGTH }, randChar).join('');
    this.state = {
      frame: 0,
      deciphered: 0,
      finalCode: letters,
      decodeFrames: Array.from({ length: 8 }, () => FPS * (0.8 + Math.random() * 3)),
      keyActivated: false,
      detonateSent: false,
    };
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }
  componentWillUnmount() {
    clearInterval(this.timer);
  }

  interp(a, b, t) {
    return a.map((c, i) => Math.round(c + (b[i] - c) * t));
  }

  tick() {
    this.setState((prev) => {
      const { frame, deciphered, keyActivated } = prev;

      // decode letters one by one
      if (deciphered < CODE_LENGTH) {
        if (frame >= DECODE_STEP_FRAMES) {
          return { ...prev, deciphered: deciphered + 1, frame: 0 };
        }
        return { ...prev, frame: frame + 1 };
      }

      // once fully decoded, simply flag keyActivated (no auto actions)
      if (!keyActivated) {
        return { ...prev, keyActivated: true };
      }

      // keep frame running for logo colour animation
      return { ...prev, frame: frame + 1 };
    });
  }

  render() {
    const { frame, deciphered, finalCode, keyActivated, detonateSent } = this.state;

    /* colour‑cycling logo */
    const seg = Math.floor(frame / 60) % fadeCols.length;
    const next = (seg + 1) % fadeCols.length;
    const rawT = (frame % 60) / 60;
    const t = (1 - Math.cos(Math.PI * rawT)) / 2;
    const logoRGB = this.interp(fadeCols[seg], fadeCols[next], t);
    const logoColour = `rgb(${logoRGB.join(',')})`;

    /* build letter spans */
    const codeSpans = Array.from({ length: CODE_LENGTH }).map((_, i) => {
      const char = i < deciphered ? finalCode[i] : randChar();
      const color = i < deciphered ? '#66ff66' : '#00ffcc';
      return (
        <span
          key={i}
          style={{
            color,
            fontFamily: 'monospace',
            fontSize: '1.5rem',
            letterSpacing: '0.3rem',
            textShadow: `0 0 6px ${color}`,
          }}>
          {char}
        </span>
      );
    });

    return (
      <Section fill scrollable backgroundColor="black" style={{ whiteSpace: 'pre-wrap' }}>
        {/* animated logo */}
        {asciiLogo.split('\n').map((ln, idx) => (
          <Box
            key={idx}
            color={logoColour}
            fontFamily="monospace"
            style={{ transform: `translateY(${Math.sin((frame + idx * 6) / 15) * 2}px)` }}>
            {ln || '\u00A0'}
          </Box>
        ))}

        <Box mt={2} />

        {!keyActivated && (
          <Box color="#00ffff" fontFamily="monospace" mb={1}>
            Generating key...
          </Box>
        )}

        <Box mb={1} style={{ display: 'flex', justifyContent: 'center', gap: '0.2rem' }}>
          {codeSpans}
        </Box>

        {/* Purge button after key activation */}
        {keyActivated && (
          <>
            <Box color="#ff0000" fontFamily="monospace" mb={1}>
              Key Activated
            </Box>
            {!detonateSent && (
              <Button
                style={buttonStyle('#ff0000')}
                onClick={() => {
                  this.props.act('Detonate');
                  this.setState({ detonateSent: true });
                }}>
                PURGE
              </Button>
            )}
          </>
        )}
      </Section>
    );
  }
}

export const buttonStyle = (stroke) => ({
  backgroundColor: 'black',
  border: `1px solid ${stroke}`,
  color: stroke,
  fontFamily: 'monospace',
  padding: '0.4rem 1rem',
  textTransform: 'uppercase',
  cursor: 'pointer',
  textShadow: `0 0 6px ${stroke}`,
});
