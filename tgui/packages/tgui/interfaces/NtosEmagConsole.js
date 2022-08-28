import { NtosWindow, Window } from '../layouts';
import { Section, Box } from '../components';
import { Component } from 'inferno';
import { useBackend } from '../backend';

const logTextAlways = `
----------------------------------------
      Crypto-breaker 2400 Edition
----------------------------------------\n`;
const logText = `
Cryptographic Sequence accepted.


Receiving key dump...


Key dump retrieved.


Initiating brute-force protocols.


Syndix uplink established.


Remote processing established.


Online!





Sending rootkit...


Root privileges established.






Initiating software link...


Online!





Enabling self-destruct protocols...


Online!





Removing packet limits...


Done!







Cryptographic Sequence complete.
`;

const FPS = 360;
const tickInterval = 1000 / FPS;

export const EmagConsole = (props, context) => {
  return (
    <Window title="Crypto-breaker 2400 Edition" width={400} height={500}>
      <Window.Content>
        <EmagConsoleText />
      </Window.Content>
    </Window>
  );
};

export const NtosEmagConsole = (props, context) => {
  return (
    <NtosWindow title="Crypto-breaker 2400 Edition" width={400} height={500}>
      <NtosWindow.Content>
        <EmagConsoleText />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

class EmagConsoleText extends Component {

  constructor() {
    super();
    this.timer = null;
    this.state = {
      index: 0,
    };
  }

  tick() {
    const { state } = this;
    if (state.index < logText.length) {
      this.setState({ index: state.index + 1 });
    } else {
      clearTimeout(this.timer);
      // 0.5s later...
      this.timer = setTimeout(() => {
        const { act } = useBackend(this.context);
        // All UI actions close the program
        act("PC_exit");
      }, 500);
    }
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    const { state } = this;
    const toShow = logText.substring(0, state.index);
    return (
      <Section fill scrollable backgroundColor="black">
        {(logTextAlways + toShow).split("\n").map((log) => (
          log !== "\n" ? (
            <Box mb={1} key={log}>
              <font color="white">{log}</font>
            </Box>
          ) : null
        ))}
      </Section>
    );
  }
}
