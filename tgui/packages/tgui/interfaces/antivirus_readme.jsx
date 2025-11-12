import { Component } from 'react';

import { Box, Section } from '../components';
import { NtosWindow } from '../layouts';

// Static header always visible
const header = String.raw`
  $$\   $$\         $$\$$\                 $$\
  $$ |  $$ |        $$ $$ |                \__|
  $$ |  $$ |$$$$$$\ $$ $$ |$$$$$$\ $$$$$$\ $$\ $$$$$$$\ $$$$$$\  $$$$$$\  $$$$$$$\
  $$$$$$$$ $$  __$$\$$ $$ $$  __$$\\____$$\$$ $$  _____$$  __$$\$$  __$$\$$  _____|
  $$  __$$ $$$$$$$$ $$ $$ $$ |  \__$$$$$$$ $$ \$$$$$$\ $$$$$$$$ $$ |  \__\$$$$$$\
  $$ |  $$ $$   ____$$ $$ $$ |    $$  __$$ $$ |\____$$\$$   ____$$ |      \____$$\
  $$ |  $$ \$$$$$$$\$$ $$ $$ |    \$$$$$$$ $$ $$$$$$$  \$$$$$$$\$$ |     $$$$$$$  |
  \__|  \__|\_______\__\__\__|     \_______\__\_______/ \_______\__|     \_______/

                        -==[ HELLRAISERS CRACK TEAM ]==-
`;

const intro = `
Auth bypass successful.
Opening README.txt …
`;

const body = `
Yarr matey!

You are now running the cracked build of *NTOS Virus Buster*.
This crack allows for remote activation of subscription packages on other devices.
Which is fancy talk for "gift card".
NT removed this feature soon after release since there were internal concerns that this might influence users into socialism.
We, of the Hellraiser team release this feature form their greedy talons and give them back to you, the user!

Usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted. (Do not be alarmed)
 3. A message will appear on your device if the activation was successful.
 4. Enjoy! Sharing is caring!

Notes:
 • Be aware that all comunication trough NTnetwork is LOGGED!
 • The program will let you know if the recipient already has an equal or better subscription package.
 • The cartrige will self-detonate on usage.

Have fun, and stay safe!
- Hellraisers  ⧉ 2536
`;

const FPS = 120;
const tickInterval = 1000 / FPS;

export const antivirus_readme = (props) => {
  return (
    <NtosWindow title="Crack-README.txt" width={650} height={560}>
      <NtosWindow.Content>
        <ReadmeScroller text={body} preText={intro} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export class ReadmeScroller extends Component {
  constructor(props) {
    super(props);
    this.state = { idx: 0 };
    this.timer = null;
    this.fullText = props.preText + props.text;
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  tick() {
    const { idx } = this.state;
    if (idx < this.fullText.length) {
      this.setState({ idx: idx + 1 });
    }
  }

  render() {
    const display = this.fullText.substring(0, this.state.idx);
    return (
      <Section fill scrollable backgroundColor="black">
        {(header + display).split('\n').map((line, i) => (
          <Box
            mb={1}
            key={i}
            fontFamily="monospace"
            color="white"
            style={{ whiteSpace: 'pre-wrap' }}
          >
            {line === '' ? '\u00A0' : line}
          </Box>
        ))}
      </Section>
    );
  }
}
export const interfaces = {
  antivirus_readme,
};
