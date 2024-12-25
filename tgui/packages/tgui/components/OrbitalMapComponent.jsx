import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component } from 'inferno';

const FPS = 20;

/**
 * Reduces screen offset to a single number based on the matrix provided.
 */
const getScalarScreenOffset = (e, matrix) => {
  return e.screenX * matrix[0] + e.screenY * matrix[1];
};

export class OrbitalMapComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      valueX: 0,
      valueY: 0,
      dragging: false,
      internalValueX: null,
      internalValueY: null,
      originX: null,
      originY: null,
      suppressingFlicker: false,
      xOffset: 0, // Map X offset
      yOffset: 0, // Map Y Offset
    };

    // Suppresses flickering while the value propagates through the backend
    this.flickerTimer = null;
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        clearTimeout(this.flickerTimer);
        this.flickerTimer = setTimeout(
          () =>
            this.setState({
              suppressingFlicker: false,
            }),
          suppressFlicker
        );
      }
    };

    this.handleDragStart = (e) => {
      const { valueX, valueY, dragMatrixX, dragMatrixY } = this.props;
      document.body.style['pointer-events'] = 'none';
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: getScalarScreenOffset(e, dragMatrixX),
        originY: getScalarScreenOffset(e, dragMatrixY),
        valueX: valueX,
        valueY: valueY,
        internalValueX: valueX,
        internalValueY: valueY,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      this.dragInterval = setInterval(() => {
        const { dragging, valueX, valueY } = this.state;
        const { onDrag } = this.props;
        if (dragging && onDrag) {
          onDrag(e, valueX, valueY);
        }
      }, 1000 / FPS);
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
    };

    this.handleDragMove = (e) => {
      const { minValue, maxValue, step, stepPixelSize, dragMatrixX, dragMatrixY } = this.props;
      const scalarScreenOffsetX = getScalarScreenOffset(e, dragMatrixX);
      const scalarScreenOffsetY = getScalarScreenOffset(e, dragMatrixY);
      this.setState((prevState) => {
        const state = { ...prevState };
        const offsetX = scalarScreenOffsetX - state.originX;
        const offsetY = scalarScreenOffsetY - state.originY;
        if (prevState.dragging) {
          const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;
          // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)
          // X TRANSLATION
          state.internalValueX = clamp(
            state.internalValueX + (offsetX * step) / stepPixelSize,
            minValue - step,
            maxValue + step
          );
          // Clamp the final value
          state.valueX = clamp(state.internalValueX - (state.internalValueX % step) + stepOffset, minValue, maxValue);
          // Y TRANSLATION
          state.internalValueY = clamp(
            state.internalValueY + (offsetY * step) / stepPixelSize,
            minValue - step,
            maxValue + step
          );
          // Clamp the final value
          state.valueY = clamp(state.internalValueY - (state.internalValueY % step) + stepOffset, minValue, maxValue);
          state.xOffset = state.valueX;
          state.yOffset = state.valueY;
          state.originX = scalarScreenOffsetX;
          state.originY = scalarScreenOffsetY;
        } else if (Math.abs(offsetX) > 4 || Math.abs(offsetY) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = (e) => {
      const { onChange, onDrag, onClick } = this.props;
      const { dragging, valueX, valueY, xOffset, yOffset } = this.state;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, valueX, valueY);
        }
        this.setState({
          xOffset: valueX,
          yOffset: valueY,
        });
        if (onDrag) {
          onDrag(e, valueX, valueY);
        }
      } else {
        onClick(e, xOffset, yOffset);
      }
    };
  }

  render() {
    const { dragging, xOffset, yOffset } = this.state;
    const { children, isTracking, dynamicXOffset, dynamicYOffset } = this.props;

    // Return a part of the state for higher-level components to use.
    return children({
      dragging: dragging,
      xOffset: isTracking ? dynamicXOffset : xOffset,
      yOffset: isTracking ? dynamicYOffset : yOffset,
      handleDragStart: this.handleDragStart,
    });
  }
}

OrbitalMapComponent.defaultHooks = pureComponentHooks;
OrbitalMapComponent.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50,
  dragMatrixX: [-1, 0],
  dragMatrixY: [0, -1],
};
