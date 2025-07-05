import { NtosWindow } from '../layouts';
import { Section, Box } from '../components';
import { Component } from 'react';
import { useBackend } from '../backend';

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
Ok!

Gloves are off this time.

We have decided to use our knowledge of NTOS Virus Buster to deliver it's reckoning.
(or is it reconing? Rekoning? I mean like, it will cease to be.)

While they hide behind their walls NT keeps reeping in the rewards of
exploiting the common person, that has nowhere better to be...

Well, their walls are no more. Cus we bring in the SLEDGEHAMMER!
(This ones mine!)

One shot.
Dual injection.


Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted.
 3. Pick a target.
 4. If they have Virus Buster installed it will knock them down a sub.

You can also activate the file itself.

Manual Usage:
 1. Run the File that comes pre-installed.
 2. Let it play (or not).
 3. Completely removes Virus Buster from your device.

Notes:
 • Careful. The virus doesn't stack. So if they have level 3 package they can only go down to 2.
 • This is ideal for manual uninstalls of VB (To set up other viruses)
 • The cartrige will self-destroy on use.

Let them fear us!
- Hellraisers  ⧉ 2536
`;

const FPS = 150;
const tickInterval = 1000 / FPS;

export const VirusReadme_Sledge = (props) => {
  return (
    <NtosWindow title="Sleghamr-README.txt" width={650} height={560}>
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
          <Box mb={1} key={i} fontFamily="monospace" color="white" style={{ whiteSpace: 'pre-wrap' }}>
            {line === '' ? '\u00A0' : line}
          </Box>
        ))}
      </Section>
    );
  }
}
export const interfaces = {
  VirusReadme_Sledge,
};
