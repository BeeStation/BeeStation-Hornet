import { RADIO_PREFIXES, CHANNELS, NO_RADIO_CHANNELS } from '../constants';
import { Modal } from '../types';

/**
 * Gets any channel prefixes from the chat bar
 * and changes to the corresponding radio subchannel.
 *
 * Exemptions: Channel is OOC, value is too short,
 * Not a valid radio pref, or value is already the radio pref.
 */
export const handleRadioPrefix = function (this: Modal) {
  const { channel } = this.state;
  const { radioPrefix, showRadioPrefix, value } = this.fields;
  if (NO_RADIO_CHANNELS.includes(CHANNELS[channel])) {
    return;
  }
  if (!value || value.length < 1) {
    return;
  }
  if (showRadioPrefix) {
    if (radioPrefix === ';') {
      if (value.startsWith(';')) {
        return;
      } else {
        this.fields.radioPrefix = '';
        this.setState({
          buttonContent: CHANNELS[0],
          channel: 0,
          edited: true,
        });
        return;
      }
    } else if (value.startsWith(';') && channel === 0) {
      this.fields.radioPrefix = ';';
      this.setState({
        buttonContent: CHANNELS[1],
        channel: 1,
        edited: true,
      });
      return;
    }
  } else if (value.startsWith(';') && channel === 0) {
    this.fields.value = value?.slice(1);
    this.fields.radioPrefix = ';';
    this.setState({
      buttonContent: CHANNELS[1],
      channel: 1,
      edited: true,
    });
  }
  if (value.length < 3) {
    if (showRadioPrefix) {
      this.fields.radioPrefix = '';
      if (radioPrefix?.length > 0 && value.startsWith(radioPrefix.slice(0, 2))) {
        this.fields.value = '';
      }
      this.setState({
        buttonContent: CHANNELS[channel],
        edited: true,
      });
    }
    return;
  }
  let nextPrefix = value?.slice(0, 3)?.toLowerCase();
  if (nextPrefix.startsWith('.')) {
    nextPrefix = nextPrefix.replace('.', ':');
  }
  if (radioPrefix === nextPrefix) {
    return;
  }
  if (!RADIO_PREFIXES[nextPrefix]) {
    if (!showRadioPrefix) {
      return;
    }
    this.fields.radioPrefix = '';
    if (radioPrefix?.length > 0 && value.startsWith(radioPrefix.slice(0, 2))) {
      this.fields.value = value.slice(2);
    }
    this.setState({
      buttonContent: CHANNELS[channel],
      edited: true,
    });
    return;
  }
  if (!showRadioPrefix) {
    this.fields.value = value?.slice(3);
  }
  // Binary is a "secret" channel
  if (nextPrefix === ':b ') {
    Byond.sendMessage('thinking', { mode: false });
  } else if (radioPrefix === ':b ' && nextPrefix !== ':b ') {
    Byond.sendMessage('thinking', { mode: true });
  }
  this.fields.radioPrefix = nextPrefix;
  this.setState({
    buttonContent: RADIO_PREFIXES[nextPrefix]?.label,
    channel: 0,
    edited: true,
  });
};
