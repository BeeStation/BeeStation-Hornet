import { CHANNELS } from '../constants';
import { storeChat, windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses enter. Closes if no value. */
export const handleEnter = function (
  this: Modal,
  event: KeyboardEvent,
  value: string
) {
  const { channel } = this.state;
  const { maxLength, radioPrefix } = this.fields;
  event.preventDefault();
  if (value && value.length < maxLength) {
    storeChat(value);
    Byond.sendMessage('entry', {
      channel: CHANNELS[channel],
      entry:
        radioPrefix === ';' && value.startsWith(';') ? value.slice(1) : value,
    });
  }
  this.events.onReset();
  windowClose();
};
