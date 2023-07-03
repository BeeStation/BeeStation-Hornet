import { CHANNELS, RADIO_PREFIXES } from '../constants';
import { windowClose, windowLoad, windowOpen } from '../helpers';
import { Modal } from '../types';

/** Attach listeners, sets window size just in case */
export const handleComponentMount = function (this: Modal) {
  Byond.subscribeTo('props', (data) => {
    this.fields.maxLength = data.maxLength;
    this.fields.lightMode = !!data.lightMode;
    this.fields.showRadioPrefix = !!data.showRadioPrefix;
  });
  Byond.subscribeTo('force', () => {
    this.events.onForce();
  });
  Byond.subscribeTo('open', (data) => {
    const channel = CHANNELS.indexOf(data.channel) || 0;
    this.setState({
      buttonContent:
        RADIO_PREFIXES[this.fields.radioPrefix]?.label || CHANNELS[channel],
      channel,
    });
    setTimeout(() => {
      this.fields.innerRef.current?.focus();
    }, 1);
    windowOpen(CHANNELS[channel]);
  });
  Byond.subscribeTo('close', () => {
    windowClose();
  });
  windowLoad();
};
