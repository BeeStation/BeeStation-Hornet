import { isEscape } from 'common/keys';
import { Component, createRef } from 'react';
import { TextArea } from 'tgui/components';
import { dragStartHandler } from 'tgui/drag';

import { WINDOW_SIZES } from '../constants';
import { eventHandlerMap } from '../handlers';
import { getCss, getTheme, timers } from '../helpers';
import { Modal, State } from '../types';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  events: Modal['events'] = eventHandlerMap(this);
  fields: Modal['fields'] = {
    historyCounter: 0,
    innerRef: createRef(),
    lightMode: false,
    showRadioPrefix: false,
    dpi: 1,
    maxLength: 1024,
    radioPrefix: '',
    tempHistory: '',
    value: '',
  };
  timers: Modal['timers'] = timers;
  state: State = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: WINDOW_SIZES.small,
  };

  componentDidMount() {
    this.events.onComponentMount();
  }

  componentDidUpdate() {
    if (this.state.edited) {
      this.events.onComponentUpdate();
    }
  }

  render() {
    const { onClick, onContextMenu, onEnter, onEscape, onKeyDown, onInput } =
      this.events;
    const { innerRef, lightMode, maxLength, radioPrefix, value } = this.fields;
    const { buttonContent, channel, edited, size } = this.state;
    const theme = getTheme(lightMode, radioPrefix, channel);

    return (
      <div
        className={getCss('modal', theme, size)}
        onMouseDown={dragStartHandler}
        onKeyDown={(event) => {
          if (isEscape(event.key)) {
            onEscape();
          }
        }}
      >
        <div className="top-border" />
        <div className="left-border" />
        <div className="modal__content">
          {!!theme && (
            <button
              className={getCss('button', theme)}
              onClick={onClick}
              onContextMenu={(e) => {
                e.preventDefault();
                onContextMenu();
              }}
              type="submit"
            >
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('textarea', theme)}
            dontUseTabForIndent
            onmousedown={(e) => {
              e.stopPropagation();
            }}
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
