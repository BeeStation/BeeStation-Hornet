import { Component } from 'react';

import { useBackend } from '../backend';
import { Box, Section } from '../components';
import { NtosWindow } from '../layouts';

const logTextAlways = `
----------------------------------------
      Crypto-breaker 2400 Edition
----------------------------------------
`;
const logTextPrependAlways = `
Cryptographic Sequence accepted.


Receiving key dump...


Key dump retrieved.


Initiating brute-force protocols.


Syndix uplink established.


Remote processing established.


Online!



`;
const logText = `

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

const FPS = 120;
const tickInterval = 1000 / FPS;

export const NtosEmagConsole = (props) => {
  return (
    <NtosWindow title="Crypto-breaker 2400 Edition" width={400} height={500}>
      <NtosWindow.Content>
        <EmagConsoleText log_text={logText} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export class EmagConsoleText extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      index: 0,
    };
    this.text = logTextPrependAlways + this.props.log_text;
  }

  tick() {
    const { props, state } = this;
    if (state.index < this.text.length) {
      this.setState({ index: state.index + 1 * (props?.frame_skip || 1) });
    } else {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        const { act } = useBackend();
        // All UI actions close the program
        act('PC_exit');
      }, this.props.end_pause || 500);
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
    const toShow = this.text.substring(
      0,
      Math.min(state.index, this.text.length),
    );
    return (
      <Section fill scrollable backgroundColor="black">
        {(logTextAlways + toShow).split('\n').map((log) =>
          log !== '\n' ? (
            <Box mb={1} key={log}>
              <font color="white">{log}</font>
            </Box>
          ) : null,
        )}
      </Section>
    );
  }
}
