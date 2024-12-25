import { Component } from 'inferno';
import { TextArea } from './TextArea';

const DEFAULT_UPDATE_INTERVAL = 4000;

interface BufferedTextAreaState {
  bufferedText: string;
  textChanged: boolean;
}

interface BufferedTextAreaPropsUnique {
  updateValue: (value: string) => void;
  value?: string;
  updateInterval?: number;
}

// If anyone ever refactors TextArea to use TypeScript, remove the & Record<string, unknown> part
type BufferedTextAreaProps = BufferedTextAreaPropsUnique & Record<string, unknown>;

export class BufferedTextArea extends Component<BufferedTextAreaProps, BufferedTextAreaState> {
  bufferTimer: NodeJS.Timeout;
  state = {
    bufferedText: this.props.value || '',
    textChanged: false,
  };

  componentDidMount() {
    this.bufferTimer = setInterval(this.pushBuffer.bind(this), this.props.updateInterval || DEFAULT_UPDATE_INTERVAL);
  }

  componentWillUnmount() {
    this.pushBuffer();
    clearInterval(this.bufferTimer);
  }

  pushBuffer = () => {
    if (this.state.textChanged) {
      this.props.updateValue(this.state.bufferedText);
      this.setState({ textChanged: false });
    }
  };

  render() {
    const { updateValue, value, updateInterval, ...rest } = this.props;
    return (
      <TextArea
        onInput={(_, value) => this.setState({ bufferedText: value, textChanged: true })}
        onChange={this.pushBuffer.bind(this)}
        value={this.state.bufferedText}
        {...rest}
      />
    );
  }
}
