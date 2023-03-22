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
  const { radioPrefix, value } = this.fields;
  if (NO_RADIO_CHANNELS.includes(CHANNELS[channel]) || !value || value.length < 1) {
    return;
  }
  if (value.startsWith(';') && channel === 0) {
    this.fields.value = value?.slice(1);
    this.fields.radioPrefix = ';';
    this.setState({
      buttonContent: CHANNELS[1],
      channel: 1,
      edited: true,
    });
  }
  if (value.length < 3) {
    return;
  }
  let nextPrefix = value?.slice(0, 3)?.toLowerCase();
  if (nextPrefix.startsWith('.')) {
    nextPrefix = nextPrefix.replace('.', ':');
  }
  if (!RADIO_PREFIXES[nextPrefix] || radioPrefix === nextPrefix) {
    return;
  }
  this.fields.value = value?.slice(3);
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
