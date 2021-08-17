import { DraggableControl } from '.';
import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { AnimatedNumber } from './AnimatedNumber';

export class DraggableOrbitalMap extends DraggableControl {
  constructor(props) {
    super(props);

    if (this.props.onUpdate)
    {
      this.crazy_update = setInterval(() => {
        const {
          onUpdate,
        } = this.props;
        onUpdate();
      }, 50);
    }

    this.handleDragEnd = e => {
      const {
        onChange,
        onDrag,
        onClick,
      } = this.props;
      const {
        dragging,
        value,
        internalValue,
      } = this.state;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        editing: false,
        origin: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      }
      else {
        onClick(e, value);
      }
    };
  }
}
