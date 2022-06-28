import { TextArea } from 'tgui/components';
import { WINDOW_SIZES } from '../constants';
import { dragStartHandler } from 'tgui/drag';
import { eventHandlerMap } from '../handlers';
import { getCss, getTheme, timers } from '../helpers';
import { Component, createRef } from 'inferno';
import { Modal, State } from '../types';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  events: Modal['events'] = eventHandlerMap(this);
  fields: Modal['fields'] = {
    historyCounter: 0,
    innerRef: createRef(),
    lightMode: false,
    maxLength: 1024,
    radioPrefix: '',
    tempHistory: '',
    value: '',
  };
  state: Modal['state'] = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: WINDOW_SIZES.small,
  };
  timers: Modal['timers'] = timers;

  componentDidMount() {
    this.events.onComponentMount();
  }

  componentDidUpdate() {
    if (this.state.edited) {
      this.events.onComponentUpdate();
    }
  }

  render() {
    const { onClick, onEnter, onEscape, onKeyDown, onInput } = this.events;
    const { innerRef, lightMode, maxLength, radioPrefix, value } = this.fields;
    const { buttonContent, channel, edited, size } = this.state;
    const theme = getTheme(lightMode, radioPrefix, channel);

    return (
      <div
        className={getCss('modal', theme, size)}
        onmousedown={dragStartHandler}
        $HasKeyedChildren>
        <div className="top-border" />
        <div className="left-border" />
        <div className="modal__content" $HasKeyedChildren>
          {!!theme && (
            <button
              className={getCss('button', theme)}
              onclick={onClick}
              type="submit">
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('textarea', theme)}
            dontUseTabForIndent
            innerRef={innerRef}
            maxLength={maxLength}
            onEnter={onEnter}
            onEscape={onEscape}
            onInput={onInput}
            onKey={onKeyDown}
            selfClear
            value={edited && value}
          />
        </div>
        <div className="bottom-border" />
        <div className="right-border" />
      </div>
    );
  }
}
