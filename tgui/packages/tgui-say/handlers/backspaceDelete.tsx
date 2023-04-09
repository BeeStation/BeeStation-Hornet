import { CHANNELS } from '../constants';
import { Modal } from '../types';

/**
 * 1. Resets history if editing a message
 * 2. Backspacing while empty resets any radio subchannels (if show prefix is off)
 * 3. Ensures backspace and delete calculate window size
 */
export const handleBackspaceDelete = function (this: Modal) {
  const { buttonContent, channel } = this.state;
  const { radioPrefix, showRadioPrefix, value } = this.fields;
  // User is on a chat history message
  if (typeof buttonContent === 'number') {
    this.fields.historyCounter = 0;
    this.setState({ buttonContent: CHANNELS[channel] });
  }
  if (!showRadioPrefix && !value?.length && radioPrefix) {
    this.fields.radioPrefix = '';
    if (radioPrefix === ';') {
      this.setState({
        buttonContent: CHANNELS[0],
        channel: 0,
      });
    } else {
      this.setState({
        buttonContent: CHANNELS[channel],
      });
    }
  }
  this.events.onSetSize(value?.length);
};
