import { NtosWindow } from '../layouts';
import { Section, Box } from '../components';
import React, { Component, useEffect } from 'react';
import { useBackend } from '../backend';

/* ───── static text blocks ──── */
const logTextAlways = `
----------------------------------------
    !!MALWARE SIGNATURE DETECTED!!
----------------------------------------
`;

const logTextPrependAlways = `
[INFECT] Initializing payload...
[INFECT] Memory breach underway...
[INFECT] Accessing kernel routines...
[INFECT] Executing system override...
[INFECT] Deploying self-replicating code...
[INFECT] Compromising BIOS integrity...
`;

const logText = `
[ERROR] Unauthorized execution at 0x00A394FF
[ERROR] Memory overflow imminent
[ERROR] Disk write protection disabled
[INFECT] Purging existing drives...
[INFECT] Root control obtained.
[!!!] SYSTEM FAILURE
[!!!] HARDWARE FAULT DETECTED

[!!!] SYSTEM SHUTDOWN IN 3...
[!!!] SYSTEM SHUTDOWN IN 2...
[!!!] SYSTEM SHUTDOWN IN 1...
`;

/* … all the constant text blocks stay exactly as you have them … */

const FPS = 120;
const tickInterval = 1000 / FPS;

/* ───── wrapper window ──── */
export const NtosVirus = () => {
  const { act, suspended } = useBackend();

  /* 🔑  Detect outer-window close / minimise */
  useEffect(() => {
    if (suspended) {
      act('PC_exit');
    }
  }, [suspended]);

  return (
    <NtosWindow title="System Infection Detected" width={400} height={500}>
      <NtosWindow.Content>
        <VirusConsoleText log_text={logText} act={act} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

/* ───── scrolling console component ──── */
export class VirusConsoleText extends Component {
  constructor(props) {
    super(props);
    this.state = { index: 0 };
    this.timer = null;
    this.text = logTextPrependAlways + props.log_text;
  }

  tick() {
    const step = this.props.frame_skip || 1;
    if (this.state.index < this.text.length) {
      this.setState(({ index }) => ({ index: index + step }));
    } else {
      clearInterval(this.timer);
      this.timer = setTimeout(() => {
        if (this.props.act) this.props.act('PC_exit');
      }, this.props.end_pause || 500);
    }
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
    /* guarantee PC_exit on React unmount (e.g. PDA minimise) */
    if (this.props.act) this.props.act('PC_exit');
  }

  render() {
    const slice = this.text.substring(0, Math.min(this.state.index, this.text.length));
    return (
      <Section fill scrollable backgroundColor="black">
        {(logTextAlways + slice).split('\n').map((line, i) =>
          line.trim() ? (
            <Box mb={1} key={i}>
              <font color="lime">{line}</font>
            </Box>
          ) : null
        )}
      </Section>
    );
  }
}
