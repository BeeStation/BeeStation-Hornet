import { NtosWindow } from '../layouts';
import { Section, Box } from '../components';
import { Component } from 'react';
import { useBackend } from '../backend';

// Static header always visible
const header = String.raw`
  $$\   $$\           $$\ $$\                    $$\
  $$ |  $$ |          $$ |$$ |                   \__|
  $$ |  $$ | $$$$$$\  $$ |$$ | $$$$$$\  $$$$$$\  $$\  $$$$$$$\  $$$$$$\   $$$$$$\   $$$$$$$\
  $$$$$$$$ |$$  __$$\ $$ |$$ |$$  __$$\ \____$$\ $$ |$$  _____|$$  __$$\ $$  __$$\ $$  _____|
  $$  __$$ |$$$$$$$$ |$$ |$$ |$$ |  \__|$$$$$$$ |$$ |\$$$$$$\  $$$$$$$$ |$$ |  \__|\$$$$$$\
  $$ |  $$ |$$   ____|$$ |$$ |$$ |     $$  __$$ |$$ | \____$$\ $$   ____|$$ |       \____$$\
  $$ |  $$ |\$$$$$$$\ $$ |$$ |$$ |     \$$$$$$$ |$$ |$$$$$$$  |\$$$$$$$\ $$ |      $$$$$$$  |
  \__|  \__| \_______|\__|\__|\__|      \_______|\__|\_______/  \_______|\__|      \_______/


                              -==[ HELLRAISERS CRACK TEAM ]==-
`;

const intro = `
Auth bypass successful.
Opening README.txt …
`;

const body = `
Hey.

Whats shakin, bakin. (!?!!?!?)

We read some comments on the forums regarding NT policy enforcers abusing
the ability to disable NT messager altogether.

It's an act of cowardice we cannot abide by. (I think that means tolerate)
So, we've developed a special little something for you, child of mankind.

We are entrusting you with this Virus, the Breacher.
(Daxter spells it like Brexer, and since he kinda coded the whole thing...
I let him have this win)

As usual you only get one shot so listen carefully:
Dual injection method Virus.


Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted.
 3. Pick a target.
 4. Their Device's receiving will be locked ON.
 5. Harrass them freely.

You can also activate the file itself.

Manual Usage:
 1. Run the File that comes pre-installed.
 2. Let it play.
 3. Your Hard-Drive and Network Card are desintegrated.

Notes:
 • Be warned! It is possible a fresh install of an anti-virus can do away with this trojan.
 • There is no penalty for closing the program early (It's just Daxters diary in funny letters)
 • The cartrige will self-detonate on usage.

Have fun raising hell!
- Hellraisers  ⧉ 2536
`;

const FPS = 120;
const tickInterval = 1000 / FPS;

export const VirusReadme_Breacher = (props) => {
  return (
    <NtosWindow title="BrexerTrojn-README.txt" width={760} height={560}>
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
  VirusReadme_Breacher,
};
